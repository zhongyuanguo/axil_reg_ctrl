#!/bin/python3

import re
import os
import sys
import math
import argparse
from typing import List, Dict, Any, Optional, Tuple
import logging
import json
from pathlib import Path

def setup_logging(log_file: Optional[Path] = None) -> logging.Logger:
    """Configure logging for the application.
    
    Args:
        log_file: Optional path to log file. If provided, logs will be written to this file.
        
    Returns:
        logging.Logger: Configured logger instance
    """
    log_format = '%(asctime)s - %(levelname)s - [%(filename)s:%(lineno)d] - %(message)s'
    datefmt = '%Y-%m-%d %H:%M:%S'
    
    if log_file:
        # Log to file if specified
        logging.basicConfig(
            level=logging.DEBUG,
            format=log_format,
            datefmt=datefmt,
            filename=str(log_file),
            filemode='w'
        )
    else:
        # Log to console by default
        logging.basicConfig(
            level=logging.INFO,
            format=log_format,
            datefmt=datefmt,
            handlers=[logging.StreamHandler(sys.stdout)]
        )
    
    return logging.getLogger(__name__)

# Set up logger
logger = setup_logging()

def parse_arguments() -> argparse.Namespace:
    """Parse command line arguments.
    
    Returns:
        argparse.Namespace: Parsed command line arguments
    """
    parser = argparse.ArgumentParser(description="Process Files Target.")
    parser.add_argument("-s", "--source", type=str, required=False, help="Filter File")
    return parser.parse_args()

def get_environment_vars() -> Dict[str, str]:
    """Get required environment variables.
    
    Returns:
        Dict[str, str]: Dictionary of environment variables
    """
    env_vars = {
        'WORK_DIR': os.environ.get("WORK_DIR"),
        'COMPILE_SPEC': os.environ.get("COMPILE_SPEC"),
        'FILTER_SPEC': os.environ.get("FILTER_SPEC")
    }
    
    # Check for missing required variables
    missing_vars = {k:v for k,v in env_vars.items() if v is None}
    if missing_vars:
        logger.error(f"Missing required environment variables: {missing_vars.keys()}")
        logger.error(f"Full environment: {dict(os.environ)}")
        raise EnvironmentError(f"Missing required environment variables: {missing_vars.keys()}")
    
    return env_vars

# Parse command line arguments for filter file is now handled by parse_arguments() function
# Environment variables are now handled by get_environment_vars() function
# File handling has been improved using context managers

# Define comment patterns for filter and file list files
ft_comment = r"^#"
fl_comment = r"^//"

# Global list to store component specifications
component_list = []

class CompileSpec:
    """Class to represent a compilation specification."""
    def __init__(self, name: str, path: str, child: List[str], flist: List[str]):
        self.name = name      # Specification name
        self.path = path      # Path to the file list
        self.child = child    # Child specifications
        self.flist = flist    # File list for this specification
        
    def __repr__(self):
        return f"CompileSpec(name='{self.name}', path='{self.path}', child_count={len(self.child)}, flist_count={len(self.flist)})"

def phase_filter(filter_dir: str) -> Dict[str, Dict[str, str]]:
    """Process filter directives from the filter specification files.
    
    Args:
        filter_dir: Directory containing filter specification files
        
    Returns:
        Dictionary containing add, override, and exclude dictionaries
    """
    logger.info(f"Processing filter directives from {filter_dir}")
    
    add_dict: Dict[str, List[str]] = {}
    over_dict: Dict[str, Dict[str, str]] = {}
    exc_dict: Dict[str, List[str]] = {}
    comment_pat = ft_comment
    
    # Split filter directory string into list
    ftdir_list = filter_dir.split(" ")
    command_opt = 0  # 0=none, 1=add, 2=override, 3=exclude
    
    # Regular expressions for parsing filter file entries
    add_pat = r"^(\w+)[\s|]*: [\s|]*(.*)"
    over_pat = r"^(\w+)[\s|]*: [\s|]*(\w+\.(?:v|vh|vhd|sv)) [\s|]*$$(.*)$$"
    exc_pat = r"^(\w+)[\s|]*: [\s|]*(\w+\.(?:v|vh|vhd|sv))$"
    
    for each_dir in ftdir_list:
        # Handle each directory in the filter specification
        logger.debug(f"Processing filter directory: {each_dir}")
        
        try:
            # Get all filter files in this directory
            filter_files = [f for f in os.listdir(each_dir) if f.endswith((".flt", ".txt", ".f"))]
            
            for filter_file in filter_files:
                with open(os.path.join(each_dir, filter_file), "r") as ftfile_hand:
                    for line_num, line in enumerate(ftfile_hand):
                        stripped_line = line.strip()

                        # Skip comments
                        if re.match(comment_pat, stripped_line):
                            continue

                        # Process commands
                        command_match = re.match(r"^$$(\w+)$$", stripped_line)
                        if command_match:
                            # Update current command based on section header
                            if command_match.group(1) == "ADD":
                                command_opt = 1
                            elif command_match.group(1) == "OVERRIDE":
                                command_opt = 2
                            elif command_match.group(1) == "EXCLUDE":
                                command_opt = 3
                            continue

                        # Handle ADD, OVERRIDE, and EXCLUDE entries based on current command
                        if command_opt == 1:  # ADD
                            add_match = re.match(add_pat, stripped_line)
                            if add_match:
                                spec_name = add_match.group(1)
                                file_name = add_match.group(2)
                                if not spec_name in add_dict:
                                    add_dict[spec_name] = []
                                resolved_path = replace_env_vars_in_path(file_name)
                                add_dict[spec_name].append(resolved_path)
                                logger.debug(f"Added {resolved_path} to {spec_name}")

                        elif command_opt == 2:  # OVERRIDE
                            over_match = re.match(over_pat, stripped_line)
                            if over_match:
                                spec_name = over_match.group(1)
                                file_name = over_match.group(2)
                                over_name = over_match.group(3)
                                if not spec_name in over_dict:
                                    over_dict[spec_name] = {}
                                resolved_over = replace_env_vars_in_path(over_name.strip())
                                over_dict[spec_name][file_name] = resolved_over
                                logger.debug(f"Overriding {file_name} with {resolved_over} in {spec_name}")

                        elif command_opt == 3:  # EXCLUDE
                            exc_match = re.match(exc_pat, stripped_line)
                            if exc_match:
                                spec_name = exc_match.group(1)
                                file_name = exc_match.group(2)
                                if not spec_name in exc_dict:
                                    exc_dict[spec_name] = []
                                exc_dict[spec_name].append(file_name)
                                logger.debug(f"Excluding {file_name} from {spec_name}")

                        else:
                            logger.warning(f"Invalid command option {command_opt} in {each_dir}/{filter_file}, line {line_num+1}")

        except Exception as e:
            logger.error(f"Error processing filter directory {each_dir}: {str(e)}", exc_info=True)
            continue
    
    result = {
        'add': add_dict,
        'override': over_dict,
        'exclude': exc_dict
    }
    
    logger.debug(f"Filter processing complete: {json.dumps(result, indent=2)}")
    return result

def replace_env_vars_in_path(path: str) -> str:
    """Replace environment variables in a path with their values.
    
    Args:
        path: Input path string that might contain environment variables
        
    Returns:
        str: Path with environment variables replaced by their values
    """
    logger.debug(f"Replacing env vars in path: {path}")
    
    for var in os.environ:
        env_var = "${}".format(var)
        if env_var in path:
            logger.debug(f"Found env var {env_var} in {path}")
            path = path.replace(env_var, os.environ[var])
    
    return path.strip()

def analyze_file_list(file_path: Path) -> bool:
    """Analyze a file list and populate component hierarchy.
    Handles environment variables and resolves relative paths to absolute ones.
    
    Args:
        file_path: Path to the file list to analyze
    
    Returns:
        bool: True if analysis was successful, False otherwise
    """
    logger.info(f"Analyzing file list: {file_path}")
    
    comment_pat = fl_comment
    fflist_pat = r"^-[f|F]\s+(.*\.f)"
    srcfile_pat = r"^(.*\.[v|vh|vhd|sv])"

    spec_name = os.path.splitext(os.path.basename(str(file_path)))[0]
    component = CompileSpec(spec_name, str(file_path), [], [])

    try:
        with open(file_path, "r") as target_hand:
            for line_num, line in enumerate(target_hand):
                stripped_line = line.strip()

                # Skip comments and empty lines
                if re.match(comment_pat, stripped_line) or not stripped_line:
                    continue

                # Match include file list (-f)
                fflist_match = re.match(fflist_pat, stripped_line)
                if fflist_match:
                    # Extract and resolve file list path
                    fflist_path = replace_env_vars_in_path(fflist_match.group(1))
                    resolved_path = Path(fflist_path).resolve()
                    
                    logger.debug(f"Found included file list: {resolved_path}")
                    component.child.append(resolved_path.name)
                    
                    # Recursively analyze the included file list
                    if not analyze_file_list(resolved_path):
                        logger.warning(f"Failed to analyze included file list: {resolved_path}")
                    continue

                # Match source file entry
                srcfile_match = re.match(srcfile_pat, stripped_line)
                if srcfile_match:
                    # Handle environment variables and resolve paths
                    converted_line = replace_env_vars_in_path(stripped_line)
                    resolved_path = Path(converted_line).resolve()
                    
                    # Append both the resolved path and original line
                    component.flist.append(str(resolved_path))
                    component.flist.append(line)
                    logger.debug(f"Added source file: {resolved_path}")
                else:
                    logger.warning(f"Unrecognized line format at line {line_num+1} in {file_path}: {stripped_line}")
                    component.flist.append(line)

        component_list.append(component)
        logger.debug(f"Completed analysis of {file_path}. Found {len(component.flist)} files.")
        return True
    
    except Exception as e:
        logger.error(f"Error analyzing file list {file_path}: {str(e)}", exc_info=True)
        return False

def get_flist_file(path: str) -> Optional[Path]:
    """Find a .f file in the specified directory.
    
    Args:
        path: Directory path to search in
        
    Returns:
        Path: Absolute path to the found .f file, or None if no file is found
    """
    logger.debug(f"Searching for .f file in {path}")
    
    try:
        # Use pathlib's glob method for more efficient searching
        path_obj = Path(path)
        
        # First look for common file list names
        for common_name in ["filelist.f", "compile.f", "sources.f"]:
            flist_path = path_obj / common_name
            if flist_path.exists():
                logger.info(f"Found standard file list: {flist_path}")
                return flist_path.resolve()
        
        # If no standard name found, find any .f file
        flist_files = sorted(path_obj.glob("**/*.f"))
        
        if flist_files:
            logger.info(f"Found file list: {flist_files[0]}")
            return flist_files[0].resolve()
        
        logger.warning(f"No .f file found in {path}")
        return None
    except Exception as e:
        logger.error(f"Error searching for .f file in {path}: {str(e)}", exc_info=True)
        return None

def filter_component_list(dict_list: Dict[str, Dict[str, str]]) -> None:
    """Process add/override/exclude directives for components.
    
    Args:
        dict_list: Dictionary containing add, override, and exclude dictionaries
    
    Returns:
        None: Modifies component_list global variable in place
    """
    logger.info("Processing component list with basic filtering")
    
    add_dict = dict_list.get('add', {})
    over_dict = dict_list.get('override', {})
    exc_dict = dict_list.get('exclude', {})
    
    for component in component_list:
        output_list = []
        spec_name = component.name
        logger.debug(f"Processing component {spec_name} with {len(component.flist)} files")
        
        if spec_name in over_dict:
            file_list = component.flist
            for f in file_list:
                file_name = os.path.basename(f)
                if file_name in over_dict[spec_name]:
                    new_entry = f"// OVERRIDE: {f}"
                    output_list.append(new_entry)
                    output_list.append(over_dict[spec_name][file_name])
                    logger.debug(f"Overriding {file_name} in {spec_name}")
                else:
                    output_list.append(f)
        elif spec_name in exc_dict:
            file_list = component.flist
            for f in file_list:
                file_name = os.path.basename(f)
                if file_name in exc_dict[spec_name]:
                    output_list.append(f"// EXCLUDE: {f}")
                    logger.debug(f"Excluding {file_name} from {spec_name}")
                else:
                    output_list.append(f)
        elif spec_name in add_dict:
            output_list = component.flist.copy()
            output_list.append("// ADD: ")
            for f in add_dict[spec_name]:
                output_list.append(f)
                logger.debug(f"Adding {f} to {spec_name}")
        else:
            output_list = component.flist.copy()
        
        # Update the component's file list
        component.flist = output_list
        logger.debug(f"Component {spec_name} now has {len(output_list)} files")

def filter_component_list_pro(dict_list: Dict[str, Dict[str, str]]) -> None:
    """Process add/override/exclude directives for components in a professional manner.
    
    Args:
        dict_list: Dictionary containing add, override, and exclude dictionaries
    
    Returns:
        None: Modifies component_list global variable in place
    """
    logger.info("Processing component list with professional filtering")
    
    add_dict = dict_list.get('add', {})
    over_dict = dict_list.get('override', {})
    exc_dict = dict_list.get('exclude', {})
    
    for component in component_list:
        output_list = []
        spec_name = component.name
        logger.debug(f"Processing component {spec_name} with {len(component.flist)} files")
        
        # Process each file in the component's file list
        for f in component.flist:
            file_base_name = os.path.basename(f)
            
            # Handle overrides
            if spec_name in over_dict and file_base_name in over_dict[spec_name]:
                output_list.append(f"// OVERRIDE: {f}")
                output_list.append(over_dict[spec_name][file_base_name])
                logger.debug(f"Overriding {file_base_name} in {spec_name}")
            # Handle excludes
            elif spec_name in exc_dict and file_base_name in exc_dict[spec_name]:
                output_list.append(f"// EXCLUDE: {f}")
                logger.debug(f"Excluding {file_base_name} from {spec_name}")
            # Keep normal files
            else:
                output_list.append(f)
        
        # Handle additions
        if spec_name in add_dict:
            output_list.append("// ADD: ")
            for f in add_dict[spec_name]:
                output_list.append(f)
                logger.debug(f"Adding {f} to {spec_name}")
        
        # Update the component's file list
        component.flist = output_list
        logger.debug(f"Component {spec_name} now has {len(output_list)} files")

def gen_file_list() -> List[str]:
    """Generate a formatted file list from the component hierarchy.
    
    Returns:
        list: Formatted list representing the file hierarchy
    """
    logger.info("Generating final file list")
    
    comment_pat = fl_comment
    file_num = 0
    output_list = [
        "//--------------------------------------------------",
        "// Generated File List",
        "//--------------------------------------------------",
        ""
    ]
    
    for component in component_list:
        logger.debug(f"Adding {len(component.flist)} files from {component.name}")
        children = " ".join(component.child)
        
        output_list.extend([
            "//--------------------------------------------------",
            f"// Compile Spec  : {component.name}",
            f"// File List     : {component.path}",
            f"// Children Spec : {children}",
            "//--------------------------------------------------",
            ""
        ])
        
        for f in component.flist:
            stripped_f = f.strip()
            skip_match = re.match(comment_pat, stripped_f)
            
            if not skip_match:
                if stripped_f in output_list:
                    new_entry = f"// REDEFINE: {stripped_f}"
                    output_list.append(new_entry)
                    logger.warning(f"File redefined: {stripped_f}")
                else:
                    file_num += 1
                    output_list.append(stripped_f)
            else:
                output_list.append(stripped_f)
        
        output_list.append("")
    
    output_list.extend([
        "//--------------------------------------------------",
        f"// End of File List. Total files: {file_num}",
        "//--------------------------------------------------"
    ])
    
    logger.info(f"Generated file list with {file_num} files")
    return output_list

def gen_srcfile_pro(srcfile_list: List[str]) -> List[str]:
    """Convert source file paths to Tcl read commands with proper extensions.
    
    Args:
        srcfile_list: List of source file paths
        
    Returns:
        list: List of Tcl commands for reading the source files
    """
    logger.info(f"Generating Tcl source file commands for {len(srcfile_list)} files")
    
    srcfile_pat = r"(^/[^/][a-zA-Z0-9_/$\{}]+)\.(v|vhd|sv)$"
    comment_pat = r"^//(.*)"
    output_list = []
    
    for line in srcfile_list:
        stripped_line = line.strip()
        
        # Handle comments
        comment_match = re.match(comment_pat, stripped_line)
        if comment_match:
            output_list.append("#" + comment_match.group(1).strip())
            continue
            
        # Handle source files
        srcfile_match = re.match(srcfile_pat, stripped_line)
        if srcfile_match:
            path = srcfile_match.group(1)
            ext = srcfile_match.group(2)
            
            # Generate appropriate read command based on file type
            if ext == "v":
                cmd = f"read_verilog {path}.v"
            elif ext == "vhd":
                cmd = f"read_vhdl {path}.vhd"
            elif ext == "sv":
                cmd = f"read_verilog {path}.sv"
            else:
                cmd = line  # Keep original line if no match
                
            output_list.append(cmd)
            logger.debug(f"Converted {stripped_line} to {cmd}")
        else:
            output_list.append(line)
            logger.debug(f"No conversion needed for {line}")
    
    logger.info(f"Generated {len(output_list)} Tcl commands from source files")
    return output_list

def generate_verilog_file_list(output_list: List[str]) -> List[str]:
    """Extract Verilog/SystemVerilog files from the output list.
    
    Args:
        output_list: List of file paths to filter
        
    Returns:
        list: List of Verilog/SystemVerilog file paths
    """
    logger.info("Extracting Verilog/SystemVerilog files")
    
    verilog_pattern = r"^/[^/][a-zA-Z0-9_/$\{\}]+\.(?:v|sv)$"
    verilog_files = [each.strip() for each in output_list if re.match(verilog_pattern, each.strip())]
    
    logger.info(f"Found {len(verilog_files)} Verilog/SystemVerilog files")
    return verilog_files

def generate_vhdl_file_list(output_list: List[str]) -> List[str]:
    """Extract VHDL files from the output list.
    
    Args:
        output_list: List of file paths to filter
        
    Returns:
        list: List of VHDL file paths
    """
    logger.info("Extracting VHDL files")
    
    vhdl_pattern = r"^/[^/][a-zA-Z0-9_/$\{\}]+\.(?:vhd)$"
    vhdl_files = [each.strip() for each in output_list if re.match(vhdl_pattern, each.strip())]
    
    logger.info(f"Found {len(vhdl_files)} VHDL files")
    return vhdl_files

def list_to_file(file_list: List[str], file_name: Path) -> None:
    """Write a list of strings to a file.
    
    Args:
        file_list: List of strings to write to the file
        file_name: Path object representing the file to write to
    """
    logger.info(f"Writing {len(file_list)} lines to {file_name}")
    
    try:
        with open(file_name, "w") as file_hand:
            for each in file_list:
                file_hand.write(each + "\n")
        logger.info(f"Successfully wrote file: {file_name}")
    except Exception as e:
        logger.error(f"Error writing file {file_name}: {str(e)}", exc_info=True)
        raise

def phase_flist(flist_dir: str) -> None:
    """Process file list specifications to build component hierarchy.
    This recursively analyzes all file lists to create the component hierarchy
    
    Args:
        flist_dir: Directory containing file list specification files
    
    Returns:
        None: Modifies component_list global variable in place
    """
    logger.info(f"Processing file lists from {flist_dir}")
    
    flist_dir_list = flist_dir.split(" ")
    processed_count = 0
    
    for each_dir in flist_dir_list:
        logger.debug(f"Searching in directory: {each_dir}")
        flist_file = get_flist_file(each_dir)
        
        if flist_file:
            logger.debug(f"Found file list: {flist_file}")
            if analyze_file_list(Path(flist_file)):
                processed_count += 1
                logger.info(f"Processed file list: {flist_file}")
            else:
                logger.warning(f"Failed to process file list: {flist_file}")
        else:
            logger.warning(f"No file list found in {each_dir}")
    
    logger.info(f"Completed processing {processed_count} file lists")

# Main execution section
try:
    logger.info("Starting gen_filelist script")
    logger.debug(f"Environment variables:")
    logger.debug(json.dumps(dict(os.environ), indent=2))
    
    # Parse command line arguments
    args = parse_arguments()
    
    # Get and validate environment variables
    env_vars = get_environment_vars()
    work_dir = env_vars['WORK_DIR']
    flist_dir = env_vars['COMPILE_SPEC']
    fter_dir = env_vars['FILTER_SPEC']
    
    # Create work directory if it doesn't exist
    output_dir = Path(work_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Initialize output files
    output_file = output_dir / "analyze.f"
    srctcl_file = output_dir / "analyze.tcl"
    
    try:
        # Open output files
        with open(output_file, "w") as output_hand, \
             open(srctcl_file, "w") as srctcl_hand:
            
            # Process filter directives
            dict_list = phase_filter(fter_dir)
            
            # Process file list specifications to build component hierarchy
            phase_flist(flist_dir)
            filter_component_list_pro(dict_list)
            output_list = gen_file_list()

            # Generate separate file lists for Verilog and VHDL files
            verilog_file_list = generate_verilog_file_list(output_list)
            list_to_file(verilog_file_list, output_dir / "analyze_verilog.f")
            vhdl_file_list = generate_vhdl_file_list(output_list)
            list_to_file(vhdl_file_list, output_dir / "analyze_vhdl.f")

            # Write the complete file list to output file
            list_to_file(output_list, output_file)
            logger.info(f"Completed generating main file list with {len(output_list)} entries")

            # Generate Tcl script for source files
            tcl_output_list = gen_srcfile_pro(output_list)
            list_to_file(tcl_output_list, srctcl_file)
            logger.info(f"Generated Tcl script with {len(tcl_output_list)} commands")
            
    except Exception as e:
        logger.error(f"Error working with output files: {str(e)}", exc_info=True)
        raise

except Exception as e:
    logger.error(f"Critical error in script execution: {str(e)}", exc_info=True)
    sys.exit(1)

logger.info("gen_filelist script completed successfully")
