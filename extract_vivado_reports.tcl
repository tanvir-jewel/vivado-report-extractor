################################################################################
# Vivado Resource Utilization Report Extraction Script
# Usage: vivado -mode tcl -source extract_vivado_reports.tcl
# Or from Vivado TCL console: source extract_vivado_reports.tcl
################################################################################

################################################################################
# CONFIGURATION - Change this path to your desired report directory
################################################################################
set base_report_dir "C:/Users/t177h608/SCA_01/vivado-reports"

# Create timestamped subdirectory for this run
set timestamp [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
set report_subdir "${base_report_dir}/reports_${timestamp}"

# Create report directory
file mkdir $report_subdir
puts "Creating report directory: $report_subdir"

################################################################################
# Helper function to safely generate reports
################################################################################
proc safe_report {report_name options report_file} {
    # Build the command with properly quoted file path
    # Use -file option with the file path as a list element to handle spaces
    set cmd [list $report_name]

    # Add any additional options
    if {$options ne ""} {
        set cmd [concat $cmd $options]
    }

    # Add -file option with properly quoted path
    lappend cmd "-file"
    lappend cmd $report_file

    if {[catch {eval $cmd} result]} {
        puts "WARNING: Could not generate $report_file - $result"
        return 0
    } else {
        puts "Generated: $report_file"
        return 1
    }
}

################################################################################
# Check if project is open
################################################################################
set project_open 0
if {[catch {current_project} proj_name]} {
    puts "No project currently open. Attempting to open project..."
    puts "Please specify project file (.xpr) or open it manually before running this script."
    puts "Usage: vivado -mode tcl -source extract_vivado_reports.tcl <project.xpr>"

    # Try to open project from command line argument
    if {$argc > 0} {
        set project_file [lindex $argv 0]
        if {[file exists $project_file]} {
            open_project $project_file
            set project_open 1
            set proj_name [current_project]
        } else {
            puts "ERROR: Project file not found: $project_file"
            return
        }
    } else {
        # Search for .xpr files in current directory
        set xpr_files [glob -nocomplain "*.xpr"]
        if {[llength $xpr_files] == 1} {
            open_project [lindex $xpr_files 0]
            set project_open 1
            set proj_name [current_project]
        } elseif {[llength $xpr_files] > 1} {
            puts "Multiple .xpr files found. Please specify which one to use:"
            foreach xpr $xpr_files {
                puts "  - $xpr"
            }
            return
        } else {
            puts "ERROR: No .xpr files found in current directory."
            return
        }
    }
} else {
    set project_open 1
}

puts "================================================"
puts "Project: $proj_name"
puts "Report Directory: $report_subdir"
puts "================================================"

################################################################################
# Find and open checkpoint files
################################################################################
set has_synth 0
set has_impl 0
set design_loaded 0

# Check if a design is already open
if {[catch {get_cells} result] == 0} {
    set design_loaded 1
    puts "Design already loaded in memory."
}

# If no design is loaded, try to open checkpoint files
if {!$design_loaded} {
    puts "No design loaded. Searching for checkpoint files..."

    # Get project directory
    set proj_dir [get_property DIRECTORY [current_project]]

    # Look for implementation checkpoint (preferred)
    set impl_dcp_paths [list \
        "${proj_dir}/${proj_name}.runs/impl_1/*_routed.dcp" \
        "${proj_dir}/${proj_name}.runs/impl_1/*_placed.dcp" \
        "${proj_dir}/${proj_name}.runs/impl_1/*.dcp" \
    ]

    foreach dcp_pattern $impl_dcp_paths {
        set dcp_files [glob -nocomplain $dcp_pattern]
        if {[llength $dcp_files] > 0} {
            set dcp_file [lindex $dcp_files 0]
            puts "Found implementation checkpoint: $dcp_file"
            puts "Opening checkpoint..."
            open_checkpoint $dcp_file
            set design_loaded 1
            set has_impl 1
            break
        }
    }

    # If no implementation checkpoint, look for synthesis checkpoint
    if {!$design_loaded} {
        set synth_dcp_paths [list \
            "${proj_dir}/${proj_name}.runs/synth_1/*.dcp" \
        ]

        foreach dcp_pattern $synth_dcp_paths {
            set dcp_files [glob -nocomplain $dcp_pattern]
            if {[llength $dcp_files] > 0} {
                set dcp_file [lindex $dcp_files 0]
                puts "Found synthesis checkpoint: $dcp_file"
                puts "Opening checkpoint..."
                open_checkpoint $dcp_file
                set design_loaded 1
                set has_synth 1
                break
            }
        }
    }

    if {!$design_loaded} {
        puts "\nERROR: No checkpoint files found!"
        puts "Please ensure synthesis and/or implementation has completed."
        puts "\nSearched in: ${proj_dir}/${proj_name}.runs/"
        puts "  - impl_1/*.dcp"
        puts "  - synth_1/*.dcp"
        puts "\nYou can also:"
        puts "  1. Run synthesis: launch_runs synth_1"
        puts "  2. Run implementation: launch_runs impl_1"
        puts "  3. Or manually open a checkpoint: open_checkpoint <path_to_dcp>"
        return
    }
}

################################################################################
# Check design state
################################################################################
# Determine what stage we have
if {!$has_impl} {
    # Check if this is post-implementation
    if {[catch {get_timing_paths} result] == 0} {
        set has_impl 1
        puts "Implementation design detected."
    } else {
        set has_synth 1
        puts "Synthesis design detected."
    }
}

################################################################################
# POST-SYNTHESIS REPORTS
################################################################################
if {$has_synth} {
    puts "\n========== Generating Post-Synthesis Reports =========="

    # Utilization Report (detailed)
    safe_report "report_utilization" "" "${report_subdir}/post_synth_utilization.rpt"

    # Utilization Report (hierarchical)
    safe_report "report_utilization" "-hierarchical" "${report_subdir}/post_synth_utilization_hierarchical.rpt"

    # Clock Utilization
    safe_report "report_clock_utilization" "" "${report_subdir}/post_synth_clock_utilization.rpt"

    # High Fanout Nets
    safe_report "report_high_fanout_nets" "" "${report_subdir}/post_synth_high_fanout_nets.rpt"

    # DRC (Design Rule Check)
    safe_report "report_drc" "" "${report_subdir}/post_synth_drc.rpt"
}

################################################################################
# POST-IMPLEMENTATION REPORTS
################################################################################
if {$has_impl} {
    puts "\n========== Generating Post-Implementation Reports =========="

    # Utilization Report (detailed)
    safe_report "report_utilization" "" "${report_subdir}/post_impl_utilization.rpt"

    # Utilization Report (hierarchical)
    safe_report "report_utilization" "-hierarchical" "${report_subdir}/post_impl_utilization_hierarchical.rpt"

    # Timing Summary
    safe_report "report_timing_summary" "" "${report_subdir}/post_impl_timing_summary.rpt"

    # Detailed Timing (worst paths)
    safe_report "report_timing" "-max_paths 100 -nworst 1 -sort_by slack" "${report_subdir}/post_impl_timing_detailed.rpt"

    # Clock Utilization
    safe_report "report_clock_utilization" "" "${report_subdir}/post_impl_clock_utilization.rpt"

    # Clock Networks
    safe_report "report_clock_networks" "" "${report_subdir}/post_impl_clock_networks.rpt"

    # Power Report
    safe_report "report_power" "" "${report_subdir}/post_impl_power.rpt"

    # Power Report (detailed)
    safe_report "report_power" "-hier all" "${report_subdir}/post_impl_power_hierarchical.rpt"

    # Route Status
    safe_report "report_route_status" "" "${report_subdir}/post_impl_route_status.rpt"

    # DRC (Design Rule Check)
    safe_report "report_drc" "" "${report_subdir}/post_impl_drc.rpt"

    # Methodology Check
    safe_report "report_methodology" "" "${report_subdir}/post_impl_methodology.rpt"

    # IO Report
    safe_report "report_io" "" "${report_subdir}/post_impl_io.rpt"

    # Control Sets
    safe_report "report_control_sets" "" "${report_subdir}/post_impl_control_sets.rpt"

    # RAM Utilization
    safe_report "report_ram_utilization" "" "${report_subdir}/post_impl_ram_utilization.rpt"

    # High Fanout Nets
    safe_report "report_high_fanout_nets" "" "${report_subdir}/post_impl_high_fanout_nets.rpt"

    # Design Analysis
    safe_report "report_design_analysis" "" "${report_subdir}/post_impl_design_analysis.rpt"

    # Datasheet (for final timing and power characteristics)
    safe_report "report_datasheet" "" "${report_subdir}/post_impl_datasheet.rpt"
}

puts "\nDEBUG: About to start CSV generation..."

################################################################################
# GENERATE CSV SUMMARY FOR EASY PARSING
################################################################################
puts "\n========== Generating CSV Summary =========="

set csv_file "${report_subdir}/resource_summary.csv"
puts "Opening CSV file: $csv_file"

if {[catch {open $csv_file w} fp]} {
    puts "ERROR: Could not open CSV file: $fp"
    return
}

puts "Writing CSV header..."
puts $fp "Metric,Value"
puts $fp "Project,$proj_name"
puts $fp "Timestamp,$timestamp"
flush $fp
puts "CSV header written successfully"

# Extract key metrics from utilization report if available
puts "Checking for utilization reports..."
set impl_util_exists [file exists "${report_subdir}/post_impl_utilization.rpt"]
set synth_util_exists [file exists "${report_subdir}/post_synth_utilization.rpt"]
puts "  post_impl_utilization.rpt exists: $impl_util_exists"
puts "  post_synth_utilization.rpt exists: $synth_util_exists"

if {$impl_util_exists || $synth_util_exists} {
    puts "At least one utilization report found, proceeding..."

    # Determine which report to use
    if {[file exists "${report_subdir}/post_impl_utilization.rpt"]} {
        set util_file "${report_subdir}/post_impl_utilization.rpt"
        set stage "Implementation"
    } else {
        set util_file "${report_subdir}/post_synth_utilization.rpt"
        set stage "Synthesis"
    }

    puts $fp "Stage,$stage"
    flush $fp

    # Parse utilization report
    puts "Parsing utilization report: $util_file"
    if {[catch {
        set util_fp [open $util_file r]
        set util_content [read $util_fp]
        close $util_fp
    } err]} {
        puts "WARNING: Could not read utilization file: $err"
    } else {
        puts "Successfully read utilization report ([string length $util_content] bytes)"

        # Extract metrics using regex patterns with more flexible matching
        # Match Slice LUTs
        if {[regexp {Slice LUTs[^\|]*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*([\d.]+)} $util_content match luts total lut_pct]} {
            puts "  Found LUTs: $luts / $total ($lut_pct%)"
            puts $fp "LUTs Used,$luts"
            puts $fp "LUTs Available,$total"
            puts $fp "LUTs Percentage,$lut_pct"
        } else {
            puts "  WARNING: Could not extract LUT information"
        }

        # Match Slice Registers
        if {[regexp {Slice Registers[^\|]*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*([\d.]+)} $util_content match regs total reg_pct]} {
            puts "  Found Registers: $regs / $total ($reg_pct%)"
            puts $fp "Registers Used,$regs"
            puts $fp "Registers Available,$total"
            puts $fp "Registers Percentage,$reg_pct"
        } else {
            puts "  WARNING: Could not extract Register information"
        }

        # Match Block RAM Tile
        if {[regexp {Block RAM Tile[^\|]*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*([\d.]+)} $util_content match bram total bram_pct]} {
            puts "  Found BRAM: $bram / $total ($bram_pct%)"
            puts $fp "BRAM Used,$bram"
            puts $fp "BRAM Available,$total"
            puts $fp "BRAM Percentage,$bram_pct"
        } else {
            puts "  WARNING: Could not extract BRAM information"
        }

        # Match DSPs
        if {[regexp {DSPs[^\|]*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*([\d.]+)} $util_content match dsp total dsp_pct]} {
            puts "  Found DSPs: $dsp / $total ($dsp_pct%)"
            puts $fp "DSPs Used,$dsp"
            puts $fp "DSPs Available,$total"
            puts $fp "DSPs Percentage,$dsp_pct"
        } else {
            puts "  WARNING: Could not extract DSP information"
        }

        # Match F7 Muxes
        if {[regexp {F7 Muxes[^\|]*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*([\d.]+)} $util_content match f7 total f7_pct]} {
            puts $fp "F7 Muxes Used,$f7"
        }

        # Match F8 Muxes
        if {[regexp {F8 Muxes[^\|]*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*([\d.]+)} $util_content match f8 total f8_pct]} {
            puts $fp "F8 Muxes Used,$f8"
        }

        flush $fp
    }
}

# Extract power metrics if available
if {[file exists "${report_subdir}/post_impl_power.rpt"]} {
    puts "Parsing power report..."
    if {[catch {
        set power_fp [open "${report_subdir}/post_impl_power.rpt" r]
        set power_content [read $power_fp]
        close $power_fp
    } err]} {
        puts "WARNING: Could not read power file: $err"
    } else {
        puts "Successfully read power report ([string length $power_content] bytes)"
        # More flexible regex for power extraction
        if {[regexp {Total On-Chip Power \(W\)[^\|]*\|\s*([\d.]+)} $power_content match total_power]} {
            puts "  Found Total Power: $total_power W"
            puts $fp "Total Power (W),$total_power"
        }

        if {[regexp {Dynamic \(W\)[^\|]*\|\s*([\d.]+)} $power_content match dynamic_power]} {
            puts "  Found Dynamic Power: $dynamic_power W"
            puts $fp "Dynamic Power (W),$dynamic_power"
        }

        if {[regexp {Device Static \(W\)[^\|]*\|\s*([\d.]+)} $power_content match static_power]} {
            puts "  Found Static Power: $static_power W"
            puts $fp "Static Power (W),$static_power"
        }
        flush $fp
    }
}

# Extract timing metrics if available
if {[file exists "${report_subdir}/post_impl_timing_summary.rpt"]} {
    puts "Parsing timing summary report..."
    if {[catch {
        set timing_fp [open "${report_subdir}/post_impl_timing_summary.rpt" r]
        set timing_content [read $timing_fp]
        close $timing_fp
    } err]} {
        puts "WARNING: Could not read timing file: $err"
    } else {
        puts "Successfully read timing report ([string length $timing_content] bytes)"
        # Extract WNS (Worst Negative Slack)
        if {[regexp {WNS\(ns\)[^\|]*\|\s*([-\d.]+)} $timing_content match wns]} {
            puts "  Found WNS: $wns ns"
            puts $fp "WNS (ns),$wns"
        }

        # Extract TNS (Total Negative Slack)
        if {[regexp {TNS\(ns\)[^\|]*\|\s*([-\d.]+)} $timing_content match tns]} {
            puts "  Found TNS: $tns ns"
            puts $fp "TNS (ns),$tns"
        }

        # Extract Number of Failing Endpoints
        if {[regexp {Failing Endpoints[^\|]*\|\s*(\d+)} $timing_content match failing]} {
            puts "  Found Failing Endpoints: $failing"
            puts $fp "Failing Endpoints,$failing"
        }
        flush $fp
    }
}

puts "Closing CSV file..."
close $fp
puts "Generated: $csv_file"
puts "CSV file size: [file size $csv_file] bytes"

################################################################################
# COMPLETION MESSAGE
################################################################################
puts "\n================================================"
puts "Report extraction complete!"
puts "All reports saved to: $report_subdir"
puts "================================================"
puts "\nGenerated reports:"
foreach report_file [glob -nocomplain "${report_subdir}/*"] {
    set file_size [file size $report_file]
    puts "  [file tail $report_file] ([expr {$file_size / 1024}] KB)"
}
puts "\n"
