# 🚀 Terragrunt Deployment Guide

## ⚠️ Important Migration Notice

**The old Terraform commands are deprecated!** After migrating to Terragrunt, you must use the new `tg-*` commands.

### ❌ Old Commands (Deprecated)
```bash
make deploy-all     # DON'T USE - will fail
make plan-all       # DON'T USE - deprecated
make start-minecraft # DON'T USE - deprecated
```

### ✅ New Commands (Terragrunt)
```bash
make tg-init        # Initialize Terragrunt
make tg-plan-all    # Plan deployment
make tg-deploy-all  # Deploy infrastructure
make tg-start-minecraft # Start minecraft server
```

## 📋 Complete Deployment Workflow

### Step 1: Prerequisites
```bash
# Install tools
make install-tools

# Set your AWS account ID
export AWS_ACCOUNT_ID=your-actual-account-id

# Configure AWS credentials
aws configure
```

### Step 2: Initialize Terragrunt
```bash
# This downloads modules and configures backends
make tg-init
```

### Step 3: Plan Deployment
```bash
# This shows what will be created
make tg-plan-all
```

### Step 4: Deploy Infrastructure
```bash
# This deploys keeping first, then scheduling (automatically)
make tg-deploy-all
```

## 🏗️ Architecture Understanding

### Environment Dependencies
```
keeping environment (persistent infrastructure)
├── VPC, subnets, security groups
├── IAM roles for ECS tasks
├── SNS topics for notifications
├── KMS keys for encryption
└── ChatBot integration

scheduling environment (cost-optimized resources)
├── Depends on: keeping environment ✅
├── ECS cluster and services
├── Load balancer (NLB)
├── Lambda functions
├── CloudWatch logs and alarms
└── Domain configuration
```

### Why Dependencies Matter
The scheduling environment uses `data` sources to reference resources created by keeping:

```terraform
# scheduling/main.tf looks for these resources:
data "aws_vpc" "myvpc" { ... }                    # Created by keeping
data "aws_iam_role" "task_role" { ... }          # Created by keeping  
data "aws_sns_topic" "my_sns" { ... }            # Created by keeping
```

**This is why scheduling will fail if keeping isn't deployed first!**

## 🎮 Daily Operations

### Start Minecraft Server
```bash
make tg-start-minecraft
```

### Stop Minecraft Server (save costs)
```bash
make tg-stop-minecraft
```

### Full Cleanup
```bash
make tg-destroy-all
```

## 🔧 Troubleshooting

### "Backend initialization required" Error
This happens when using old commands. **Solution**: Use Terragrunt commands instead.

### "no matching EC2 VPC found" Error  
This happens when scheduling runs before keeping. **Solution**: Terragrunt handles this automatically with `make tg-deploy-all`.

### "Module not found" Error
Run `make tg-init` to download modules.

## ✅ Quick Reference

| Task | Command |
|------|---------|
| Initialize | `make tg-init` |
| Plan | `make tg-plan-all` |
| Deploy | `make tg-deploy-all` |
| Start MC | `make tg-start-minecraft` |
| Stop MC | `make tg-stop-minecraft` |
| Destroy | `make tg-destroy-all` |

---

**Remember**: Always use `tg-*` commands after the Terragrunt migration! 🎯
