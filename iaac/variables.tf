#variables.tf


#app variables
variable "env-prefix" {
  default = "VTT_"
  description = "Prefix for the environment variables to be used by servian app"
}

variable "app_port" {
  default = "3000"
  description = "Port number on which the application is running"
}

variable "db_port" {
  default = "5432"
  description = "Port number on which the DB is running"
}

variable "listen_host" {
  default = "0.0.0.0"
  description = "Setting up the listening host for the app"
}

variable "db_pass" {
  description = "Password to be used for app database"
  sensitive = true
}

variable "db_user" {
  default = "postgres"
  description = "User for accessing database"
  sensitive = true
}

variable "db_name" {
  default = "app"
  description = "Initial database name"
  sensitive = true
}

#custom variables for terraform config
variable "repository_name" {
  default = "tech-challenge-app"
  description = "ECR repository name which has to be created manually to avoid trouble"
}

variable "health_check_path" {
  default = "/healthcheck/"
}
