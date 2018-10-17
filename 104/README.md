
# Terraform And AWS Module (104)

## Overview
Terraform Modules are used to bundle terraform code and to make it easy to re-use them. Module code looks the same as regular terraform code. In this module you will see how to make a module and how to use it.

## Training Goals for this module
Though this module we will learn:
*  The difference between a root module and another module
*  How variables and outputs are used together with Modules



# Terraform Modules & Output

In most cases, AWS infastructure tend to exist out of many resources. To keep it DRY and to make it possible to re-use Terraform code over and over we use so called Terraform Modules.

"Modules. Modules in Terraform are self-contained packages of Terraform configurations that are managed as a group. Modules are used to create reusable components in Terraform as well as for basic code organization."

Modules are either
* A folder on the filesystem with a single .tf file
* A github repository with a tf file
* A module exported through the Terraform Registry

## Let's create a module

1. In your current Terraform directory, create a folder called `vpc`
2. Copy all file of your current terraform  working directory to the vpc folder and remove provider.tf, Makefile and terraform.tfvars
3. Clean your current main.tf
4. Create a module block
```hcl
module "vpc" {
  source             = "./vpc"
  network_name       = "${var.network_name}"
  network            = "${var.network}"
  public_subnets     = ["${var.public_subnets}"]
  private_subnets    = ["${var.private_subnets}"]
  availability_zones = ["${var.availability_zones}"]
}
```
5. modify the outputs.tf in your root module folder to
```hcl
output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
```

Now we moved all the network logic to a separate module. The input params are defined by the variables.tf inside the vpc module. To get information outof the module outputs are used to be able to later reference them again.
