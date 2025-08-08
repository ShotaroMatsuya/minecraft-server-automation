# 🎮 Minecraft Server Infrastructure on AWS

Cost-optimized Minecraft server infrastructure using Terragrunt for multi-environment management.

## 🏗️ Architecture

- **keeping**: Persistent infrastructure (VPC, IAM, SNS)
- **scheduling**: Cost-optimized resources (ECS, Lambda)

## 🚀 Quick Start

### Prerequisites

```bash
# Install aqua for tool management
curl -sSfL https://raw.githubusercontent.com/aquaproj/aqua-installer/v3.1.0/aqua-installer | bash
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aqua}/bin:$PATH"

# Install tools
make install-tools
```

### Deploy

```bash
# Configure AWS
export AWS_ACCOUNT_ID=your-account-id
aws configure

# Deploy infrastructure
make tg-init
make tg-deploy-all

# Start server
make tg-start-minecraft
```

## 📋 Commands

| Command | Description |
|---------|-------------|
| `make tg-deploy-all` | Deploy all environments |
| `make tg-start-minecraft` | Start server |
| `make tg-stop-minecraft` | Stop server |
| `make tg-destroy-all` | Destroy infrastructure |

Run `make help` for full command list.

## � AWS Setup

See [AWS OIDC Setup Guide](docs/aws-oidc-setup.md) for GitHub Actions authentication.
