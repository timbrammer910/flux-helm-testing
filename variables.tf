variable "project_id" {
  description = "project id"
  default     = "terraform-gke-311221"
}

variable "region" {
  description = "region"
  default     = "us-west4"
}

variable "nodes" {
  default     = 2
  description = "number of gke nodes"
}
