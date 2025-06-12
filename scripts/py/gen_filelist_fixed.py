#!/bin/python3

import re
import os
import sys
import math
import argparse

# Parse command line arguments for filter file
parser = argparse.ArgumentParser(description="Process Files Target.")
parser.add_argument("-s", "--source", type=str, required=False, help="Filter File")
args = parser.parse_args()
filter_file = args.source

# Get environment variables
emu_dir     = os.environ.get("emu")
work_dir    = os.environ.get("WORK_DIR")
work_id     = os.environ.get("WID")
par_id      = os.environ.get("PID")
top_module  = os.environ.get("TOP_MODULE")
flist_dir   = os.environ.get("COMPILE_SPEC")
fter_dir    = os.environ.get("FILTER_SPEC")

# Initialize output files
output_file = work_dir+"/analyze.f"
output_hand = open(output_file, "w")

srctcl_file = work_dir+"/analyze.tcl"
srctcl_hand = open(srctcl_file, "w")

# Define comment patterns for filter and file list files
ft_comment = r"^#"
fl_comment = r"^//"

# Global list to store component specifications
component_list = []

class compile_spec:
    """Class to represent a compilation specification."""
    def __init__(self, name, path, child, flist):
        self.name = name      # Specification name
        self.path = path      # Path to the file list
        self.child = child    # Child specifications
        self.flist = flist    # File list for this specification

def filter_component_list_pro(dict_list):
    """Process add/override/exclude directives for components in a professional manner.
    
    Args:
        dict_list: List containing add, override, and exclude dictionaries
    
    Returns:
        None: Modifies component_list global variable in place
    """
    add_dict = dict_list[0]
    over_dict = dict_list[1]
    exc_dict = dict_list[2]
    
    for component in component_list:
        output_list = []
        spec_name = component.name
        
        # Process each file in the component's file list
        for f in component.flist:
            file_base_name = os.path.basename(f)
            
            # Handle overrides
            if spec_name in over_dict and file_base_name in over_dict[spec_name]:
                output_list.append("// OVERRIDE: "+f)
                output_list.append(over_dict[spec_name][file_base_name])
            # Handle excludes
            elif spec_name in exc_dict and file_base_name in exc_dict[spec_name]:
                output_list.append("// EXCLUDE: "+f)
            # Keep normal files
            else:
                output_list.append(f)
        
        # Handle additions
        if spec_name in add_dict:
            output_list.append("// ADD: ")
            for f in add_dict[spec_name]:
                output_list.append(f)
        
        # Update the component's file list
        component.flist = output_list
    return

def phase_filter(filter_dir):
    """Process filter directives from the filter specification files.
    
    Args:
        filter_dir: Directory containing filter specification files
        
    Returns:
        list: List containing add, override, and exclude dictionaries
    """
    add_dict = {}
    over_dict = {}
    exc_dict = {}
    dict_list = []
    comment_pat = ft_comment
    ftdir_list = filter_dir.split(" ")
    command_opt = 0
    add_pat = r"^(\w+)[\s|]*: [\s|]*(.*)"
    over_pat = r"^(\w+)[\s|]*: [\s|]*(\w+\.(?:v|vh|vhd|sv)) [\s|]*$$(.*)$$"
    exc_pat = r"^(\w+)[\s|]*: [\s|]*(\w+\.(?:v|vh|vhd|sv))$"
    
    for each in ftdir_list:
        ftfile_hand = open(each, "r")
        for line in ftfile_hand:
            stripped_line = line.strip()
            
            # Skip comments
            if re.match(comment_pat, stripped_line):
                continue
            
            # Process commands
            command_match = re.match(comment_pat, stripped_line)
            if command_match:
                if command_match.group(1) == "ADD":
                    command_opt = 1
                elif command_match.group(1) == "OVERRIDE":
                    command_opt = 2
                elif command_match.group(1) == "EXCLUDE":
                    command_opt = 3
            
            # Handle ADD Option
            if command_opt == 1:
                add_match = re.match(add_pat, stripped_line)
                if add_match:
                    spec_name = add_match.group(1)
                    file_name = add_match.group(2)
                    if not spec_name in add_dict:
                        add_dict[spec_name] = []
                    add_dict[spec_name].append(replace_env_vars_in_path(file_name))
            
            # Handle OVERRIDE Option
            elif command_opt == 2:
                over_match = re.match(over_pat, stripped_line)
                if over_match:
                    spec_name = over_match.group(1)
                    file_name = over_match.group(2)
                    over_name = over_match.group(3)
                    if not spec_name in over_dict:
                        over_dict[spec_name] = {}
                    over_dict[spec_name][file_name] = replace_env_vars_in_path(over_name.strip())
            
            # Handle EXCLUDE Option
            elif command_opt == 3:
                exc_match = re.match(exc_pat, stripped_line)
                if exc_match:
                    spec_name = exc_match.group(1)
                    file_name = exc_match.group(2)
                    if not spec_name in exc_dict:
                        exc_dict[spec_name] = []
                    exc_dict[spec_name].append(file_name)
    
    dict_list.append(add_dict)
    dict_list.append(over_dict)
    dict_list.append(exc_dict)
    return dict_list

def replace_env_vars_in_path(path):
    """Replace environment variables in a path with their values.
    
    Args:
        path: Input path string that might contain environment variables
        
    Returns:
        str: Path with environment variables replaced by their values
    """
    for var in os.environ:
        env_var = "${}".format(var)
        if env_var in path:
            path = path.replace(env_var, os.environ[var])
    return path.strip()

def gen_file_list():
    """Generate a formatted file list from the component hierarchy.
    
    Returns:
        list: Formatted list representing the file hierarchy
    """
    comment_pat = fl_comment
    file_num = 0
    output_list = [
        "//--------------------------------------------------",
        "// Generated File List",
        "//--------------------------------------------------",
        ""
    ]
    
    for component in component_list:
        children = " ".join(component.child)
        
        output_list.extend([
            "//--------------------------------------------------",
            "// Compile Spec  : " + component.name,
            "// File List     : " + component.path,
            "// Children Spec : " + children,
            "//--------------------------------------------------",
            ""
        ])
        
        for f in component.flist:
            stripped_f = f.strip()
            skip_match = re.match(comment_pat, stripped_f)
            
            if not skip_match:
                if stripped_f in output_list:
                    output_list.append("// REDEFINE: " + stripped_f)
                else:
                    file_num += 1
                    output_list.append(stripped_f)
            else:
                file_num += 1
                output_list.append(stripped_f)
        
        output_list.append("")
    
    output_list.extend([
        "//--------------------------------------------------",
        "// End of File List",
        "// File Number       : " + str(file_num),
        "//--------------------------------------------------"
    ])
    
    return output_list

def gen_srcfile_pro(srcfile_list):
    """Convert source file paths to Tcl read commands with proper extensions.
    
    Args:
        srcfile_list: List of source file paths
        
    Returns:
        list: List of Tcl commands for reading the source files
    """
    srcfile_pat = r"(^/[^/][a-zA-Z0-9_/$\{}]+)\.(v|vhd|sv)$"
    comment_pat = r"^//(.*)"
    output_list = []
    
    for line in srcfile_list:
        stripped_line = line.strip()
        
        # Handle comments
        comment_match = re.match(comment_pat, stripped_line)
        if comment_match:
            output_list.append("#" + comment_match.group(1).strip())
        else:
            # Handle source files
            srcfile_match = re.match(srcfile_pat, stripped_line)
            if srcfile_match:
                path = srcfile_match.group(1)
                ext = srcfile_match.group(2)
                
                # Generate appropriate read command based on file type
                if ext == "v":
                    output_list.append("read_verilog " + path + ".v")
                elif ext == "vhd":
                    output_list.append("read_vhdl " + path + ".vhd")
                elif ext == "sv":
                    output_list.append("read_verilog " + path + ".sv")
            else:
                output_list.append(line)
    return output_list

def generate_verilog_file_list(output_list):
    """Extract Verilog/SystemVerilog files from the output list.
    
    Args:
        output_list: List of file paths to filter
        
    Returns:
        list: List of Verilog/SystemVerilog file paths
    """
    verilog_pattern = r"^/[^/][a-zA-Z0-9_/$\{\}]+\.(?:v|sv)$"
    return [each.strip() for each in output_list if re.match(verilog_pattern, each.strip())]

def generate_vhdl_file_list(output_list):
    """Extract VHDL files from the output list.
    
    Args:
        output_list: List of file paths to filter
        
    Returns:
        list: List of VHDL file paths
    """
    vhdl_pattern = r"^/[^/][a-zA-Z0-9_/$\{\}]+\.(?:vhd)$"
    return [each.strip() for each in output_list if re.match(vhdl_pattern, each.strip())]

def list_to_file(file_list, file_name):
    """Write a list of strings to a file.
    
    Args:
        file_list: List of strings to write to the file
        file_name: Name of the file to write to
    """
    with open(file_name, "w") as file_hand:
        for each in file_list:
            file_hand.write(each + "\n")
    return

def analyze_file_list(file_path):
    """Analyze a file list and populate component hierarchy.
    Handles environment variables and resolves relative paths to absolute ones.
    
    Args:
        file_path: Path to the file list to analyze
    """
    comment_pat = fl_comment
    fflist_pat = r"^-[f|F]\s+(.*\.f)"
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
                    converted_line = os.path.abspath(
                        os.path.join(os.path.dirname(file_path), converted_line)
                    )
                
                # Append both the resolved path and original line
                component.flist.append(converted_line)
                component.flist.append(line)

    component_list.append(component)

def get_flist_file(path):
    """Find a .f file in the specified directory.
    
    Args:
        path: Directory path to search in
        
    Returns:
        str: Absolute path to the found .f file, or 0 if no file is found
    """
    for root, dirs, files in os.walk(path):
        for f in files:
            if f.endswith(".f"):
                return os.path.join(root, f)
    return 0

def filter_component_list(dict_list):
    """Process add/override/exclude directives for components.
    
    Args:
        dict_list: List containing add, override, and exclude dictionaries
    
    Returns:
        None: Modifies component_list global variable in place
    """
    add_dict = dict_list[0]
    over_dict = dict_list[1]
    exc_dict = dict_list[2]
    
    for component in component_list:
        output_list = []
        spec_name = component.name
        
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
            file_list = component.flist
            for f in file_list:
                file_name = os.path.basename(f)
                if file_name in exc_dict[spec_name]:
                    output_list.append("// EXCLUDE: "+f)
                else:
                    output_list.append(f)
        elif spec_name in add_dict:
            output_list = component.flist
            output_list.append("// ADD: ")
            for f in add_dict[spec_name]:
                output_list.append(f)
        else:
            for f in component.flist:
                output_list.append(f)
        
        component.flist = output_list
    return

def phase_flist(flist_dir):
    """Process file list specifications to build component hierarchy.
    
    Args:
        flist_dir: Directory containing file list specification files
        
    Returns:
        None: Modifies component_list global variable in place
    """
    flist_pat = r"^-[f|F]\s+(.*\.f)"
    flist_dir_list = flist_dir.split(" ")
    for each in flist_dir_list:
        flist_file = get_flist_file(each)
        if flist_file:
            analyze_file_list(flist_file)
    return

# 主执行部分
# 处理过滤规范以获取添加/覆盖/排除字典
# 这在处理开始时完成
dict_list = phase_filter(fter_dir)

# Process file list specifications to build component hierarchy
# This recursively analyzes all file lists to create the component hierarchy
phase_flist(flist_dir)
#filter_component_list(dict_list)
filter_component_list_pro(dict_list)
output_list = gen_file_list()

# Generate separate file lists for Verilog and VHDL files
verilog_file_list = generate_verilog_file_list(output_list)
list_to_file(verilog_file_list, work_dir+"/analyze_verilog.f")
vhdl_file_list = generate_vhdl_file_list(output_list)
list_to_file(vhdl_file_list, work_dir+"/analyze_vhdl.f")

# Write the complete file list to output file
for each in output_list:
    output_hand.write(each + "\n")
output_hand.close()

# Generate Tcl script for source files
output_list = gen_srcfile_pro(output_list)
for each in output_list:
    srctcl_hand.write(each + "\n")
srctcl_hand.close()
