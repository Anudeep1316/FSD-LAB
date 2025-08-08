#!/bin/bash

# Script to push any folder to GitHub as a new repository
# Usage: ./push-to-github.sh <folder_path> <repository_name> [github_username]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <folder_path> <repository_name> [github_username]"
    echo ""
    echo "Arguments:"
    echo "  folder_path      - Path to the folder you want to push to GitHub"
    echo "  repository_name  - Name for the new GitHub repository"
    echo "  github_username  - Your GitHub username (optional, will prompt if not provided)"
    echo ""
    echo "Examples:"
    echo "  $0 /path/to/my-project my-awesome-repo"
    echo "  $0 ./my-folder my-repo myusername"
    echo ""
    echo "Prerequisites:"
    echo "  - Git must be installed"
    echo "  - GitHub CLI (gh) must be installed and authenticated"
    echo "  - Or you can use personal access token for HTTPS authentication"
}

# Check if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# Check arguments
if [ $# -lt 2 ]; then
    print_error "Missing required arguments"
    show_usage
    exit 1
fi

FOLDER_PATH="$1"
REPO_NAME="$2"
GITHUB_USERNAME="$3"

# Validate folder path
if [ ! -d "$FOLDER_PATH" ]; then
    print_error "Folder '$FOLDER_PATH' does not exist"
    exit 1
fi

# Convert to absolute path
FOLDER_PATH=$(realpath "$FOLDER_PATH")
print_status "Working with folder: $FOLDER_PATH"

# Get GitHub username if not provided
if [ -z "$GITHUB_USERNAME" ]; then
    # Try to get from git config first
    GITHUB_USERNAME=$(git config --global user.name 2>/dev/null || echo "")
    
    if [ -z "$GITHUB_USERNAME" ]; then
        read -p "Enter your GitHub username: " GITHUB_USERNAME
    else
        print_status "Using GitHub username from git config: $GITHUB_USERNAME"
    fi
fi

if [ -z "$GITHUB_USERNAME" ]; then
    print_error "GitHub username is required"
    exit 1
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install Git first."
    exit 1
fi

# Check if GitHub CLI is available
GH_CLI_AVAILABLE=false
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        GH_CLI_AVAILABLE=true
        print_status "GitHub CLI is available and authenticated"
    else
        print_warning "GitHub CLI is installed but not authenticated"
    fi
else
    print_warning "GitHub CLI is not installed"
fi

print_status "Starting repository creation process..."

# Navigate to the folder
cd "$FOLDER_PATH"

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
    print_status "Initializing Git repository..."
    git init
    print_success "Git repository initialized"
else
    print_status "Git repository already exists"
fi

# Check if there are any files to commit
if [ -z "$(ls -A)" ]; then
    print_warning "Folder is empty. Creating a README.md file..."
    echo "# $REPO_NAME" > README.md
    echo "" >> README.md
    echo "This repository was created automatically." >> README.md
fi

# Add all files
print_status "Adding files to Git..."
git add .

# Check if there are changes to commit
if git diff --cached --quiet; then
    print_warning "No changes to commit. Repository might already be up to date."
else
    # Commit changes
    print_status "Committing changes..."
    git commit -m "Initial commit"
    print_success "Changes committed"
fi

# Set main branch
git branch -M main

# Create repository on GitHub
if [ "$GH_CLI_AVAILABLE" = true ]; then
    print_status "Creating repository on GitHub using GitHub CLI..."
    
    # Check if repository already exists
    if gh repo view "$GITHUB_USERNAME/$REPO_NAME" &> /dev/null; then
        print_warning "Repository '$GITHUB_USERNAME/$REPO_NAME' already exists on GitHub"
        read -p "Do you want to push to the existing repository? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_error "Aborted by user"
            exit 1
        fi
    else
        # Create new repository
        gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
        print_success "Repository created and pushed successfully using GitHub CLI!"
        print_success "Repository URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
        exit 0
    fi
else
    print_status "Creating repository manually..."
    print_warning "GitHub CLI is not available. You'll need to:"
    echo "1. Go to https://github.com/new"
    echo "2. Create a new repository named '$REPO_NAME'"
    echo "3. Don't initialize with README, .gitignore, or license (since we're pushing existing code)"
    echo ""
    read -p "Press Enter after creating the repository on GitHub..."
fi

# Add remote origin
REPO_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
print_status "Adding remote origin: $REPO_URL"

# Remove existing origin if it exists
if git remote get-url origin &> /dev/null; then
    print_warning "Remote 'origin' already exists. Removing it..."
    git remote remove origin
fi

git remote add origin "$REPO_URL"

# Push to GitHub
print_status "Pushing to GitHub..."

# Try to push
if git push -u origin main; then
    print_success "Successfully pushed to GitHub!"
    print_success "Repository URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
else
    print_error "Failed to push to GitHub"
    print_warning "This might be due to authentication issues."
    echo ""
    echo "To fix authentication issues:"
    echo "1. For HTTPS: Set up a personal access token"
    echo "   git remote set-url origin https://TOKEN@github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    echo ""
    echo "2. For SSH: Set up SSH keys"
    echo "   git remote set-url origin git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"
    echo ""
    echo "3. Or install and authenticate GitHub CLI:"
    echo "   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
    echo "   echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null"
    echo "   sudo apt update && sudo apt install gh"
    echo "   gh auth login"
    exit 1
fi

print_success "All done! Your folder has been successfully pushed to GitHub."