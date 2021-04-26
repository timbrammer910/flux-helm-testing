variable "project_id" {
  description = "project id"
  default     = "terraform-gke-311314"
}

variable "region" {
  description = "region"
  default     = "us-west4"
}

variable "username" {
  default     = ""
  description = "gke username"
}

variable "password" {
  default     = ""
  description = "gke password"
}

variable "nodes" {
  default     = 2
  description = "number of gke nodes"
}

variable "application_name" {
  type    = string
  default = "flux-demo"
}

