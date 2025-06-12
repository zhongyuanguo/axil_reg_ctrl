#!/bin/python3

import re
import os
import sys
import math
import argparse

def parameter_parser ():
    parser = argparse. ArgumentParser (description="Process Files Target.")
    parser . add_argument ("-s", " -- source", type=str, required=False, help="Filter File")
    args = parser.parse_args ()
    filter_file = args. source
    return filter_file

emu_dir     = os.environ.get("emu")
work_dir    = os.environ.get("WORK_DIR")
work_id     = os.environ.get("WID")
par_id      = os.environ.get("PID")
top_module  = os.environ.get("TOP_MODULE")
flist_dir   = os.environ.get("COMPILE_SPEC")
fter_dir    = os.environ.get("FILTER_SPEC")

output_file = work_dir+"/analyze.f"
output_hand = open(output_file, "w")

srctcl_file = work_dir+"/analyze.tcl"
srctcl_hand = open(srctcl_file, "w")

ft_comment = r"^#"
fl_comment = r"^//"

component_list = []

class compile_spec:
    def _init_(self, name, path, child, flist):
        self.name = name
        self.path = path
        self.child = child
        self.flist = flist

def phase_filter(filter_dir):
    add_dict    = {}
    over_dict   = {}
    exc_dict    = {}
    dict_list   = []
    comment_pat = ft_comment
    ftdir_list  = filter_dir.split(" ")
    command_pat = r"^\[(\w+)\]"
    command_opt = 0
    add_pat     = r"^(\w+)[\s|] *: [\s|]*(.*)"
    over_pat    = r"^(\w+)[\s|] *: [\s|]*(\w+\.(?:v|vh|vhd|sv)) [\s|]*\((.*)\)"
    exc_pat     = r"^(\w+)[\s|] *: [\s|]*(\w+\.(?:v|vh|vhd|sv))$"
    for each in ftdir_list:
        ftfile_hand = open(each, "r")
        for line in ftfile_hand:
            # skip comment line
            skip_match = re.match(comment_pat, line.strip())
            if skip_match:
                continue
            # begin phase filter file
            else:
                command_match = re.match(command_pat, line.strip())
                # check command
                if command_match:
                    if command_match.group(1) == "ADD":
                        command_opt = 1
                    elif command_match.group(1) == "OVERRIDE":
                        command_opt = 2
                    elif command_match.group(1) == "EXCLUDE":
                        command_opt = 3
                # command add
                if command_opt == 1:
                    add_match = re.match(add_pat, line.strip())
                    if add_match:
                        spec_name = add_match.group(1)
                        file_name = add_match.group(2)
                        if not spec_name in add_dict:
                            add_dict[spec_name] = []
                        add_dict[spec_name].append(replace_env_vars_in_path(file_name))
                        #print(f"ADD NAME: {spec_name}, {replace_env_vars_in_path(file_name)}")
                # command override
                elif command_opt == 2:
                    over_match = re.match(over_pat, line.strip())
                    if over_match:
                        spec_name = over_match.group(1)
                        file_name = over_match.group(2)
                        over_name = over_match.group(3)
                        if not spec_name in over_dict:
                            over_dict [spec_name] = {}
                        over_dict[spec_name][file_name] = replace_env_vars_in_path(over_name.strip())
                        #print(f"OVER NAME: {spec_name}, {file_name}, {over_name}")
                # command exclude
                elif command_opt == 3:
                    exc_match = re.match(exc_pat, line. trip())
                    exc_match = re.match(exc_pat, line.strip())
                    if exc_match:
                        spec_name = exc_match.group(1)
                        file_name = exc_match.group(2)
                        if not spec_name in exc_dict:
                            exc_dict[spec_name] = []
                        exc_dict[spec_name].append(file_name)
//                        #print(f"EXCLUDE NAME: {spec_name}, {file_name}")
    dict_list.append(add_dict)
    dict_list.append(over_dict)
    dict_list.append(exc_dict)
    return dict_list

def phase_flist(flist_dir):
    # list of compile spec directory
    dir_list = flist_dir. split(" ")
    for path in dir_list:
        # get file name with abstract path
        file_name = get_flist_file(path)
        analyze_file_list(file_name)
    return

# analyze file-list
# file_path: input file of file-list with directory in abspath
def analyze_file_list(file_path):
    """
    Analyze the given file list and populate component hierarchy.
    Handles environment variables and resolves relative paths to absolute ones.
    """
    comment_pat = fl_comment
    fflist_pat = r"^\-[f|F]\s+(.*\.f)"
    srcfile_pat = r"^(.*\.[v|vh|vhd|sv])"

    spec_name = os.path.splitext(os.path.basename(file_path))[0]
    component = compile_spec(spec_name, file_path, [], [])

    with open(file_path, "r") as target_hand:
        for line in target_hand:
            stripped_line = line.strip()

            # Skip comments and empty lines
            if re.match(comment_pat, stripped_line) or not stripped_line:
                continue

            # Match include file list (-f)
            fflist_match = re.match(fflist_pat, stripped_line)
            if fflist_match:
                # Extract and resolve file list path
                fflist_path = replace_env_vars_in_path(fflist_match.group(1))
                resolved_path = os.path.abspath(os.path.join(os.path.dirname(file_path), fflist_path))

                component.child.append(os.path.splitext(os.path.basename(resolved_path))[0])
                analyze_file_list(resolved_path)
                continue

            # Match source file entry
            srcfile_match = re.match(srcfile_pat, stripped_line)
            if srcfile_match:
                # conversion of env-variable
                converted_line = replace_env_vars_in_path(stripped_line)
                if not os.path.isabs(converted_line):
                    converted_line = os.path.abspath(os.path.join(os.path.dirname(file_path), converted_line))
                
                # Append both the resolved path and original line
                component.flist.append(converted_line)
                component.flist.append(line)

    component_list.append(component)

def filter_component_list(dict_list):
    add_dict = dict_list[0]
    #print(f"DEBUG --- >{add_dict}")
    over_dict = dict_list[1]
    exc_dict = dict_list[2]
    for component in component_list:
        output_list = []
        spec_name = component.name
        #print(f"DEBUG --- >{spec_name}")
        if spec_name in over_dict:
            file_list = component.flist
            for f in file_list:
                file_name = os.path.basename(f)
                if file_name in over_dict[spec_name]:
                    output_list.append("// OVERRIDE: "+f)
                    output_list.append(over_dict[spec_name][file_name])
                else:
                    output_list.append(f)
        elif spec_name in exc_dict:
            #print(f"DEBUG --- >GET {spec_name} TO EXCLUDE")
            file_list = component.flist
            for f in file_list:
                file_name = os. path. basename(f)
                #print(f"EXCLUDE: {file_name}")
                #print(f"TARGET: {exc_dict[spec_name]}")
                if file_name in exc_dict[spec_name]:
                    output_list.append("// EXCLUDE: "+f)
                else:
                    output_list.append(f)
        elif spec_name in add_dict:
            #print(f"DEBUG --- >GET {spec_name} TO ADD")
            output_list = component.flist
            output_list.append("// ADD: ")
            for f in add_dict[spec_name]:
                #print(f"ADD: {f}")
                output_list.append(f)
        else:
            for f in component.flist:
                output_list.append(f)
        component. flist = output_list
    return

def filter_component_list_pro(dict_list):
    add_dict = dict_list[0]
    #print(f"DEBUG --- >{add_dict}")
    over_dict = dict_list[1]
    exc_dict = dict_list[2]
    for component in component_list:
        output_list = []
        spec_name = component.name
        #print(f"DEBUG --- >{spec_name}")
        for f in component.flist:
            file_base_name = os.path.basename(f)
            if spec_name in over_dict and file_base_name in over_dict[spec_name]:
                output_list.append("// OVERRIDE: "+f)
                output_list.append(over_dict[spec_name][file_base_name])
            elif spec_name in exc_dict and file_base_name in exc_dict[spec_name]:
                #print(f"DEBUG --- >GET {spec_name} TO EXCLUDE")
                output_list.append("// EXCLUDE: "+f)
            else:
                output_list.append(f)
        if spec_name in add_dict:
            #print(f"DEBUG --- >GET {spec_name} TO ADD")
            output_list.append("// ADD: ")
            for f in add_dict[spec_name]:
                #print(f"ADD: {f}")
                output_list.append(f)
        component. flist = output_list
    return

def replace_env_vars_in_path(path):
    # Use proper string formatting for environment variables
    for var in os.environ:
        env_var = "${}".format(var)
        if env_var in path:
            path = path.replace(env_var, os.environ[var])
    return path.strip()

def get_flist_file(path):
    for root, dirs, files in os.walk(path):
        for f in files:
            if f.endswith(".f"):
                return os.path.join(root, f)
    return 0


def gen_file_list():
    comment_pat = fl_comment
    file_num = 0
    output_list = []
    output_list.append("//--------------------------------------------------")
    output_list.append("// Generate File List")
    output_list.append("//--------------------------------------------------")
    output_list.append("")
    for component in component_list:
        output_list.append("//--------------------------------------------------")
        output_list.append("// Compile Spec: "+component.name)
        output_list.append("// File List   : "+component.path)
        children = ""
        for child in component.child:
            children += child+" "

        output_list.append("// Children Spec : "+children)
        output_list.append("//--------------------------------------------------")
        output_list.append("")
        for f in component.flist:
            skip_match = re.match(comment_pat, f)
            if not skip_match:
                if f in output_list:
                    output_list.append("// REDEFINE: "+f)
                else:
                    file_num += 1
                    output_list.append(f)
            else:
                file_num += 1
                output_list.append(f)
        output_list.append("")
    output_list.append("//--------------------------------------------------")
    output_list.append("// End of File List")
    output_list.append("// File Number       : "+str(file_num))
    output_list.append("//--------------------------------------------------")
    return output_list

def gen_srcfile(srcfile_list):
    srcfile_pat = r"(.*\.[v|vhd])$"
    comment_pat = r"^//(.*)"
    output_list = []
    for line in srcfile_list:
        comment_match = re.match(comment_pat, line. strip())
        if comment_match:
            output_list.append("# "+comment_match.group(1).strip())
        else:
            srcfile_match = re.match(srcfile_pat, line.strip())
            if srcfile_match:
                if "vhd" in srcfile_match.group(1):
                    output_list.append("read_vhdl "+srcfile_match.group(1).strip())
                else:
                    output_list.append("read_verilog "+srcfile_match.group(1).strip())
            else:
                output_list.append(line)
    return output_list

def gen_srcfile_pro(srcfile_list):
    srcfile_pat = r"(^/[^/][a-zA-Z0-9_/\$\{}]+)\.(v|vhd|sv)$"
    comment_pat = r"^//(.*)"
    output_list = []
    for line in srcfile_list:
        comment_match = re.match(comment_pat, line.strip())
        if comment_match:
            output_list.append("#"+comment_match.group(1).strip())
        else:
            srcfile_match = re.match(srcfile_pat, line.strip())
            if srcfile_match:
                if "v" == srcfile_match.group(2):
                    output_list.append("read_verilog "+srcfile_match.group(1).strip()+".v")
                elif "vhd" == srcfile_match.group(2):
                    output_list.append("read_vhdl "+srcfile_match.group(1).strip()+".vhd")
                elif "sv" == srcfile_match.group(2):
                    output_list.append("read_verilog "+srcfile_match.group(1).strip()+".sv")
            else:
                output_list.append(line)
    return output_list

def generate_verilog_file_list(output_list):
    verilog_pattern = r"^/[^/][a-zA-Z0-9_/$\{\}]+\.(?:v|sv)$"
    verilog_file_list = []
    for each in output_list:
        verilog_match = re.match(verilog_pattern, each.strip())
        if verilog_match:
            verilog_file_list.append(verilog_match.group())
    return verilog_file_list

def generate_vhdl_file_list(output_list):
    vhdl_pattern = r"^/[^/][a-zA-Z0-9_/$\{\]+\.vhd$"
    return [each.strip() for each in output_list if re.match(vhdl_pattern, each.strip())]

def list_to_file(file_list, file_name):
    file_hand = open(file_name, "w")
    for each in file_list:
        file_hand.write(each)
        file_hand.write("\n")
        file_hand.close()
    return

# Process filter specifications to get add/override/exclude dictionaries
dict_list = phase_filter(fter_dir)

# Process file list specifications to build component hierarchy
phase_flist(flist_dir)
#filter_component_list(dict_list)
filter_component_list_pro(dict_list)
output_list = gen_file_list()

#print(fter_dir)

verilog_file_list = generate_verilog_file_list(output_list)
list_to_file(verilog_file_list, work_dir+"/analyze_verilog.f")
vhdl_file_list = generate_vhdl_file_list(output_list)
list_to_file(vhdl_file_list, work_dir+"/analyze_vhdl.f")

for each in output_list:
    output_hand.write(each)
    output_hand.write("\n")
output_hand. close()
output_list = gen_srcfile_pro(output_list)
for each in output_list:
    srctcl_hand.write(each)
    srctcl_hand.write("\n")
srctcl_hand.close()