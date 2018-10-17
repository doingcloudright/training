# Terraform / AWS (101)

## Overview
Terraform is a tool for provisioning infrastructure. It is a structured templating language that supports many different providers, not just AWS. As well as most resources for each provider. Because Terraform is open source, you can also create your own providers, and resources.
You define the resources you need as code in Terraform templates.

Terraform allows the infrastructure to be defined as code giving three measurable benefits:
*  Reduced Cost
*  Faster Execution
*  Remove Errors and Risks

Which also means that you gain the benefits of code tools such as:
*  Source control
*  Versioning
*  Shared team access
*  Project boards
*  Approval sign off
*  And any other tools you would use for software development governance

## Training Goals for day one
Though this workshop we will learn:
*  Which tools are needed, and how to install them on to our computers
*  How to configure MFA and AWS profiles for Terraform
*  How to use a named profile and assume a security role
*  How to layout a Terraform directory
*  How to create a Terraform template
*  How to add an AWS Provider
*  How to add an S3 bucket
*  The Terraform commands `plan`, `apply`, and `destroy`
*  How Terraform tracks the state of its resources


### NOTE
It is important to note that this tutorial assumes you have your own IAM User that has 
restricted permissions and MFA enabled (Which will use the local AWS profile name of `securityaccount`),
and a second role (and aws profile) that has more elevated permissions to run Terraform with called `terraformrole`. 
This could be within the same AWS Account, or across multiple AWS accounts.
If you haven't got this configured, then [start by doing that.](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html)

## Task One - Configure your workstation for using Terraform with AWS Assumed Roles and MFA
1.  Install `aws-vault` and `awscli` and `terraform`

    **For Mac via [brew](https://brew.sh/)**
    ```bash
    brew cask install aws-vault
    brew install awscli terraform
    brew upgrade awscli terraform
    ```
    **For Windows via [choco](https://chocolatey.org/docs/installation)**
    ```powershell
    choco install terraform awscli make
    Invoke-WebRequest -Uri "https://github.com/99designs/aws-vault/releases/download/v4.2.1/aws-vault-windows-386.exe" -OutFile "$PSScriptRoot/aws-vault-windows-386.exe"
    rename-item "$PSScriptRoot/aws-vault-windows-386.exe" aws-vault.exe
    Start-Process -Filepath "$PSScriptRoot/aws-vault.exe"
    $oldpath = (Get-ItemProperty -Path ‘Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment’ -Name PATH).path
    Set-ItemProperty -Path ‘Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment’ -Name PATH -Value "$PSScriptRoot/aws-vault.exe"
    ``` 

2.  Set up local credentials
    ```bash
    aws-vault add securityaccount
    ```


3.  On Mac edit `~/.aws/config` or on Windows edit `"%UserProfile%\.aws\config"`and add

    ```bash
    [profile securityaccount]
    region = eu-west-1
    [profile terraformrole]
    output = json
    region = eu-west-1
    role_arn = arn:aws:iam::<ASSUMED_ACCOUNT_ID>:role/TerraformRole
    source_profile = securityaccount
    mfa_serial = arn:aws:iam::<SECURITY_ACCOUNT_ID>:mfa/<AWSIAMUSERNAME>
    ```
    #### NOTE: Make sure you replace the parts with `<variable>` with your actual values.
    *  `ASSUMED_ACCOUNT_ID` is the AWS Account ID of the `terraformrole` that was created for using Terraform.
    *  `SECURITY_ACCOUNT_ID` is the AWS Account ID of the IAM User you use (it's fine for the assumed and security accounts to be the same)
    *  `AWSIAMUSERNAME` is the IAM username that you are using in your AWS security account.
    
    For more details on this setup read the [aws-vault usage guide](https://github.com/99designs/aws-vault/blob/master/USAGE.md).

4.  Test that it works:
    ```bash
    aws-vault exec terraformrole -- aws s3 ls
    ```

## Terraform formatting - to tidy up your code
```bash
terraform fmt .
```
If you use **[Visual Studio Code](https://code.visualstudio.com/download)** as your IDE then you can install the [Terraform Plugin](https://marketplace.visualstudio.com/items?itemName=mauve.terraform) to get syntax highlighting, code completion, and automatic formatting on file save. It works on Mac, Linux, and Windows.


## Terraform

This source folder has three Terraform files. 
*  [main.tf](./main.tf) 
   Which contains the resource `aws_s3_bucket` that will be created.
*  [variables.tf](./variables.tf)
   Which as two variable declaration
   -  `bucket_prefix` Which will hold the bucket name prefix that we will create
   -  `region` Which will specify which region we will create the provider in, which also dictates where the S3 bucket will be created.
*  [provider.tf](./provider.tf)
   Which specifies details about the AWS provider, in this case I give it the the value of the `region` variable.

In this directory is also a [Makefile](./Makefile) which I have created to simplify the running of commands.

When using `aws-vault` to assume a profile and run `terraform` commands you need to normally type in:
```bash
aws-vault exec terraformrole -- terraform init
aws-vault exec terraformrole -- terraform plan
aws-vault exec terraformrole -- terraform apply
```
But with the `Makefile` you can just type:
```bash
make init
make plan
make apply
```

## Workshop guide
*  Move the source code to your working directory from where you would like to work with Terraform
*  run `make init` and see what the difference is in your folder, a .terraform folder has been created. Take a look at those files
*  If you run `make plan` you will see that there will not be any actions, a difference vector is calculated and shown
*  Now run `make apply` and fill in your name as bucket prefix
*  Take another look at the .terraform folder and see how it changes
*  When the apply completes you will be presented with the outputs, which you will see the full bucket name. 
*  To check if the bucket was created, type:
   `aws-vault exec terraformrole -- aws s3 ls`
   Which will show a list of all your buckets, your bucket will start with `yourfirstname` and have a string of characters after it, such as `demo-oneHVHYNS87987JKJGHYFVJ8687687HJHB`
   I have done this because S3 buckets must be globally unique in the world, and so I used `bucket_prefix` in the `aws_s3_bucket` resource to append a random string to the bucket name. You can set a specific name to a bucket by using `bucket` instead of `bucket_prefix`.
*  This bucket will be used for the next demo, so don't destroy it just yet.
You can read more about the `aws_s3_bucket` resource [here](https://www.terraform.io/docs/providers/aws/r/s3_bucket.html)
To remove the bucket in the end of all demos type `make destroy`
* Now take another look at the .terraform folder


