output "endpoints" {
  value = [
    for instance_ip in aws_instance.etcd.*.private_ip :
    "https://ip-${replace(instance_ip, ".", "-")}.${local.discovery_service}:${local.client_port}"
  ]
}

output "ca_cert" {
  value     = module.etcd_ca.cert_pem
  sensitive = true
}

output "ca_key" {
  value     = module.etcd_ca.private_key_pem
  sensitive = true
}

output "default_role_name" {
  value = aws_iam_role.etcd.name
}
