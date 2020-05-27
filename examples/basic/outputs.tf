output "public_ip" {
    value = module.atlantis.atlantis_public_ip
}

output "domain_name" {
    value = module.atlantis.atlantis_xip_domain
}

output "ssh_user" {
    value = module.atlantis.atlantis_ssh_user
}

output "role_arn" {
    value = module.atlantis.atlantis_role_arn
}

output "instance_id" {
    value = module.atlantis.atlantis_ec2_id
}

output "security_group_id" {
    value = module.atlantis.atlantis_security_group
}