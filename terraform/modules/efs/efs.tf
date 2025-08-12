resource "aws_efs_file_system" "main" {
  encrypted        = true
  performance_mode = "generalPurpose"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

}

resource "aws_efs_backup_policy" "main" {
  file_system_id = aws_efs_file_system.main.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "main" {
  for_each       = { for k, v in var.public_subnets : k => v }
  file_system_id = aws_efs_file_system.main.id
  subnet_id      = each.value
  security_groups = [
    var.security_group_id
  ]
}
