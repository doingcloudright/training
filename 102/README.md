# Terraform And AWS Module (102)

## Overview
The VPC ( Virtual Private Cloud ) defines a virtual network for Amazon resources to work in. As with all private networks they are limited to use private netting only. You can find a list of private networks here: https://en.wikipedia.org/wiki/Private_network . This course module covers the creation of a VPC with Terraform and helps to explain how the parts are working together.

## Training Goals for this module
Though this module we will learn:
*  What the difference is between a Region and an Availability Zone
*  What the difference is between an Internet Gateway and a NAT Gateway
*  Why a distinction between private and public subnetting is important
*  How routing works inside the VPC
*  How redundant setups are spread across different availability zones.
*  How to manually setup a VPC, subnets and an Internet Gateway
*  How to use Terraform to accomplish the same thing

## Graphical overview of a VPC in action 
<img src="https://docs.aws.amazon.com/vpc/latest/userguide/images/nat-gateway-diagram.png"/>

## Regions and Availability zones
Each AWS Region is a separate geographic area. Each AWS Region has multiple, isolated locations known as Availability Zones (AZs), they are different datacenters within one of those regions (https://wikileaks.org/amazon-atlas/). Resources aren't replicated across AWS Regions unless you do so specifically. Examples of regions are eu-west-1 (Ireland), us-east-1 ( Virginia ) and eu-central-1 (Frankfurt). Example of different AZs are eu-central-1a, eu-central-1b, eu-central-1c. The naming allocation of those availability zones is different per AWS customer, to make sure that the usage of Availability zones is evenly spread.

<img src="https://filedb.experts-exchange.com/files/public/2015/8/30/e9d9aac8-3bfe-42d8-b115-f137b9c1140e.png"/>

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
*  0.0.0.0/0 is also called default, or everything else, meaning that if traffic has not matched any other routes it will fallback to this route.  
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

```hcl
variable "network_name" {
  default = "myvpc"
}

variable "network" {
  default = "10.10.0.0/16"
}

variable "availability_zones" {
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnets" {
  default = ["10.10.11.0/24", "10.10.12.0/24"]
}

variable "private_subnets" {
  default = ["10.10.4.0/24", "10.10.5.0/24"]
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.network}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.network_name}"
  }
}

resource "aws_subnet" "public" {
  count             = "${length(var.public_subnets)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(var.public_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  map_public_ip_on_launch = false

  tags {
    Name = "${var.network_name}-public-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count             = "${length(var.private_subnets)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(var.private_subnets, count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"

  map_public_ip_on_launch = false

  tags {
    Name = "${var.network_name}-private-${count.index}"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }

  tags {
    Name = "${var.network_name}-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.network_name}-private"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}
➜ 
```


1. Run `make init` to make sure that the module is being sourced
2. `make plan` will show you which resources are being created
3. `make apply` 
4. Check the VPC dashboard and see how it compares to what you did before
