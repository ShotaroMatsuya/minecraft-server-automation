config {
  # TFLint configuration for Terraform analysis
  call_module_type = "all"
  force = false
  disabled_by_default = false
}

# AWS provider rules
plugin "aws" {
  enabled = true
  version = "0.42.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Terraform rules
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Custom rules
rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
  style   = "semver"
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_standard_module_structure" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_unused_required_providers" {
  enabled = true
}

# AWS specific rules
rule "aws_resource_missing_tags" {
  enabled = true
  tags = ["Environment", "Project", "Owner"]
}

rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_s3_bucket_invalid_acl" {
  enabled = true
}

rule "aws_security_group_rule_invalid_protocol" {
  enabled = true
}
