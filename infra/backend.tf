terraform {
  backend "s3" {
    bucket         = "dream-vacations-tfstate-730012679214"
    key            = "dream-vacations/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dream-vacations-tfstate-lock"
    encrypt        = true
  }
}
