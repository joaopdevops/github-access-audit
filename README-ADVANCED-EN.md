# 🔍 GitHub Access Audit - Advanced Audit Script

## 📋 Table of Contents
- [About the Project](#about-the-project)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [How to Use](#how-to-use)
- [Generated Reports](#generated-reports)
- [Automation with Cron](#automation-with-cron)
- [Troubleshooting](#troubleshooting)

---

## 🎯 About the Project

This script performs **automatic access auditing** on GitHub repositories, generating detailed reports about:
- 👥 Users with repository access
- 🔑 Permission levels (admin, write, read)
- ⏱️ Real last activity (via commits and events)
- 📅 Days of inactivity
- 🔐 2FA status (when available)
- ⚠️ Smart security alerts
- 📊 Detailed statistics and metrics
- 🔒 Complete audit trail
- 🔐 SHA256 hash for integrity

### Why use it?
- **Security**: Identifies unauthorized access, inactive admins, or empty repositories
- **Compliance**: Maintains audit history with complete trail
- **Automation**: Saves time on repetitive tasks
- **Visibility**: Reports in multiple formats (LOG, CSV, HTML, JSON)
- **Integrity**: SHA256 hash ensures reports haven't been tampered
- **Privacy**: Masked IP in public reports

### ✨ Advanced Features (v2.0.0)

#### 🔍 Real Inactivity Detection
- Searches last activity via Events API (last 90 days)
- Falls back to Commits API (complete history)
- Calculates real days of inactivity
- Detects empty repositories

#### 🚨 Smart Alert System
- **CRITICAL**: Admin inactive for 180+ days
- **HIGH**: Admin inactive 90+ days or user inactive 180+ days
- **MEDIUM**: User inactive for 90+ days
- **WATCH**: Active admin (continuous monitoring)
- **LOW**: Normal active user

#### 📋 Complete Audit Trail
- Who executed the audit
- When it was executed (date/time/timezone)
- Where it was executed (hostname, IP, directory)
- How it was executed (shell, PID, script version)
- SHA256 hash of report (integrity)
- Persistent log of all actions

#### 🔒 Security and Privacy
- Masked IP in console and HTML (e.g., `192.168.xxx.xxx`)
- Real IP stored only in trail log (forensic use)
- SHA256 hash to validate report integrity
- Empty repository detection with alerts

#### 📊 Multiple Report Formats
- **LOG**: Colored terminal visualization
- **CSV**: Import to Excel/Google Sheets
- **HTML**: Visual report with colors by criticality
- **JSON**: Structured data for future comparisons
- **Trail Log**: Complete audit history

---

## 📦 Prerequisites

Before starting, you need to have installed:

### 1. Operating System
- Linux (Ubuntu, Debian, CentOS, etc.)
- macOS
- Windows with WSL2

### 2. Required tools
```bash
# Git (to clone the repository)
git --version

# curl (to make API calls)
curl --version

# jq (to process JSON)
jq --version
```

### 3. Install tools (if needed)

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y git curl jq
```

**CentOS/RHEL:**
```bash
sudo yum install -y git curl jq
```

**macOS:**
```bash
brew install git curl jq
```

---

## 🚀 Installation

### Step 1: Clone the repository
```bash
# Clone the project
git clone https://github.com/your-username/github-access-audit.git

# Enter the directory
cd github-access-audit
```

### Step 2: Grant execution permission
```bash
chmod +x audit-access-advanced.sh
```

---

## ⚙️ Configuration

### Step 1: Create a GitHub Token

1. Access: https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Configure the token:
   - **Name**: `github-audit-token`
   - **Expiration**: Choose according to need (recommended: 90 days)
   - **Required permissions**:
     - ✅ `repo` → **Full control of private repositories**
       - Needed to list collaborators and permissions
     - ✅ `read:org` → **Read org and team membership**
       - Required for auditing organization repositories
     - ⚠️ `read:user` → Optional for extra user info

#### 🔐 Minimum Required Permissions

For maximum security, use only necessary permissions:

| Permission | Required? | Reason |
|-----------|-----------|--------|
| `repo` | ✅ **Yes** | List collaborators and permissions |
| `read:org` | ✅ **Yes** | Audit organization repos |
| `read:user` | ⚠️ Optional | Extra user information |
| `admin:org` | ❌ No | Too privileged - avoid |
| `delete_repo` | ❌ No | Script doesn't delete anything |

#### ⚠️ Important about Permissions

- **Personal Repositories**: Only `repo` is sufficient
- **Organizations**: Needs `repo` + `read:org`
- **2FA Status**: Requires Enterprise API (not available on free accounts)
- **Last Activity**: Uses Events API (last 90 days) + Commits API (complete history)
4. Click **"Generate token"**
5. **IMPORTANT**: Copy the token (you won't see it again!)

### Step 2: Configure the Token as environment variable

```bash
# Export the token (replace with your actual token)
export GITHUB_TOKEN="ghp_your_token_here"

# Verify it was configured correctly
echo $GITHUB_TOKEN
```

**Tip**: To make it permanent, add to your `~/.bashrc` or `~/.zshrc`:
```bash
echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.bashrc
source ~/.bashrc
```

### Step 3: Configure repositories to audit

Edit the `audit-access-advanced.sh` file:

```bash
# Use nano (simpler)
nano audit-access-advanced.sh

# OR use vim (more advanced)
vim audit-access-advanced.sh
```

Look for the section (approximately line 240):
```bash
# List of repositories to audit
repos=(
    "your-company/your-repository"
)
```

Change to your repositories:
```bash
repos=(
    "your-company/project1"
    "your-company/project2"
    "your-username/personal-repository"
)
```

**Save and exit:**
- **nano**: `Ctrl + O` (save), `Enter`, `Ctrl + X` (exit)
- **vim**: `Esc`, type `:wq`, `Enter`

---

## 🎮 How to Use

### Basic Execution

```bash
# Run the script
./audit-access-advanced.sh
```

### Save output to separate file

```bash
# Redirect output to file
./audit-access-advanced.sh | tee manual_audit.log
```

### Run at specific time

```bash
# Run at 8am
echo "0 8 * * * cd /path/to/github-access-audit && ./audit-access-advanced.sh" | crontab -e
```

---

## 📊 Generated Reports

After execution, reports are saved in the `reports/` folder:

### 1. LOG File (.log)
- **Format**: Colored text
- **Use**: Quick terminal viewing
- **Example**: `reports/audit_20251102_083015.log`

```bash
# View LOG report
cat reports/audit_*.log | less -R
```

### 2. CSV File (.csv)
- **Format**: Spreadsheet
- **Use**: Import to Excel, Google Sheets, data analysis
- **Example**: `reports/audit_20251102_083015.csv`

```bash
# Open CSV in terminal
column -t -s, reports/audit_*.csv | less -S
```

### 3. HTML File (.html)
- **Format**: Responsive visual web page
- **Use**: Share with teams, presentations
- **Example**: `reports/audit_20251102_083015.html`
- **Features**: Colors by criticality, audit trail, masked IP

```bash
# Open in browser
xdg-open reports/audit_*.html  # Linux
open reports/audit_*.html      # macOS
```

### 4. JSON File (.json)
- **Format**: Structured data
- **Use**: Future comparisons, system integration
- **Example**: `reports/audit_20251102_083015.json`
- **Contains**: Complete audit metadata

### 5. Audit Trail (audit_trail.log)
- **Format**: Cumulative persistent log
- **Use**: Complete history, forensic investigations
- **Location**: `reports/audit_trail.log`
- **Contains**: All executions, actions, real IP, hashes

```bash
# View complete audit history
cat reports/audit_trail.log

# View today's audits only
grep "$(date +%Y-%m-%d)" reports/audit_trail.log

# Check hash of specific report
grep "REPORT_HASH" reports/audit_trail.log | tail -1
```

### Report Structure

Each report contains:

#### 📋 Audit Trail
- � Date/time with timezone
- 👤 Executing user
- 🖥️ Machine hostname
- 🌐 IP Address (masked in public, real in trail)
- 🔧 Shell used
- 📁 Execution directory
- 🆔 Process ID (PID)
- � Script version
- 🔒 Report SHA256 hash

#### 📦 Per Repository
- 👥 Complete collaborator list
- 🔑 Each user's permission (admin/write/read)
- 📅 Last activity (real date via API)
- ⏱️ Days inactive
- 🔐 2FA status (when available)
- ⚡ Alert level (CRITICAL/HIGH/MEDIUM/WATCH/LOW)
- 📊 Summary: total users, admins, critical alerts

#### 🚨 Automatic Alerts
- Admins inactive for more than 180 days
- Users inactive for more than 90 days
- Empty repositories with access
- Unused administrative permissions

---

## ⏰ Automation with Cron

### Configure weekly audit

```bash
# Edit crontab
crontab -e

# Add line to run every Monday at 8am
0 8 * * 1 cd /full/path/to/github-access-audit && /bin/bash ./audit-access-advanced.sh >> /var/log/github-audit.log 2>&1
```

### Cron scheduling examples

```bash
# Every Monday at 8am
0 8 * * 1 /path/to/script.sh

# Every day at 9am
0 9 * * * /path/to/script.sh

# First day of each month at 7am
0 7 1 * * /path/to/script.sh

# Every 6 hours
0 */6 * * * /path/to/script.sh
```

### Check if cron is working

```bash
# View scheduled tasks
crontab -l

# View cron logs
tail -f /var/log/syslog | grep CRON  # Ubuntu/Debian
tail -f /var/log/cron                # CentOS/RHEL
```

---

## 🔧 Troubleshooting

### Problem: "GITHUB_TOKEN not configured"

**Solution:**
```bash
export GITHUB_TOKEN="your-token-here"
```

---

### Problem: "command not found: jq"

**Solution:**
```bash
# Ubuntu/Debian
sudo apt install jq

# CentOS/RHEL
sudo yum install jq

# macOS
brew install jq
```

---

### Problem: "Permission denied"

**Solution:**
```bash
# Grant execution permission
chmod +x audit-access-advanced.sh
```

---

### Problem: 401 or 403 API error

**Possible causes:**
1. Invalid or expired token
2. Token without necessary permissions
3. Repository doesn't exist or you don't have access

**Solution:**
1. Check if token is correct:
```bash
echo $GITHUB_TOKEN
```

2. Test token manually:
```bash
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

3. Generate a new token with correct permissions

---

### Problem: "No collaborators found"

**Possible causes:**
1. Repository doesn't exist
2. Incorrect repository name
3. Token without read permission

**Solution:**
Verify repository name is correct in `username/repository` format

---

### Problem: Reports are not generated

**Solution:**
```bash
# Check if reports folder exists
ls -la reports/

# Create manually if needed
mkdir -p reports

# Check permissions
chmod 755 reports
```

---

## 📝 Alert Levels

The script classifies users into 5 levels based on inactivity and permissions:

| Level | Color | Description | Criteria | Recommended Action |
|-------|-------|-------------|----------|-------------------|
| 🔴 **CRITICAL** | Red | Critical inactive admin | Admin inactive 180+ days | ⚠️ **REVIEW IMMEDIATELY** - Remove access |
| 🟣 **HIGH** | Purple | High risk | Admin 90+ days OR user 180+ days | ⚠️ Review and consider urgent removal |
| 🟡 **MEDIUM** | Yellow | Moderate risk | User inactive 90+ days | 👀 Monitor and review soon |
| � **WATCH** | Blue | Monitoring | Active admin | 👁️ Keep under continuous observation |
| �🟢 **LOW** | Green | Normal | Active user | ✅ No action needed |

### 🚨 Special Alerts

The script also detects and alerts about:

- **📦 Empty Repositories**: Repos without commits but with admins
- **👤 External Users**: Collaborators from outside the organization (when detectable)
- **🔑 Administrative Permissions**: All admins are highlighted

### 💡 Alert Interpretation

**Output Example:**
```
👤 User: john-doe
   🔑 Permission: admin
   📅 Last activity: Never (empty repo)
   ⏱️  Days inactive: 999
   🔐 2FA: unknown
   ⚡ Level: CRITICAL
   🚨 CRITICAL: Admin inactive for more than 180 days!
   ℹ️  Repository without commits - consider removing access or archiving
```

**Interpretation:**
1. User has **admin** permission
2. **Never had activity** in the repository
3. **Repository is empty** (no commits)
4. **ACTION**: Remove access or archive the repository

---

## 🤝 Use Cases

### 1. Technology Company
- Weekly automatic audit
- Security team reviews reports
- Removes former employees with access

### 2. Compliance/Governance
- Audit history for external audits
- Demonstrates compliance with security policies
- Evidence for certifications (ISO 27001, SOC 2)

### 3. Access Management
- Identifies excessive permissions
- Reviews contractor/third-party access
- Maintains principle of least privilege

---

## 🔒 Security Best Practices

### 🔐 Token Management

1. **Never share your token** in code, messages, or public repositories
2. Use tokens with **minimum necessary permissions** (principle of least privilege)
3. **Rotate tokens** periodically (recommended: every 90 days)
4. Store tokens in **environment variables**, never in committed files
5. Use different tokens for **different environments** (dev, staging, prod)
6. **Revoke tokens** immediately if compromised or no longer needed
7. Configure **automatic expiration** on tokens (maximum 90 days)

### 📋 Audit Trail and Compliance

1. Keep **audit logs** for appropriate time (recommended: 1-2 years)
2. Use **SHA256 hash** to ensure report integrity
3. **Verify hashes** before using old reports:
   ```bash
   # Hash generated by script
   grep "REPORT_HASH" reports/audit_trail.log | tail -1
   
   # Verify manually
   sha256sum reports/audit_20251102_083015.log
   ```
4. Store reports in **secure location** with backup
5. **Review reports** regularly (weekly or monthly)

### 🌐 Privacy and Data Protection

1. **Masked IP** in public reports (HTML, visible LOG)
2. **Real IP** kept only in trail log (forensic/internal use)
3. Don't share reports with sensitive data externally
4. Use **encryption** when transmitting reports (HTTPS, SSH, VPN)

### 🚨 Incident Response

1. If you detect **unauthorized access**:
   - Remove access immediately
   - Revoke compromised tokens
   - Investigate using audit trail
   - Document the incident

2. For **critical inactive admins**:
   - Notify security team
   - Remove administrative permissions
   - Downgrade to read-only if necessary
   - Document the decision

3. For **empty repositories**:
   - Evaluate if still needed
   - Archive or delete if unused
   - Remove unnecessary access

### ✅ Security Checklist

- [ ] Token with minimum permissions configured
- [ ] Scheduled audit (cron) working
- [ ] Reports being reviewed regularly
- [ ] Audit trail being stored securely
- [ ] Process defined for CRITICAL alert response
- [ ] Hashes being verified before using old reports
- [ ] Report backups configured

---

## 📧 Support

- **Issues**: https://github.com/your-username/github-access-audit/issues
- **Documentation**: This README

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## ✨ Contributing

Contributions are welcome! Please:
1. Fork the project
2. Create a branch for your feature (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

---

