# Vivado Resource Utilization Report Extractor

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Vivado](https://img.shields.io/badge/Vivado-2024.2+-blue.svg)](https://www.xilinx.com/products/design-tools/vivado.html)

A comprehensive TCL script for automatically extracting resource utilization, power, and timing reports from Xilinx Vivado projects. This tool generates detailed reports and a CSV summary for easy analysis and comparison across different implementations.

## Features

- **Automatic Checkpoint Detection**: Automatically finds and opens synthesis or implementation checkpoint files (.dcp)
- **Comprehensive Report Generation**: Extracts all major resource utilization reports including:
  - Resource utilization (LUTs, Registers, BRAM, DSPs)
  - Power analysis (Total, Dynamic, Static)
  - Timing analysis (WNS, TNS, Failing Endpoints)
  - Clock utilization and networks
  - Design rule checks (DRC)
  - Methodology checks
  - IO reports
  - Control sets
  - RAM utilization
  - High fanout nets
  - Route status
  - Design analysis
- **CSV Summary Generation**: Automatically parses reports and extracts key metrics into a CSV file for easy data analysis
- **Timestamped Output**: Each run creates a timestamped directory to track design iterations
- **Robust Error Handling**: Gracefully handles missing reports and provides detailed debug output

## Requirements

- Xilinx Vivado (tested with 2024.2+)
- A Vivado project with completed synthesis and/or implementation runs
- TCL environment (included with Vivado)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/tanvir-jewel/vivado-report-extractor.git
   cd vivado-report-extractor
   ```

2. Or download the `extract_vivado_reports.tcl` file directly to your project directory.

## Configuration

Before running the script, configure the output directory path at the top of `extract_vivado_reports.tcl`:

```tcl
################################################################################
# CONFIGURATION - Change this path to your desired report directory
################################################################################
set base_report_dir "C:/Users/YourUsername/vivado-reports"
```

**Note**: Use forward slashes (`/`) for paths, even on Windows.

## Usage

### Method 1: From Vivado TCL Console

1. Open your Vivado project
2. In the TCL Console, source the script:
   ```tcl
   source {C:/path/to/extract_vivado_reports.tcl}
   ```

### Method 2: From Command Line

Run Vivado in TCL mode with your project:
```bash
vivado -mode tcl -source extract_vivado_reports.tcl your_project.xpr
```

### Method 3: Auto-detect Project

If the script is in your project directory with a single `.xpr` file:
```bash
cd your_project_directory
vivado -mode tcl -source extract_vivado_reports.tcl
```

## Output Structure

The script creates a timestamped directory with all reports:

```
vivado-reports/
└── reports_20251119_143022/
    ├── post_impl_utilization.rpt
    ├── post_impl_utilization_hierarchical.rpt
    ├── post_impl_power.rpt
    ├── post_impl_power_hierarchical.rpt
    ├── post_impl_timing_summary.rpt
    ├── post_impl_timing_detailed.rpt
    ├── post_impl_clock_utilization.rpt
    ├── post_impl_clock_networks.rpt
    ├── post_impl_route_status.rpt
    ├── post_impl_drc.rpt
    ├── post_impl_methodology.rpt
    ├── post_impl_io.rpt
    ├── post_impl_control_sets.rpt
    ├── post_impl_ram_utilization.rpt
    ├── post_impl_high_fanout_nets.rpt
    ├── post_impl_design_analysis.rpt
    ├── post_impl_datasheet.rpt
    └── resource_summary.csv
```

## CSV Summary Format

The `resource_summary.csv` file contains extracted metrics in an easy-to-parse format:

```csv
Metric,Value
Project,my_project
Timestamp,20251119_143022
Stage,Implementation
LUTs Used,5234
LUTs Available,20800
LUTs Percentage,25.16
Registers Used,3421
Registers Available,41600
Registers Percentage,8.22
BRAM Used,12
BRAM Available,50
BRAM Percentage,24.00
DSPs Used,8
DSPs Available,90
DSPs Percentage,8.89
Total Power (W),0.153
Dynamic Power (W),0.081
Static Power (W),0.072
WNS (ns),2.5
TNS (ns),0.0
Failing Endpoints,0
```

## How It Works

1. **Project Detection**: Opens the specified Vivado project or auto-detects `.xpr` files
2. **Checkpoint Loading**: Searches for and opens implementation or synthesis checkpoint files
3. **Report Generation**: Runs Vivado report commands for all resource categories
4. **Data Extraction**: Parses generated reports using regex patterns
5. **CSV Creation**: Writes extracted metrics to a CSV file for analysis

## Troubleshooting

### "No checkpoint files found"
- Ensure synthesis or implementation has been run successfully
- Check that `.dcp` files exist in `<project>.runs/impl_1/` or `<project>.runs/synth_1/`

### "Could not generate report"
- Verify that a design is loaded (checkpoint opened successfully)
- Check Vivado version compatibility

### CSV file shows "0 KB"
- If the file size is less than 1 KB, it displays as "0 KB" due to integer rounding
- Check the actual file contents - it likely contains data

### Path with spaces issues
- Always wrap paths in curly braces or quotes: `source {C:/path with spaces/script.tcl}`
- Use forward slashes (`/`) instead of backslashes (`\`)

## Example Workflow

```tcl
# 1. Open Vivado with your project
vivado my_design.xpr

# 2. Source the script from TCL console
source {/path/to/extract_vivado_reports.tcl}

# 3. Reports are generated automatically
# 4. Check the output directory for all reports and CSV summary
```

## Use Cases

- **Design Iteration Tracking**: Compare resource usage across different design versions
- **Optimization Analysis**: Track improvements after design optimizations
- **Batch Processing**: Extract metrics from multiple projects for comparative analysis
- **Documentation**: Generate comprehensive implementation reports for documentation
- **CI/CD Integration**: Automate report generation in continuous integration pipelines

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Tanvir Hossain** ([@tanvir-jewel](https://github.com/tanvir-jewel))

## Acknowledgments

- Developed for FPGA design analysis and optimization workflows
- Tested with Xilinx Vivado 2024.2+
- Supports all 7-series and UltraScale devices

## Support

If you encounter any issues or have questions, please open an issue on GitHub.

---

**Star this repository if you find it useful!** ⭐
