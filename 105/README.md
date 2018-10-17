
# Terraform And AWS Module (105)

## Overview
EC2 is how AWS started. In this module we go through a few of the resources which are available inside EC2. Security Groups, and EC2 instances.

## Training Goals for this module
Though this module we will learn:
*  What an AMI is
*  How to create a Security Group in the AWS Console
*  How to create an instance based of an AMI
*  How to use userdata to execute commands on the instance at boot-time
*  How to use Terraform to achieve the exact same.


## What is a security group

"A security group acts as a virtual firewall for your instance to control inbound and outbound traffic. When you launch an instance in a VPC, you can assign up to five security groups to the instance. Security groups act at the instance level, not the subnet level. Therefore, each instance in a subnet in your VPC could be assigned to a different set of security groups. If you don't specify a particular group at launch time, the instance is automatically assigned to the default security group for the VPC."

Simpler said, a security group is a set of Firewall rules for both incoming and outgoing traffic. Outgoing traffic firewall rules can be applied to limit the access of an instance to other resources or to the internet for security reasons. Incoming Firewall rules are to clearly specify what traffic can flow through the security group to the insetance, and what not.


1. Go to the EC2 Dashboard
2. Go to Security Groups
3. Click Create Security Group
4. Name: web-incoming
5. Description: web-incoming
6. VPC: Yours

Now you have created a Firewall rule with no rules. By default a security group has as policy DENY. This means that this security group applied to an instance will not allow traffic.


## Apply Security Group to a webserver
AMI's are ( Amazon Machine Images) these are prebaked Virtual Machines, and can be provided by third parties. Using third party AMI's comes with a risk, more about that later.
For this demo we will use a machine image made by bitnami.

1. Go to the EC2 Dashboard
2. Go to AMIs
3. Select Public images
4. Fill the search with `bitnami-nginx-1.14.0-1-linux-debian-9-x86_64-hvm-ebs`
5. Right click the AMI and select Launch
6. As instance type we take t2.micro
7. Click configure instance details
8. Make Sure the right VPC is selected
9. A public subnet should be used for this isntance
10. Auto-assign Public IP, should be marked enabled
11. Go to advanced in the bottom and fill the userdata
```bash
#!/bin/bash
echo "Hello World!" > /opt/bitnami/nginx/html/index.html
```
12. Click Review&Launch
13. Edit the security groups, click Select an existing security group
14. Select web-incoming
15. Edit Tags, Add Tag, with key: Name and value : webserver
16. review & launch & ignore the warning, continue & Launch
17. Proceed without a keypair

```In the EC2 dashboard you wil now find your EC2 instance. You will see it has both a private subnet IP address but also a IPv4 Public IP assigned. When the instance is done initializing, try to access the instance in your browser with that ip address.

18. That didn't work out right. Let's go back to security groups and add a rule for web traffic, port 80
19. Go to Security Groups
20. Select web-incoming and edit Inbound
21. Add a custom TCP rule with port 80 and source anywhere

Take a look at your browser again. You will now be able to reach your instance ! 

22. Destroy your instance, and security group!

## Terraform
1. Take a look at the source folder, and implement this module in your own stack
