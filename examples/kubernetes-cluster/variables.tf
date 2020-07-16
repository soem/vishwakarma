variable "aws_region" {
  description = "(Optional) The AWS region"
  type        = string
  default     = "us-west-2"
}

variable "kubernetes_version" {
  description = "Kubernetes cluster version."
  type        = string
  default     = "v1.18.5"
}

variable "service_cidr" {
  description = "(Optional) The Kubernetes service CIDR."
  type        = string
  default     = "10.96.0.0/12"
}

variable "cluster_cidr" {
  description = "(Optional) The Kubernetes cluster CIDR."
  type        = string
  default     = "172.24.0.0/13"
}

variable "key_pair_name" {
  description = "The ssh key name for all instance, e.g. bastion, master, etcd, worker"
  type        = string
}

variable "network_plugin" {
  description = "(Optional) Desired network plugin which is use for Kubernetes cluster. e.g. 'flannel', 'amazon-vpc'"
  type        = string
  default     = "amazon-vpc"
}

variable "environment" {
  description = "(Optional) environment name, used to compose the resource name"
  type        = string
  default     = "test"
}

variable "project" {
  description = "(Optional) project name, used to compose the resource name"
  type        = string
  default     = "getamis"
}

variable "name" {
  description = "(Optional) name, used to compose the resource name"
  type        = string
  default     = "k8s"
}

variable "service" {
  description = "(Optional) which service provide by this service"
  type        = string
  default     = "kubernetes"
}

variable "endpoint_public_access" {
  description = "(Optional) kubernetes apiserver endpoint"
  default     = false
}
