variable "name" {
  description = "Nom du Load Balancer"
  type        = string
}

variable "subnets" {
  description = "Liste des subnets où le Load Balancer sera déployé"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID du VPC où se trouve Vault"
  type        = string
}

variable "vault_instance_ids" {
  description = "Liste des IDs des instances Vault"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN du certificat SSL ACM pour HTTPS"
  type        = string
}

variable "member_group_name" {
  description = "Nom du Security Group pour Vault"
  type        = string
}

variable "load_balancer_group_name" {
  description = "Nom du Security Group pour le Load Balancer"
  type        = string
}

variable "bastion_group_id" {
  description = "ID du Security Group pour le Bastion"
  type        = string
}