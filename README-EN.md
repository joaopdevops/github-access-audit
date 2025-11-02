# GitHub Access Audit Automation

## 🎯 Objective
Automation script for auditing access to GitHub repositories, useful for managing former employee access and maintaining company repository security.

## 🛠️ Technologies Used
- Shell Script (Bash)
- GitHub API
- AWS EC2 (Ubuntu VM)
- SSH

## 📋 Prerequisites
- AWS account with EC2 access
- GitHub Token with appropriate permissions
- Configured SSH key
- Ubuntu (local or VM)

## 🚀 Step by Step

### 1. Environment Setup

#### 1.1 Connecting to VM via SSH
```bash
# SSH connection command example (replace with your data)
ssh -i "your-key-address.pem" ubuntu@public-ip-xx-xx-xx-xx.
```

#### 1.2 GitHub Token Configuration
```bash
# Export token as environment variable
export GITHUB_TOKEN="your-token-here"
```

### 2. Cloning the Repository
```bash
# Clone the repository with the automation script
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

### 3. Running the Audit Script
```bash
# Grant execution permission to the script
chmod +x audit-access.sh

# Run the script
./audit-access.sh
```

### 4. Interpreting the Results
The script will generate a report with:
- List of users with repository access
- Permission level for each user
- Last access date
- Account status (active/inactive)

## 📊 Output Example
```
Repository: company/important-project
Last Audit: 2025-11-01

Users with access:
1. john_doe (Admin)
   - Last access: 2025-10-30
   - Status: Active

2. ex_employee (Write)
   - Last access: 2025-09-15
   - Status: Inactive
   ⚠️ ATTENTION: Inactive user with repository access
```

## 🔒 Security Best Practices
- Always revoke access immediately after an employee leaves
- Perform regular audits (recommended: monthly)
- Keep logs of permission changes
- Use tokens with minimum necessary permissions

## 🤝 Contributing
Feel free to contribute with improvements! Open an issue or submit a pull request.



---
