# Terraform Root module and Variables

The terraform codebase you are executing terraform from is called the `Root module`. Terraform does not traverse any directories and all files ending with .tf are seen as one big file concatenated.

It's up to the developer to name files and create logical groups by filenames. Although the developer is completely free, it's common to work on a certain pattern.
* ./provider.tf <- Here the provider blocks are added
* ./variables.tf <- Here the variable blocks are added
* ./outputs.tf <- Here the outputs blocks are added

In the previous course module, the variables were prefilled with default values. In some cases the same terraform code could be re-used on a different AWS Account which would render the use of default values unwished for.

To populate these variables Terraform has files called .tfvars. For all files which match terraform.tfvars or *.auto.tfvars present in the current directory, Terraform automatically loads them to populate variables. If the tfvar file has a different name, terraform can be called with an extra argument -var-file ./filename.tfvars. By doing so a terraform wrapper script can choose which tfvars file to load.

TFVars have a syntax similar to INI files. In the example of this module you will find a terraform.tfvars with names identical to the names in the variables.tf
```hcl
network_name = "myvpc"
network = "10.10.0.0/16"
availability_zones=["eu-central-1a", "eu-central-1b"]
public_subnets=["10.10.11.0/24", "10.10.12.0/24"]
private_subnets=["10.10.21.0/24", "10.10.22.0/24"]
```

1. Modify your current codebase to be similar to the source folder
2. Plan & Apply!
