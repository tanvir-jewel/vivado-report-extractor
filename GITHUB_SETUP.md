# GitHub Repository Setup Guide

Follow these steps to push this project to GitHub.

## Prerequisites

- Git installed on your system
- GitHub account (username: tanvir-jewel)
- GitHub repository created (or follow Step 1 to create one)

## Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com)
2. Click the "+" icon in the top-right corner → "New repository"
3. Fill in the details:
   - **Repository name**: `vivado-report-extractor`
   - **Description**: "Automated resource utilization report extraction for Xilinx Vivado projects"
   - **Public** or **Private** (your choice)
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)
4. Click "Create repository"

## Step 2: Initialize Local Repository

Open Git Bash or terminal and navigate to the project directory:

```bash
cd "C:/KU/OneDrive - University of Kansas/KU-Research/Side-Channel/CW-explainer/chaotic-sca-analysis/vivado-report-extractor"
```

Initialize git repository:

```bash
git init
```

## Step 3: Add Files

Add all files to git:

```bash
git add .
```

Check what files will be committed:

```bash
git status
```

## Step 4: Create Initial Commit

```bash
git commit -m "Initial commit: Vivado report extractor with comprehensive documentation"
```

## Step 5: Connect to GitHub Repository

Replace `tanvir-jewel` with your GitHub username if different:

```bash
git remote add origin https://github.com/tanvir-jewel/vivado-report-extractor.git
```

## Step 6: Push to GitHub

```bash
git branch -M main
git push -u origin main
```

If prompted for credentials:
- **Username**: tanvir-jewel
- **Password**: Use a [Personal Access Token](https://github.com/settings/tokens) instead of your password

## Step 7: Verify Upload

1. Go to `https://github.com/tanvir-jewel/vivado-report-extractor`
2. Verify all files are present:
   - README.md
   - extract_vivado_reports.tcl
   - LICENSE
   - EXAMPLE_USAGE.md
   - .gitignore

## Step 8: Add Repository Topics (Optional)

On your GitHub repository page:
1. Click "⚙️ Settings" (or the gear icon near "About")
2. Add topics: `vivado`, `xilinx`, `fpga`, `tcl`, `automation`, `report-generation`, `resource-utilization`

## Step 9: Create a Release (Optional)

1. Go to "Releases" on your repository page
2. Click "Create a new release"
3. Tag version: `v1.0.0`
4. Release title: `v1.0.0 - Initial Release`
5. Description:
   ```
   Initial release of Vivado Report Extractor

   Features:
   - Automatic checkpoint detection
   - Comprehensive report generation (utilization, power, timing)
   - CSV summary export
   - Timestamped outputs
   - Detailed debug logging

   Tested with Vivado 2024.2+
   ```
6. Click "Publish release"

## Updating the Repository Later

When you make changes to the script:

```bash
# Navigate to repository directory
cd "C:/KU/OneDrive - University of Kansas/KU-Research/Side-Channel/CW-explainer/chaotic-sca-analysis/vivado-report-extractor"

# Check what changed
git status

# Add changed files
git add extract_vivado_reports.tcl
# or add all changes: git add .

# Commit with descriptive message
git commit -m "Fix: Improved CSV parsing for timing metrics"

# Push to GitHub
git push
```

## Common Git Commands

```bash
# Check status
git status

# View commit history
git log --oneline

# Create a new branch
git checkout -b feature/new-feature

# Switch branches
git checkout main

# Pull latest changes
git pull

# View remote URL
git remote -v

# Undo last commit (keep changes)
git reset --soft HEAD~1
```

## SSH Setup (Recommended for easier authentication)

1. Generate SSH key:
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. Add to SSH agent:
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

3. Copy public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

4. Add to GitHub:
   - Go to GitHub Settings → SSH and GPG keys
   - Click "New SSH key"
   - Paste the public key

5. Update remote URL:
   ```bash
   git remote set-url origin git@github.com:tanvir-jewel/vivado-report-extractor.git
   ```

## Troubleshooting

### Authentication Failed
- Use Personal Access Token instead of password
- Or set up SSH authentication (recommended)

### Large Files
- Vivado checkpoint files (.dcp) are already in .gitignore
- Don't commit large binary files to git

### Merge Conflicts
- Pull before pushing: `git pull`
- Resolve conflicts manually if they occur
- Then commit and push

## Resources

- [GitHub Docs](https://docs.github.com)
- [Git Basics](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics)
- [Personal Access Tokens](https://github.com/settings/tokens)

---

**Need help?** Open an issue on the repository or consult the Git documentation.
