This directory has three Terraform files.
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

## Guide
*  To run demo_one and create the s3 bucket, type `make init` followed by `make apply`
*  You will be prompted on your screen to provide a value for `bucket_name`, call it: `demo-one`
*  To check if the bucket was created, type:
   `aws-vault exec terraformrole -- aws s3 ls`
   Which will show a list of all your buckets, your bucket will start with `demo-one` and have a string of characters after it, such as `demo-oneHVHYNS87987JKJGHYFVJ8687687HJHB`
   I have done this because S3 buckets must be globally unique in the world, and so I used `bucket_prefix` in the `aws_s3_bucket` resource to append a random string to the bucket name. You can set a specific name to a bucket by using `bucket` instead of `bucket_prefix`.
*  Outcomment everything in main.tf and do another make apply

You can read more about the `aws_s3_bucket` resource [here](https://www.terraform.io/docs/providers/aws/r/s3_bucket.html)
To remove the bucket in the end of all demos type `make destroy`
