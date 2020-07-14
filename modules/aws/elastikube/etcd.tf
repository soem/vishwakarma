module "etcd" {
  source = "../../aws/kube-etcd"

  name            = var.name
  ssh_key         = var.ssh_key
  instance_config = var.etcd_instance_config
  container       = local.container

  subnet_ids                  = var.private_subnet_ids
  master_security_group_id    = module.master.master_sg_id
  zone_id                     = aws_route53_zone.private.zone_id
  s3_bucket                   = aws_s3_bucket.ignition.id
  reboot_strategy             = var.reboot_strategy
  certs_validity_period_hours = var.certs_validity_period_hours

  extra_ignition_file_ids         = var.extra_etcd_ignition_file_ids
  extra_ignition_systemd_unit_ids = var.extra_etcd_ignition_systemd_unit_ids
  extra_tags                      = var.extra_tags
}
