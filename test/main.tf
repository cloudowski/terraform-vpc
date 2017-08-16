provider "aws" {
  region = "eu-west-1"
}

//  Create the OpenShift cluster using our module.
module "vpc" {
  source = "../"
  cidr   = "10.0.0.0/16"
}
