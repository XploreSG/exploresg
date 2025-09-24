#!/bin/bash

# Simple Repository Setup Script for Mac/Linux
# Reads repositories from repos.txt and clones/pulls them to the parent directory

CONFIG_FILE="repos.txt"
TARGET_DIR=".."

# Nice startup banner
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 ExploresSG Project Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: Git is not installed. Please install Git first."
    exit 1
fi

# Check if repos.txt exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found"
    echo "Please create repos.txt with repository URLs, one per line."
    exit 1
fi

# Get current directory and set target to project-exploresg root
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_PATH="$(cd "$CURRENT_DIR/../.." && pwd)"

echo "📁 Target directory: $TARGET_PATH"
echo ""

# Read repositories from config file
repos=()
while IFS= read -r line || [ -n "$line" ]; do
    # Trim whitespace and remove carriage returns (for Windows files)
    line=$(echo "$line" | tr -d '\r' | xargs)
    # Skip empty lines and comments
    if [[ -n "$line" && ! "$line" =~ ^#.* && ${#line} -gt 5 ]]; then
        repos+=("$line")
    fi
done < "$CONFIG_FILE"

if [ ${#repos[@]} -eq 0 ]; then
    echo "Warning: No repositories found in $CONFIG_FILE"
    echo "Please add repository URLs to repos.txt, one per line."
    exit 1
fi

echo "Processing ${#repos[@]} repositories..."

# Process each repository
successful=0
failed=0
current=0
total=${#repos[@]}

# Function to show progress with current repo
show_progress() {
    local current=$1
    local total=$2
    local repo_name=$3
    local status=$4
    local width=30
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    
    # Clear previous lines (current repo + progress bar)
    printf "\r\033[2K"  # Clear current line
    printf "\033[1A\r\033[2K" 2>/dev/null || true  # Clear line above if exists
    
    # Show current operation
    printf "🔄 %s: %s\n" "$repo_name" "$status"
    
    # Show progress bar
    printf "Progress: ["
    for ((i=0; i<completed; i++)); do printf "█"; done
    for ((i=completed; i<width; i++)); do printf "░"; done
    printf "] %d%% (%d/%d)" "$percentage" "$current" "$total"
}

# Arrays to track results
cloned_repos=()
updated_repos=()
failed_repos=()

echo ""

# Function to show spinner for long operations
show_spinner() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        printf "\r%s %s" "${spin:$i:1}" "$message"
        i=$(((i + 1) % ${#spin}))
        sleep 0.1
    done
    printf "\r"
}

for repo_url in "${repos[@]}"; do
    # Skip if repo_url is empty (shouldn't happen but extra safety)
    if [[ -z "$repo_url" ]]; then
        echo "Skipping empty repository URL"
        continue
    fi
    
    # Extract repository name
    repo_name=$(basename "$repo_url" .git)
    repo_path="$TARGET_PATH/$repo_name"
    
    if [ -d "$repo_path" ]; then
        # Update existing repositories
        show_progress $current $total "$repo_name" "Pulling latest changes..."
        
        cd "$repo_path"
        if git pull origin &> /dev/null; then
            updated_repos+=("$repo_name")
            ((successful++))
        else
            failed_repos+=("$repo_name (pull failed)")
            ((failed++))
        fi
        cd "$CURRENT_DIR"
    else
        # Show cloning status
        show_progress $current $total "$repo_name" "Cloning repository..."
        
        if git clone "$repo_url" "$repo_path" &> /dev/null; then
            cloned_repos+=("$repo_name")
            ((successful++))
        else
            failed_repos+=("$repo_name (clone failed)")
            ((failed++))
        fi
    fi
    
    # Update progress
    ((current++))
done

# Clear the progress display
printf "\r\033[2K"  # Clear current line
printf "\033[1A\r\033[2K" 2>/dev/null || true  # Clear line above
printf "\r"

# Show final summary
echo "🎉 Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Show cloned repositories
if [ ${#cloned_repos[@]} -gt 0 ]; then
    echo "📦 Newly Cloned:"
    for repo in "${cloned_repos[@]}"; do
        echo "  ✅ $repo"
    done
fi

# Show updated repositories
if [ ${#updated_repos[@]} -gt 0 ]; then
    echo "🔄 Updated:"
    for repo in "${updated_repos[@]}"; do
        echo "  ✅ $repo"
    done
fi

# Show failed repositories
if [ ${#failed_repos[@]} -gt 0 ]; then
    echo "❌ Failed:"
    for repo in "${failed_repos[@]}"; do
        echo "  ❌ $repo"
    done
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Location: $TARGET_PATH"
echo "📊 Total: $successful successful, $failed failed"

