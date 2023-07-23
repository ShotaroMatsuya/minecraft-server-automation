output "efs_id" {
  description = "The ID that identifies the file system (e.g., `fs-ccfc0d65`)"
  value       = aws_efs_file_system.main.id
}

output "efs_arn" {
  description = "Amazon Resource Name of the file system"
  value       = aws_efs_file_system.main.arn
}
