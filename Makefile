.PHONY: help install-tools validate fmt plan apply destroy clean

# Default target
help: ## Show this help
	@echo "🛠️  Minecraft Server Automation - Available Commands"
	@echo ""
	@echo "📦 Tool Management:"
	@grep -E '^(install-tools|reinstall-aqua|update-aqua):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "🔍 Code Quality:"
	@grep -E '^(validate|fmt|lint):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "📋 Planning:"
	@grep -E '^(plan-keeping|plan-scheduling|plan-all):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "🚀 Deployment:"
	@grep -E '^(deploy-all|apply-keeping|apply-scheduling):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "🎮 Minecraft Operations:"
	@grep -E '^(start-minecraft|stop-minecraft):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "🗑️  Cleanup:"
	@grep -E '^(destroy-all|destroy-keeping|destroy-scheduling|clean):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

install-tools: ## Install all tools via aqua
	aqua install

reinstall-aqua: ## Reinstall aqua with verification disabled
	curl -sSfL https://raw.githubusercontent.com/aquaproj/aqua-installer/v3.1.0/aqua-installer | bash -s -- --no-policy

update-aqua: ## Update aqua to latest version
	aqua update-aqua

validate: ## Validate Terraform configurations
	@echo "🔄 Initializing keeping resources..."
	cd terraform/keeping && terraform init -upgrade
	cd terraform/keeping && terraform validate
	@echo "🔄 Initializing scheduling resources..."
	cd terraform/scheduling && terraform init -upgrade
	cd terraform/scheduling && terraform validate
	@echo "✅ All Terraform configurations are valid"

fmt: ## Format Terraform configurations
	cd terraform/keeping && terraform fmt -recursive
	cd terraform/scheduling && terraform fmt -recursive

lint: ## Run TFLint on Terraform configurations
	cd terraform/keeping && tflint
	cd terraform/scheduling && tflint

plan-keeping: ## Show Terraform plan for keeping resources
	cd terraform/keeping && terraform plan

plan-scheduling: ## Show Terraform plan for scheduling resources
	cd terraform/scheduling && terraform plan

apply-keeping: ## Apply Terraform for keeping resources
	cd terraform/keeping && terraform apply

apply-scheduling: ## Apply Terraform for scheduling resources
	cd terraform/scheduling && terraform apply

# Sequential deployment targets - DEPRECATED: Use Terragrunt commands instead
deploy-all: ## DEPRECATED: Use 'make tg-deploy-all' instead
	@echo "⚠️  WARNING: This command is deprecated!"
	@echo "❌ The direct Terraform workflow is no longer supported after Terragrunt migration."
	@echo "✅ Please use: make tg-deploy-all"
	@echo ""
	@echo "📋 Migration steps:"
	@echo "  1. make tg-init         # Initialize Terragrunt"
	@echo "  2. make tg-plan-all     # Plan deployment"
	@echo "  3. make tg-deploy-all   # Deploy infrastructure"
	@exit 1

plan-all: ## DEPRECATED: Use 'make tg-plan-all' instead
	@echo "⚠️  WARNING: This command is deprecated!"
	@echo "❌ Please use: make tg-plan-all"
	@exit 1

# Sequential destruction targets (reverse order)
destroy-all: ## Destroy all resources in reverse order (scheduling -> keeping)
	@echo "🗑️  Starting full destruction..."
	@echo "📋 Step 1: Destroying scheduling resources first..."
	cd terraform/scheduling && terraform destroy
	@echo "✅ Scheduling resources destroyed"
	@echo "📋 Step 2: Destroying keeping resources..."
	cd terraform/keeping && terraform destroy
	@echo "🎉 All resources destroyed successfully!"

# Start/Stop scheduling resources only (for daily operations) - DEPRECATED
start-minecraft: ## DEPRECATED: Use 'make tg-start-minecraft' instead  
	@echo "⚠️  WARNING: This command is deprecated!"
	@echo "✅ Please use: make tg-start-minecraft"
	@exit 1

stop-minecraft: ## DEPRECATED: Use 'make tg-stop-minecraft' instead
	@echo "⚠️  WARNING: This command is deprecated!"
	@echo "✅ Please use: make tg-stop-minecraft"  
	@exit 1

clean: ## Clean Terraform cache and lock files
	find terraform -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	find terraform -name ".terraform.lock.hcl" -delete 2>/dev/null || true

check-tools: ## Check tool versions and PATH
	@echo "🔍 Checking tool versions..."
	@echo "PATH: $$PATH"
	@echo "Terraform: $$(which terraform) - $$(terraform version --json | jq -r '.terraform_version')"
	@echo "AWS CLI: $$(which aws) - $$(aws --version)"
	@echo "TFLint: $$(which tflint) - $$(tflint --version)"

setup-path: ## Setup aqua PATH in current shell
	@echo "Setting up aqua PATH..."
	@echo 'export PATH="$${AQUA_ROOT_DIR:-$${XDG_DATA_HOME:-$$HOME/.local/share}/aquaproj-aqua}/bin:$$PATH"'
	@echo "Run the above export command or source your shell profile"

init: ## Initialize Terraform for both keeping and scheduling
	@echo "🔄 Initializing Terraform configurations..."
	cd terraform/keeping && terraform init -upgrade
	cd terraform/scheduling && terraform init -upgrade
	@echo "✅ Terraform initialization complete"

upgrade-modules: ## Upgrade all Terraform modules to latest versions
	@echo "🔄 Upgrading Terraform modules..."
	cd terraform/keeping && terraform init -upgrade
	cd terraform/scheduling && terraform init -upgrade
	@echo "✅ All modules upgraded successfully"

# Terragrunt commands
tg-validate: ## Validate Terragrunt configurations
	@echo "🔍 Validating Terragrunt configurations..."
	cd terragrunt/environments/keeping && terragrunt validate
	cd terragrunt/environments/scheduling && terragrunt validate
	@echo "✅ All Terragrunt configurations are valid"

tg-init: ## Initialize Terragrunt for both environments
	@echo "🔄 Initializing Terragrunt configurations..."
	cd terragrunt/environments/keeping && terragrunt init
	cd terragrunt/environments/scheduling && terragrunt init
	@echo "✅ Terragrunt initialization complete"

tg-plan-keeping: ## Show Terragrunt plan for keeping resources
	cd terragrunt/environments/keeping && terragrunt plan

tg-plan-scheduling: ## Show Terragrunt plan for scheduling resources
	cd terragrunt/environments/scheduling && terragrunt plan

tg-plan-all: ## Show Terragrunt plans for both environments
	@echo "📋 Planning keeping resources..."
	cd terragrunt/environments/keeping && terragrunt plan
	@echo "📋 Planning scheduling resources..."
	cd terragrunt/environments/scheduling && terragrunt plan

tg-deploy-all: ## Deploy all resources using Terragrunt (keeping -> scheduling)
	@echo "🚀 Starting Terragrunt deployment..."
	@echo "📋 Step 1: Deploying keeping resources..."
	cd terragrunt/environments/keeping && terragrunt apply
	@echo "✅ Keeping resources deployed successfully"
	@echo "📋 Step 2: Deploying scheduling resources..."
	cd terragrunt/environments/scheduling && terragrunt apply
	@echo "🎉 All resources deployed successfully!"

tg-start-minecraft: ## Start minecraft server using Terragrunt
	@echo "🎮 Starting Minecraft server with Terragrunt..."
	cd terragrunt/environments/scheduling && terragrunt apply
	@echo "✅ Minecraft server started!"

tg-stop-minecraft: ## Stop minecraft server using Terragrunt
	@echo "🛑 Stopping Minecraft server with Terragrunt..."
	cd terragrunt/environments/scheduling && terragrunt destroy
	@echo "✅ Minecraft server stopped!"

tg-destroy-all: ## Destroy all resources using Terragrunt (reverse order)
	@echo "🗑️  Starting Terragrunt destruction..."
	@echo "📋 Step 1: Destroying scheduling resources..."
	cd terragrunt/environments/scheduling && terragrunt destroy
	@echo "✅ Scheduling resources destroyed"
	@echo "📋 Step 2: Destroying keeping resources..."
	cd terragrunt/environments/keeping && terragrunt destroy
	@echo "🎉 All resources destroyed successfully!"
