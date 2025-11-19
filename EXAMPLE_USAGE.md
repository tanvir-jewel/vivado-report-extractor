# Example Usage Guide

This guide provides step-by-step examples for using the Vivado Report Extractor.

## Quick Start Example

### Step 1: Configure Output Path

Edit `extract_vivado_reports.tcl` and set your desired output directory:

```tcl
set base_report_dir "C:/Users/YourUsername/vivado-reports"
```

### Step 2: Run the Script

**Option A: From Vivado GUI**

1. Open Vivado and load your project
2. Open TCL Console (Window → Tcl Console)
3. Run:
   ```tcl
   source {C:/path/to/extract_vivado_reports.tcl}
   ```

**Option B: From Command Line**

```bash
cd /path/to/your/vivado/project
vivado -mode tcl -source /path/to/extract_vivado_reports.tcl your_project.xpr
```

## Example Output

```
================================================
Project: my_aes_design
Report Directory: C:/Users/tanvir/vivado-reports/reports_20251119_143022
================================================

No design loaded. Searching for checkpoint files...
Found implementation checkpoint: .../impl_1/design_routed.dcp
Opening checkpoint...

========== Generating Post-Implementation Reports ==========
Generated: .../post_impl_utilization.rpt
Generated: .../post_impl_power.rpt
Generated: .../post_impl_timing_summary.rpt
...

========== Generating CSV Summary ==========
Parsing utilization report: .../post_impl_utilization.rpt
Successfully read utilization report (11234 bytes)
  Found LUTs: 5234 / 20800 (25.16%)
  Found Registers: 3421 / 41600 (8.22%)
  Found BRAM: 12 / 50 (24.00%)
  Found DSPs: 8 / 90 (8.89%)

Parsing power report...
  Found Total Power: 0.153 W
  Found Dynamic Power: 0.081 W
  Found Static Power: 0.072 W

Parsing timing summary report...
  Found WNS: 2.5 ns
  Found TNS: 0.0 ns
  Found Failing Endpoints: 0

CSV file size: 415 bytes

================================================
Report extraction complete!
All reports saved to: C:/Users/tanvir/vivado-reports/reports_20251119_143022
================================================
```

## Analyzing Results

### View CSV in Excel/Python

**Excel:**
1. Open Excel
2. File → Open → Select `resource_summary.csv`
3. Data will be automatically formatted

**Python:**
```python
import pandas as pd

# Read the CSV
df = pd.read_csv('resource_summary.csv')

# Display metrics
print(df)

# Extract specific values
luts_used = df[df['Metric'] == 'LUTs Used']['Value'].values[0]
power = df[df['Metric'] == 'Total Power (W)']['Value'].values[0]

print(f"Design uses {luts_used} LUTs and consumes {power}W")
```

### Compare Multiple Runs

```python
import pandas as pd
import glob

# Read all CSV files from different runs
csv_files = glob.glob('vivado-reports/*/resource_summary.csv')

data = []
for csv_file in csv_files:
    df = pd.read_csv(csv_file)
    # Extract timestamp from path
    timestamp = csv_file.split('/')[-2].replace('reports_', '')

    # Create summary dictionary
    summary = {'Timestamp': timestamp}
    for _, row in df.iterrows():
        summary[row['Metric']] = row['Value']
    data.append(summary)

# Create comparison dataframe
comparison_df = pd.DataFrame(data)
print(comparison_df[['Timestamp', 'LUTs Used', 'Total Power (W)', 'WNS (ns)']])
```

## Batch Processing Multiple Projects

Create a bash/batch script to process multiple projects:

```bash
#!/bin/bash

SCRIPT_PATH="/path/to/extract_vivado_reports.tcl"
PROJECTS=(
    "project1/project1.xpr"
    "project2/project2.xpr"
    "project3/project3.xpr"
)

for project in "${PROJECTS[@]}"; do
    echo "Processing $project..."
    vivado -mode tcl -source "$SCRIPT_PATH" "$project"
done

echo "All projects processed!"
```

## Integration with CI/CD

Example GitHub Actions workflow:

```yaml
name: Extract Vivado Reports

on: [push]

jobs:
  extract-reports:
    runs-on: self-hosted  # Requires Vivado installation

    steps:
    - uses: actions/checkout@v2

    - name: Run Vivado Report Extraction
      run: |
        vivado -mode tcl -source extract_vivado_reports.tcl my_project.xpr

    - name: Upload Reports
      uses: actions/upload-artifact@v2
      with:
        name: vivado-reports
        path: vivado-reports/
```

## Advanced: Custom Metrics Extraction

You can modify the script to extract additional metrics. Add this to the CSV generation section:

```tcl
# Extract custom metric from a report
if {[file exists "${report_subdir}/post_impl_utilization.rpt"]} {
    set util_fp [open "${report_subdir}/post_impl_utilization.rpt" r]
    set util_content [read $util_fp]
    close $util_fp

    # Extract BUFG resources
    if {[regexp {BUFG[^\|]*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*([\d.]+)} $util_content match bufg total pct]} {
        puts $fp "BUFG Used,$bufg"
        puts $fp "BUFG Percentage,$pct"
    }
}
```

## Troubleshooting Examples

### Issue: Script can't find project

**Solution:** Specify full path to .xpr file:
```tcl
vivado -mode tcl -source extract_vivado_reports.tcl "C:/Projects/my_design/my_design.xpr"
```

### Issue: No checkpoint files found

**Solution:** Run synthesis and implementation first:
```tcl
# In Vivado TCL console
launch_runs synth_1
wait_on_run synth_1
launch_runs impl_1
wait_on_run impl_1

# Now run the extraction script
source extract_vivado_reports.tcl
```

### Issue: Path contains spaces

**Solution:** Use curly braces:
```tcl
source {C:/My Projects/vivado-report-extractor/extract_vivado_reports.tcl}
```

## Tips and Best Practices

1. **Run after implementation**: Always ensure implementation is complete before extracting reports
2. **Automated workflows**: Integrate into your build scripts for consistent reporting
3. **Version control**: Keep reports in a separate directory (already in .gitignore)
4. **Compare iterations**: Use timestamps to track design improvements over time
5. **CSV for automation**: Use the CSV file for automated design space exploration

## Getting Help

If you encounter issues:
1. Check the debug output from the script
2. Verify your Vivado version is compatible
3. Open an issue on GitHub with:
   - Vivado version
   - Operating system
   - Error messages
   - Steps to reproduce
