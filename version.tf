# versions.tf

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
<<<<<<< HEAD
      version = ">= 5.46.0"
=======
      version = "~> 4.0"
>>>>>>> 5e5e6c6d2a126d682af4464dc9ccb3d7e14ab179
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}
