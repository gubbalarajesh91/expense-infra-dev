variable "project_name" {
    default = "expense"
  
}

variable "environment" {
    default = "dev"
  
}

variable "common_tags" {
    default = {
        Project = "expense"
        Environment = "dev"
        Terraform = "true"
        Component = "web_alb"
    }
  
}


variable "zone_name" {
  default = "indix.store"
}

variable "zone_id" {
    default = "Z01554241D4PXADZBZ1KY"
  
}