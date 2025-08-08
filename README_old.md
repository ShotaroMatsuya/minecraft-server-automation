![Static Badge](https://img.shields.io/badge/minecraft-v1.21-blue)
[![drift](https://github.com/ShotaroMatsuya/minecraft-server-automation/actions/workflows/drift.yml/badge.svg)](https://github.com/ShotaroMatsuya/minecraft-server-automation/actions/workflows/drift.yml)
[![Matrix Docker Build with Snyk Scan](https://github.com/ShotaroMatsuya/minecraft-server-automation/actions/workflows/build_image.yml/badge.svg)](https://github.com/ShotaroMatsuya/minecraft-server-automation/actions/workflows/build_image.yml)
[![Start and Stop Workflow](https://github.com/ShotaroMatsuya/minecraft-server-automation/actions/workflows/schedule_job.yml/badge.svg)](https://github.com/ShotaroMatsuya/minecraft-server-automation/actions/workflows/schedule_job.yml)
[![Terraform Continuous Integration By Official](https://github.com/ShotaroMatsuya/minecraft-server-automation/actions/workflows/terraform_ci.yml/badge.svg)](https://github.com/ShotaroMatsuya/minecraft-server-automation/actions/workflows/terraform_ci.yml)
[![Apply](https://github.com/ShotaroMatsuya/minecraft-server-automation/actions/workflows/apply.yml/badge.svg)](https://github.com/ShotaroMatsuya/minecraft-server-automation/actions/workflows/apply.yml)
# minecraft-server-automation

Build a minecraft container execution environment using terraform.  

## Main Feature

It mainly supports local provisioning.  
Since it uses personal resources, it is divided into two terraform.states as below considering the cost.  

#### keeping

Resources that do not cost much even if they are constantly running are defined as `keeping` resources.

#### scheduling

For resources that incur running costs, automatically start or stop them on daily.　　
These are defined as `scheduling` resources.

![Infrastructure Diagram](./docs/mc-server.drawio.png)

## Other Feature

- Backup  
By customizing the entrypoint shell of the Dockerfile, it is possible to restore from the latest data from backup (S3) when starting, and automatically back up when stopping.  
Continuous backups to inexpensive object storage(AWS S3) eliminate the risk of data loss due to frequent container lifecycles.  
Those activities will be notified in own slack.

- Task definition mapped from yaml  
Improves operability by defining container environment variables in multiple yaml files　and mapping them with terraform.

- Restore  
By default restore is performed from the latest backup when the container starts (As mentioned earlier), it is also possible to restore world data from a specific recovery point via terraform variable.  
This is useful when you want to travel back in time to your precious world.


## Prerequisites

### Tool Version Management with aqua

This project uses [aqua](https://aquaproj.github.io/) for consistent tool version management across all environments.

#### Installation

```bash
# Method 1: Using latest installer (recommended)
curl -sSfL https://raw.githubusercontent.com/aquaproj/aqua-installer/v3.1.0/aqua-installer | bash

# Method 2: If SLSA verification fails, disable verification temporarily
curl -sSfL https://raw.githubusercontent.com/aquaproj/aqua-installer/v3.1.0/aqua-installer | bash -s -- --no-policy

# Method 3: Install via Homebrew (macOS)
brew install aquaproj/aqua/aqua


# Add to PATH (add this to your shell profile)
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aqua}/bin:$PATH"
```

#### Usage

```bash
# Install all tools defined in aqua.yaml
aqua install

# Verify PATH and tool versions
make check-tools

# Check tool versions
terraform version
tflint --version
aws --version
```

**Important**: Make sure aqua's bin directory is in your PATH before system-installed tools:

```bash
# Add this to your shell profile (~/.bash_profile, ~/.zshrc, etc.)
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"

# Reload your shell or run:
source ~/.bash_profile  # or ~/.zshrc
```

#### Troubleshooting

If you encounter SLSA verification errors:

```bash
# Option 1: Update aqua to latest version
aqua update-aqua

# Option 2: Reinstall with verification disabled
curl -sSfL https://raw.githubusercontent.com/aquaproj/aqua-installer/v3.1.0/aqua-installer | bash -s -- --no-policy

# Option 3: Use Homebrew (macOS)
brew install aquaproj/aqua/aqua
```

#### Managed Tools

- **Terraform**: v1.9.8
- **TFLint**: v0.53.0  
- **AWS CLI**: v2.17.57
- **jq**: v1.7.1
- **yq**: v4.44.3

## Quick Start

### Full Deployment

```bash
# Install tools and deploy all resources
make install-tools
make deploy-all
```

### Daily Operations

```bash
# Start Minecraft server (deploy only scheduling resources)
make start-minecraft

# Stop Minecraft server (destroy only scheduling resources)
make stop-minecraft
```

### Development Workflow

```bash
# Setup development environment
make install-tools
make validate
make fmt

# Plan changes
make plan-all

# Deploy infrastructure (keeping resources first, then scheduling)
make deploy-all
```

### Terragrunt Workflow (Recommended)

```bash
# Install tools and initialize Terragrunt
make install-tools
make tg-init

# Deploy all infrastructure (keeping -> scheduling)
make tg-deploy-all
```

### Daily Operations with Terragrunt

```bash
# Start Minecraft server (deploy only scheduling resources)
make tg-start-minecraft

# Stop Minecraft server (destroy only scheduling resources)
make tg-stop-minecraft
```

### Development Workflow with Terragrunt

```bash
# Setup development environment
make install-tools
make tg-validate

# Plan changes
make tg-plan-all

# Deploy infrastructure
make tg-deploy-all
```

### Legacy Terraform Workflow

```bash
# Install tools and deploy all resources
make install-tools
make deploy-all
```

### Daily Operations

```bash
# Start Minecraft server (deploy only scheduling resources)
make start-minecraft

# Stop Minecraft server (destroy only scheduling resources)
make stop-minecraft
```

### Development Workflow

```bash
# Setup development environment
make install-tools
make validate
make fmt

# Plan changes
make plan-all

# Deploy infrastructure (keeping resources first, then scheduling)
make deploy-all
```

### Available Commands

Run `make help` to see all available commands organized by category:

- **Tool Management**: Install and update development tools
- **Code Quality**: Validate, format, and lint Terraform code
- **Planning**: Preview infrastructure changes
- **Deployment**: Deploy infrastructure components
- **Minecraft Operations**: Start/stop game server
- **Cleanup**: Clean up resources and cache

## Utilities

### Simple Load Test

CPU load by repeatedly hitting the yes command

```bash
yes > /dev/null &
yes > /dev/null &
yes > /dev/null &
yes > /dev/null &
yes > /dev/null &
```

```bash
$ jobs
[1]   実行中               yes > /dev/null &
[2]   実行中               yes > /dev/null &
[3]   実行中               yes > /dev/null &
[4]   実行中               yes > /dev/null &
[5]   実行中               yes > /dev/null &
```

```bash
$ kill %1 %2 %3
[1] 終了しました yes > /dev/null
[2]- 終了しました yes > /dev/null
[3]+ 終了しました yes > /dev/null
```

The process that consumes 500MB of memory for each press of Enter is described as follows

```bash
(load-memory.sh)
#! /bin/bash
# "--bytest 5000000" is 500MB.
echo PID=$$
echo -n "[ Enter : powerup! ] , [ Ctrl+d : stop ]"
c=0
while read byte; do
   eval a$c'=$(head --bytes 5000000 /dev/zero |cat -v)'
   c=$(($c+1))
   echo -n ">"
done
echo
```

#### Run the script as follows

```bash
chmod +x load-memory.sh
./load-memory.sh
```

### Bulk deletion of all backup vaults
```bash
aws backup list-backup-jobs | jq -r '.BackupJobs[] | select(.BackupVaultName == "minecraft-vault" )' | jq -r '.RecoveryPointArn' | xargs -L 1 aws backup delete-recovery-point --backup-vault-name minecraft-vault --recovery-point-arn
```

### ECS Exec実行

```bash
cl=$(aws ecs list-clusters | jq -r '.clusterArns[0]' )
prefix=`echo ${cl} | sed -E 's/.+cluster\///g' `
taskarn=$(aws ecs list-tasks --cluster ${cl} | jq -r '.taskArns[0]')
taskid=`echo ${taskarn} | sed -E 's/.+task\/.+\///g' `
CONTAINER_NAME="minecraft"

echo ${cl};     \
echo ${prefix} ; \
echo ${taskarn}; \
echo ${taskid};  \
echo ${CONTAINER_NAME};  \

aws ecs execute-command  \
 --region    ap-northeast-1 \
 --cluster   ${cl} \
 --task      ${taskarn} \
 --container ${CONTAINER_NAME}\
 --command "/bin/sh" \
 --interactive
```

### Confirm environment variables in local
```bash
docker compose run --rm mc env
```
