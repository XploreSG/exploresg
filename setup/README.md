# Project Setup

This setup folder contains scripts to bootstrap your project by automatically cloning all required repositories.

## Quick Start

1. **Edit `repos.txt`** - Add your project repository URLs, one per line
2. **Run setup script**: `./setup.sh`
   - **First time**: `chmod +x setup.sh && ./setup.sh`
   - **Windows**: Use Git Bash, WSL, or any shell environment

## Files

- **`repos.txt`** - Configuration file with repository URLs
- **`setup.sh`** - Cross-platform shell script (works on Windows, Mac, Linux)

## How it Works

1. Reads repository URLs from `repos.txt`
2. Clones repositories to the `project-exploresg` root directory
3. For each repository:
   - **If exists**: Pulls latest changes
   - **If new**: Clones the repository
4. Shows summary and optionally opens the project directory

## Example repos.txt

```
git@github.com:XploreSG/exploresg-frontend-service.git
git@github.com:XploreSG/exploresg-user-service.git
git@github.com:XploreSG/exploresg-api-gateway.git
```

## Directory Structure After Setup

```
d:\learning-projects\
└── project-exploresg\          # Root directory
    ├── exploresg\              # This bootstrap repository
    │   └── setup\              # Setup scripts
    ├── exploresg-frontend-service\  # Cloned repositories
    ├── exploresg-user-service\
    └── other-services\
```

## Prerequisites

- **Git** must be installed and available in your PATH
- **SSH keys configured** with your Git provider (GitHub, GitLab, etc.)
- **Internet connection** to clone repositories
- **Access** to all repositories listed in `repos.txt`

## SSH Key Setup

For team members who haven't set up SSH keys yet:

1. **Generate SSH key**: `ssh-keygen -t ed25519 -C "your.email@company.com"`
2. **Add to SSH agent**: `ssh-add ~/.ssh/id_ed25519`
3. **Copy public key**: `cat ~/.ssh/id_ed25519.pub` (Linux/Mac) or `type %USERPROFILE%\.ssh\id_ed25519.pub` (Windows)
4. **Add to GitHub/GitLab**: Paste the public key in your Git provider's SSH keys section
5. **Test connection**: `ssh -T git@github.com`

## Why SSH Instead of HTTPS?

**SSH is the industry standard for development teams:**

- ✅ **No password prompts** - Uses key-based authentication
- ✅ **More secure** - Cryptographic keys vs passwords/tokens
- ✅ **Better for frequent pushes** - Seamless authentication
- ✅ **Team-friendly** - Standard practice in professional environments

**HTTPS is mainly for:**

- One-time cloning of public repositories
- Environments where SSH is blocked
- Quick anonymous access

## Usage for Teams

1. **Team Lead**: Add all project repository URLs to `repos.txt`
2. **Developers**:
   - Clone this bootstrap repository
   - Run: `chmod +x setup.sh && ./setup.sh`
   - All project repositories are automatically set up

Perfect for onboarding new team members or setting up development environments!
