variable "location" {
  description = "Azure deployment region"
  type        = string
  default     = "uksouth"
}

variable "project_name" {
  description = "Project resource naming prefix"
  type        = string
  default     = "devops-demo"
}

variable "registry_name" {
  description = "Globally unique Azure Container Registry name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "deploy_app" {
  description = "Enable Container App deployment"
  type        = bool
  default     = false
}

variable "image_tag" {
  description = "Docker image version"
  type        = string
  default     = "v1"
}