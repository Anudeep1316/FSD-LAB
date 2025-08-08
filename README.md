# Push Any Folder to GitHub

A comprehensive bash script to easily push any folder to GitHub as a new repository.

## Features

- ✅ **Automatic Git initialization** - Initializes Git repo if not already done
- ✅ **GitHub CLI integration** - Uses GitHub CLI for seamless repo creation when available
- ✅ **Fallback support** - Works with manual repo creation and HTTPS/SSH authentication
- ✅ **Smart validation** - Checks for required tools and validates inputs
- ✅ **Error handling** - Comprehensive error messages and troubleshooting tips
- ✅ **Colorized output** - Clear, colored status messages for better UX
- ✅ **Flexible authentication** - Supports multiple authentication methods

## Prerequisites

### Required
- **Git** - Must be installed and configured
- **GitHub account** - You need a GitHub account

### Optional (but recommended)
- **GitHub CLI (gh)** - For automatic repository creation
  ```bash
  # Install GitHub CLI (Ubuntu/Debian)
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update && sudo apt install gh
  
  # Authenticate
  gh auth login
  ```

## Installation

1. **Download the script:**
   ```bash
   curl -O https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/push-to-github.sh
   ```

2. **Make it executable:**
   ```bash
   chmod +x push-to-github.sh
   ```

3. **Optional: Move to your PATH for global access:**
   ```bash
   sudo mv push-to-github.sh /usr/local/bin/push-to-github
   ```

## Usage

### Basic Syntax
```bash
./push-to-github.sh <folder_path> <repository_name> [github_username]
```

### Parameters
- `folder_path` - Path to the folder you want to push (relative or absolute)
- `repository_name` - Name for the new GitHub repository
- `github_username` - Your GitHub username (optional, will prompt if not provided)

### Examples

#### 1. Push current directory
```bash
./push-to-github.sh . my-awesome-project
```

#### 2. Push specific folder with username
```bash
./push-to-github.sh /path/to/my-project cool-repo myusername
```

#### 3. Push relative folder
```bash
./push-to-github.sh ../my-other-project another-repo
```

#### 4. Get help
```bash
./push-to-github.sh --help
```

## How It Works

1. **Validation** - Checks if folder exists and required tools are available
2. **Git Setup** - Initializes Git repository if needed
3. **File Preparation** - Adds all files and creates initial commit
4. **Repository Creation** - Creates repository on GitHub (automatically with GitHub CLI or manually)
5. **Remote Setup** - Adds GitHub remote and pushes code
6. **Success** - Provides repository URL and confirmation

## Authentication Methods

### Method 1: GitHub CLI (Recommended)
- **Pros**: Automatic repository creation, seamless authentication
- **Setup**: `gh auth login`
- **Usage**: Script handles everything automatically

### Method 2: Personal Access Token (HTTPS)
- **Pros**: Works without GitHub CLI
- **Setup**: Create token at https://github.com/settings/tokens
- **Usage**: 
  ```bash
  git remote set-url origin https://TOKEN@github.com/USERNAME/REPO.git
  ```

### Method 3: SSH Keys
- **Pros**: Secure, no token needed
- **Setup**: Configure SSH keys in GitHub settings
- **Usage**:
  ```bash
  git remote set-url origin git@github.com:USERNAME/REPO.git
  ```

## Troubleshooting

### Common Issues

#### "Permission denied" error
- **Cause**: Authentication failure
- **Solution**: Set up authentication (see methods above)

#### "Repository already exists"
- **Cause**: Repository name is taken
- **Solution**: Choose a different repository name

#### "Git not found"
- **Cause**: Git is not installed
- **Solution**: Install Git
  ```bash
  sudo apt update && sudo apt install git
  ```

#### "Empty folder" warning
- **Cause**: Folder has no files
- **Solution**: Script automatically creates README.md

### Getting Help

If you encounter issues:

1. **Check prerequisites** - Ensure Git is installed and configured
2. **Verify authentication** - Make sure you can authenticate with GitHub
3. **Check permissions** - Ensure script has execute permissions
4. **Review error messages** - Script provides detailed error information

## Advanced Usage

### Custom Git Configuration
```bash
# Set up Git if not configured
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Using with Different Branches
The script uses `main` as the default branch. To use a different branch:
```bash
# After running the script, you can rename the branch
git branch -M your-preferred-branch-name
git push -u origin your-preferred-branch-name
```

### Batch Processing Multiple Folders
```bash
# Example: Push multiple projects
for folder in project1 project2 project3; do
    ./push-to-github.sh "$folder" "$folder-repo" yourusername
done
```

## Script Features Detail

### Error Handling
- Validates all inputs before proceeding
- Checks for required tools and dependencies
- Provides clear error messages with solutions
- Safely exits on any critical error

### Smart Defaults
- Attempts to get username from Git config
- Creates README.md for empty folders
- Uses `main` branch by default
- Handles existing Git repositories gracefully

### User Experience
- Colorized output for better readability
- Progress indicators for each step
- Helpful prompts and confirmations
- Comprehensive help documentation

## Contributing

Feel free to submit issues and enhancement requests!

## License

This script is provided as-is under the MIT License.