output "atlantis_role_name" {
  description = "Role name for the Atlantis EC2"
  value       = aws_iam_role.atlantis.name
}

output "atlantis_role_arn" {
  description = "ARN of the Atlantis EC2 role"
  value       = aws_iam_role.atlantis.arn
}

output "atlantis_public_ip" {
  description = "Elastic IP of the EC2"
  value       = aws_eip.self.public_ip
}

output "atlantis_xip_domain" {
  description = "XIP based domain for the EC2"
  value       = "${aws_eip.self.public_ip}.xip.io"
}

output "atlantis_ssh_user" {
  description = "Username to ssh to the EC2"
  value       = "ubuntu"
}

output "atlantis_security_group" {
  description = "List of ID of security group for the Atlantis EC2"
  value       = aws_instance.self.vpc_security_group_ids
}

output "atlantis_ec2_id" {
  description = "ID of the Atlantis EC2"
  value       = aws_instance.self.id
}
