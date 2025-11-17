terraform {
  backend "s3" {
    bucket       = "b-tf-805649859294"
    key          = "iti/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
