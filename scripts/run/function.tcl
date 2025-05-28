# -------------------------------------------------------------------------------
# reportCriticalPaths
# -------------------------------------------------------------------------------
# This function generates a CSV file that provides a summary of the first
# 50 violations for both Setup and Hold analysis. So a maximum number of
# 100 paths are reported.
# -------------------------------------------------------------------------------
proc reportCriticalPaths { fileName } {
    # Open the specified output file in write mode
    set FH [open $fileName w]
    # Write the current date and CSV format to a file header
    puts $FH "#\n# File created on [clock format [clock seconds]]\n#\n"
    puts $FH "Startpoint, Endpoint, DelayType, Slack,#Levels, #LUTs"
    # Iterate through both Min and Max delay types
    foreach delayType {max min} {
        # Collect details from the 50 worst timing paths for the current analysis
        # (max = setup/recovery, min = hold/removal)
        # The $path variable contains a Timing Path object.
        foreach path [get_timing_paths -delay_type $delayType -max_paths 50 nworst 1] {
            # Get the LUT cells of the timing paths
            set luts [get_cells -filter {REF_NAME =~ LUT*} -of_object $path]
            # Get the startpoint of the Timing Path object
            set startpoint [get_property STARTPOINT_PIN $path]
            # Get the endpoint of the Timing Path object
            set endpoint [get_property ENDPOINT_PIN $path]
            # Get the slack on the Timing Path object
            set slack [get_property SLACK $path]
            # Get the number of logic levels between startpoint and endpoint
            set levels [get_property LOGIC_LEVELS $path]
            # Save the collected path details to the CSV file
            puts $FH "$startpoint, $endpoint, $delayType, $slack, $levels, [llength $luts]"
        }
    }

    # Close the output file
    close $FH
    puts "CSV file $fileName has been created. \n"
    return 0
};
# End PROC

# -------------------------------------------------------------------------------
# reportDate
# -------------------------------------------------------------------------------
# This function generates a formated date string.
# -------------------------------------------------------------------------------
proc reportDate {} {
    set now [clock seconds]
    set formattedDate [clock format $now -format "%Y-%m-%d %H: %M:%S" ]
    puts "Clock: $formattedDate"
};

# -------------------------------------------------------------------------------
# TraceDriveNet
# -------------------------------------------------------------------------------
# This function traces a signal from driving net
# -------------------------------------------------------------------------------
proc traceDriveNet { netName } {
    set drvNetName [get_nets -of [get_pins -of [get_nets -seg $netName] -filter {IS_LEAF && DIRECTION == OUT}]]
    return $drvNetName
};

# -------------------------------------------------------------------------------
# findFile
# -------------------------------------------------------------------------------
# This function find target file
# -------------------------------------------------------------------------------
proc findFile {dir pattern} {
    set result [exec find $dir -type f -name $pattern]
    return $result
};