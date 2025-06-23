variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-c"
}

variable "instance_name" {
  description = "Nome da instância"
  type        = string
  default     = "workstation"
}

variable "gcp_user" {
  description = "Nome do usuário na VM"
  type        = string
  default     = "GCP_USER"
}

variable "ssh_public_key_path" {
  description = "Caminho para a chave pública SSH"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
