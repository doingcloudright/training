# Terraform And AWS Module (102)

## Overview
The VPC ( Virtual Private Cloud ) defines a virtual network for Amazon resources to work in. As with all private networks they are limited to use private netting only. You can find a list of private networks here: https://en.wikipedia.org/wiki/Private_network . This course module covers the creation of a VPC with Terraform and helps to explain how the parts are working together.

<img src="https://docs.aws.amazon.com/vpc/latest/userguide/images/nat-gateway-diagram.png">

## Regions and Availability zones
Each AWS Region is a separate geographic area. Each AWS Region has multiple, isolated locations known as Availability Zones (AZs), they are different datacenters within one of those regions (https://wikileaks.org/amazon-atlas/). Resources aren't replicated across AWS Regions unless you do so specifically. Examples of regions are eu-west-1 (Ireland), us-east-1 ( Virginia ) and eu-central-1 (Frankfurt). Example of different AZs are eu-central-1a, eu-central-1b, eu-central-1c. The naming allocation of those availability zones is different per AWS customer, to make sure that the usage of Availability zones is evenly spread.

https://filedb.experts-exchange.com/files/public/2015/8/30/e9d9aac8-3bfe-42d8-b115-f137b9c1140e.png

## Manual Creation of a VPC

1. Go to VPC in the VPC dashboard.
2. Click on Your VPC's and click on Create VPC
2a. Give a name
2b. And give in an IPV4 CIDR block, an example CIDR block is 10.10.0.0/16, we call this the network

## Subnets
In this step we create 4 different subnets in two different availability zones.

1. Go to VPC in the VPC dashboard.
2. go to Subnets and click Create Subnets
2. Name this subnet left-public, and select the previously created VPC
3. The subnet needs to be smaller than the Network /16, a common use for a subnet is a /24. As example we use 10.10.1.0/24
4. Select an Availability Zone and click on create, write down which Availability zone you created this in
5. In the same availability zone create another subnet called left-private
6. Repeat all steps again, but for subnets named right-public and right-private in a different Availability Zone

Now you should have 4 different subnets, 2 in one AZ, and 2 in another.

## Route Tables, public and Private nets and the Internet Gateway.

Now we have 4 different subnets in two different availability zones. Out of security reasons, we created public- and private- naming to make a clear distinction which subnets are directly connected to the internet and which not.

1. Go to VPC and to Route Tables
2. Click on Create route table, name public, and select the created VPC
3. Click on Create route table, name private, and select the created VPC

In the overview you now have 2 different route tables, one for public, and one for private

1. Select the public route table
2. Go to subnet associations and click edit
3. Select the subnets with public label and press save
4. Repeat for the private route table

You have now created 2 route tables, one for public and one for private. If you take a look at the routes you will see that they both have the same routes. 
In the following step we will make sure that the public subnet can access the internet.


1. Go to Internet Gateways and click "Create Internet Gateway", give it a nice name and create it
2. In the overview you will see that the gatway has as state 'detached'. Select it and attach the gateway to your VPC.
3. Go back to route tables, to the public table and edit the routes, click Add another Route.
4. As destination fill in the network 0.0.0.0/0 with as target the internet gateway you made, press Save.
4a. 0.0.0.0/0 is also called default, or everything else, meaning that if traffic has not matched any other routes it will fallback to this route.
5. In the overview you will now see your route to the internet gateway.


## NAT Gateway Optional
With AWS it is common to create instances in the private subnet. When instances are not directly connected to the internet, flaws in firewalling will
not straight away become a disaster. However, most instances do need internet access, for example to access other services. A NAT gateway is made for that purpose, just as with office networks, it will translate TCP traffic from private networks to reach the public internet, it keeps a table of ongoing TCP Traffic to make sure that when TCP traffic comes back to the NAT it knows where to send traffic to.


1. Go to Subnet and write down the Subnet ID of a public Subnet
2. Go to NAT Gateways and click Create NAT Gateway
3. Fill in the ID of a public Subnet
4. Click on Create EIP ( Elastic IP Address )
5. Click Create a Nat Gateway
6. Edit Route tables
7. Edit your private route table and add another route
8. 0.0.0.0/0 with destination your recently create NAT gateway.

## Done!

You have now created a geographically distributed network with a distinction between public and private subnetting. Now we need to remove everything we made.
1. Go to Your VPCs, select your VPC and click Delete VPC
2. Go to Elastic IPs and disasociate the address


# Now we are going to do the same with Terraform. Go to your Terraform codebase and add the following, and edit.

```
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b" ] <- According to your region
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "Your Name"
  }
}
```


1. Take a look at https://github.com/terraform-aws-modules/terraform-aws-vpc
2. Run `make init` to make sure that the module is being sourced
3. `make plan` will show you which resources are being created
4. `make apply` 
5. Check the VPC dashboard and see how it compares to what you did before
