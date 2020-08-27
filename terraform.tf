terraform {
  backend "s3" {
    region         = "me-south-1"
    encrypt        = true
    bucket         = "the-sun-must-die"
    key            = "beta-project/jenkins-server/terraform.tfstate"
    dynamodb_table = "the-moon-has-never-been-there"
  }
}
