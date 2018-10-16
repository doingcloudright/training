# EC2 Autoscaling groups and Load Balancers

In this module you will learn
* What autoscaling groups are
* How they relate to a launch configuration
* How to connect a Classic AWS Load balancer to an Autoscaling Group


## What is an Autoscaling Group


"An Auto Scaling group contains a collection of EC2 instances that share similar characteristics and are treated as a logical grouping for the purposes of instance scaling and management. For example, if a single application operates across multiple instances, you might want to increase the number of instances in that group to improve the performance of the application, or decrease the number of instances to reduce costs when demand is low. You can use the Auto Scaling group to scale the number of instances automatically based on criteria that you specify, or maintain a fixed number of instances even if an instance becomes unhealthy. This automatic scaling and maintaining the number of instances in an Auto Scaling group is the core functionality of the Amazon EC2 Auto Scaling service."

An Autoscaling Group defines the size of the collection of underlying instances and can have Autoscaling Policies applied on top of it. The Autoscaling Group has as parameter the Launch Configuration ( or Launch Template ).


## What is a Launch Configuration

"A launch configuration is a template that an Auto Scaling group uses to launch EC2 instances. When you create a launch configuration, you specify information for the instances such as the ID of the Amazon Machine Image (AMI), the instance type, a key pair, one or more security groups, and a block device mapping. If you've launched an EC2 instance before, you specified the same information in order to launch the instance."
A launch configuration cannot be modified once it's made. To make changes a new launch configuration needs to be made with the changes applied.


# Create Two security groups
1. Create one security Group called loadbalancer, and allow port 80 public to 0.0.0.0/0
2. Create one another security group called webserver, and allow port 80 from the loadbalancer SG

## Creating a Launch Configuration
1. Go to the EC2 Dashboard
2. Go to Launch Configurations
3. Click Create Launch Configuration
4. Click Community Ami's and fill  `bitnami-nginx-1.14.0-1-linux-debian-9-x86_64-hvm-ebs`
5. Select t2.micro and click configure details
6. Name: webserver-lauch-config-1
7. Click Advanced Details
9. And fill the same userdata as we did before
```bash
#!/bin/bash
echo "Hello World!" > /opt/bitnami/nginx/html/index.html
```
10. We leave "IP Address Type" disabled
11. Skip Storage
12. For security group select the created webserver security Group
13. Continue creation without a keypair

## Creating an Autoscaling Group
1. Go to the EC2 Dashboard
2. Go to Autoscaling Groups
3. Select Launch Configuration & Use an existing launch configuration
4. Scroll Down and select the launch configuration you just made
5. Name: Webserver-ASG
6. Network: Your VPC
7. Subnet: Select all Private Subnets!
8. Click configure scaling policies
9. Keep this group at its initial size
10. Continue to tags: and Create your first Autoscaling Group

