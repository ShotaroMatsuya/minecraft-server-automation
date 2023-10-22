resource "aws_backup_plan" "main" {
  name = "hourly-backup-plan"

  rule {
    rule_name         = "hourlry-rule"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 * * * ? *)"
    lifecycle {
      delete_after = 30
    }
  }
}

resource "aws_backup_vault" "main" {
  name = "minecraft-vault"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "backup" {
  name               = "minecraft-backup-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "backup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup.name
}

resource "aws_backup_selection" "backup" {
  iam_role_arn = aws_iam_role.backup.arn
  name         = "minecraft-selection"
  plan_id      = aws_backup_plan.main.id

  resources = [
    aws_efs_file_system.main.arn
  ]
}
