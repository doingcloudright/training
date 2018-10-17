# Course Modules

## 101

This introductory module starts of with setting up Terraform and aws-vault on your workstation. With help of a Makefile, Terraform will be instructed to create a S3 Bucket. H/T to https://github.com/Jamie-BitFlight for providing this module.

## 102

The VPC ( Virtual Private Cloud ) defines a virtual network for Amazon resources to work in. As with all private networks they are limited to use private netting only. You can find a list of private networks here: https://en.wikipedia.org/wiki/Private_network . This course module covers the creation of a VPC with Terraform and helps to explain how the parts are working together.

## 103

Terraform is not strict in how developers name their files. Through the years however, common patterns have become mainstream. This module adds another terraform file we can use for variables.

## 104

Terraform Modules are used to bundle terraform code and to make it easy to re-use them. Module code looks the same as regular terraform code. In this module you will see how to make a module and how to use it.

## 105

EC2 is how AWS started. In this module we go through a few of the resources which are available inside EC2. Security Groups, and EC2 instances.

## 106

A Single Instance as a production webserver will not provide an up-time guarantee one would need. Autoscaling Groups and Load Balancers come into play in this module. They are the tools which convert pets into cattle.
