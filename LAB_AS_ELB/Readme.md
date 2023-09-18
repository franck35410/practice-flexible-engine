# LAB: Deployment of an apache and AS/ELB configuration

## Description

Deploying a apache server with a Auto Scalling (AS) and Elastic Load Balance (ELB).

Requested FE Services:

* 1 KeyPair
* 2 EIP
* 2 ECS
* 1 IMS
* 1 ELB
* 1 AS
* 2 VPC
* 2 Subnets
* 2 SG

## Targeted architecture

![Infra_AS_ELB](images/Infra_AS_ELB.png)

## Procedure

Follow these steps:

1. Key-pairs creation
1. Network creation
1. Security groups creation
1. Elastic Cloud Server (ECS) creation
1. Private Image (IMS) creation
1. Elastic Load Balance (ELB) creation
1. Auto Scalling (AS) creation
1. Stress test
1. Resources deletion

## Key-pairs creation

Basic Informations:

* Name: **kp_stud0x**
* Download the private key file

## Network creation: Virtual Private Cloud (VPC) and Subnet creation

Basic Informations:

* Region: **Student Project**
* Name: **vpc_stud0x**
* CIDR Block: **192.168.0.0/16**
* Tag: key=**owner**;value=**stud0x**
* Default Subnet:
  * Name: **subnet-front-stud0x**
  * CIDR Block: **192.168.0.0/24**
  * Tag: key=**owner**;value=**stud0x**

## Security groups creation

Basic Informations:

* Name: **sg_front_stud0x**
* Template: **Custom**
* Manage Rule :
  * Add  2 Inbound rules (Port **80**/Type **IPv4**/source **"0.0.0.0/0"**/Description **Allow HTTP from everywhere**; Port **22**/Type **IPv4**/source **"0.0.0.0/0"**/Description **Allow SSH from everywhere**)
  
## Elastic Cloud Server (ECS) creation

Basic Informations:

* Region: **Student Project**
* AZ: **eu-west-0a**
* Flavor: **s3.small.1**
* Image: **Public image**
  * **OBS Ubuntu 22.04(40GB)**
* System Disk: **Common I/O 40GB**
* VPC: **vpc_stud0x**
* Primary NIC: **subnet-front-stud0x - Automatically assign IP address**
* Security Goup: **sg_front_stud0x**
* EIP: **Automatically assign**
* Bandwith: **1000 Mbit/s**
* ECS Name: **ecs_stud0x**
* Key pair: **kp_stud0x**
* Cloud Backup Recovery: **Do not use**
* Advanced Settings: **Configure now**
  * User Data: **As text**

    ```bash
    #!/bin/bash

    sudo apt update
    sudo apt install apache2 -y
    sudo systemctl restart apache2

    ```

* Tag: key=**owner**;value=**stud0x**
* No Agency

Apache installation verification:

http://\<EIP\>

## Private Image (IMS) creation

1. First off all, stop the stud0x ECS
1. Detach the EIP from the stud0x ECS
1. Private Image creation:

    * Basic Informations
      * Type: **System disk image**
      * Source: ECS: **ecs_stud0x**
      * Name: **img-ecs-stud0x**
        * Tag: key=**owner**;value=**stud0x**

## Elastic Load Balancer (ELB) creation

Basic Informations:

* Create Elastic Load Balancer
* Type: **Shared**
* Region:  **Student Project**
* Network Type: **Public network**
* VPC: **vpc_stud0x**
* Subnet: **subnet_front_stud0x**
* EIP: **Use existing** (select the EIP)
* Name: **elb_stud0x**
* Tag: key=**owner**;value=**stud0x**
* **Create Now**

* Select the ELB **elb_stud0x**
  * **Add Listeners**
  * Name: **listener_stud0x_web**
  * Frontend Protocol/Port: **HTTP/80**
  * Access Policy: **All IP addresses**
  * Timeout(s): **60**
  * Create new Backend Server Group: **server_group_http_stud0x**
  * Backend Protocol/Port: **HTTP**
  * Load Balancing Algorithm: **Weighted Round Robin**
  * Sticky Session: **no**
  * No Backend Servers
  * Health Check Protocol/Port: **HTTP/80**
  * Check Path: **/**
  * Interval (s): **5**
  * Timeout(s): **3**
  * Maximum Retries: **3**
* Select the ELB **elb_stud0x**
  * **Add Listeners**
  * Name: **listener_stud0x_ssh**
  * Frontend Protocol/Port: **TCP/22**
  * Access Policy: **All IP addresses**
  * Timeout(s): **300**
  * Create new Backend Server Group: **server_group_ssh_stud0x**
  * Backend Protocol/Port: **TCP**
  * Load Balancing Algorithm: **Weighted Round Robin**
  * Sticky Session: **yes**
  * Stickiness Duration (min): **5**
  * Health Check Protocol/Port: **TCP/22**
  * Interval (s): **5**
  * Timeout (s): **3**
  * Maximum Retries: **3**

## Auto Scaling (AS) creation

Basic Informations:

* Create AS Groups
  * Region: **Student Project**
  * AZ: **eu-west-0a and eu-west-0c**
  * Name: **as-group-stud0x**
  * Max. Instances: **3**
  * Expected Instances: **1**
  * Min. Instances: **1**
  * VPC: **vpc_stud0x**
  * Subnet: **subnet-front-stud0x**
  * Load Balancing: **Enhanced load balancer**
    * Load Balancer: **elb_stud0x**
    * Backend ECS Group: **ecs_group_ssh_stud0x**
    * Backend Port: 22
  * Load Balancing: **Add Load Balancer**
    * Load Balancer: **elb_stud0x**
    * Backend ECS Group: **ecs_group_http_stud0x**
    * Backend Port: 80
  * Instance Removal Policy: **Oldest Instance created from on the oldest AS configuration**
  * EIP: **Release**
  * Health Check Method: **ELB health check**
  * Health Check Interval: **15 minutes**
* ADD AS Configuration
  * AS Configuration: **Create**
  * Name: **as-config-stud0x**
  * Configuration Template: **Create a new template**
  * ECS Type: **s3.small.1**
  * **Private Image**
  * Image: **img-ecs-stud0x(40 GB)**
  * Disk: **Common I/O 40GB**
  * Security Goup: **sg_front_stud0x**
  * EIP: **Do not use**
  * Key Pair: **kp_stud0x**
  * Advanced Settings: **Configure now**
    * **As text**

    ```bash
    #!/bin/bash

    # Cloud user password initialization (useful for ECS Remote Login with English Keyboard, if required)
    sudo usermod -p $(openssl passwd -1 "P@ssword1234") "cloud"

    sudo sed -i -e "s/It works/$HOSTNAME \: It works/" /var/www/html/index.html

    ```

* Add AS Policy
  * Policy Name: **as-policy-cpu-usage**
  * Policy Type: **Alarm**
  * Alarm Rule: **Create**
  * Rule Name: **as-alarm-sup05**
  * Trigger Condition: **CPU Usage Avg. >= 5%**
  * Monitoring Interval: **5 minutes**
  * Consecutive Occurences: **1**
  * Scaling Action: **Add 1 instances**
  * Cooldown Period(s): **120**

Verification:
http://\<ELB EIP\>

### Stress Test - environnement deployment:

#### Virtual Private Cloud (VPC) and Subnet creation

Basic Informations:
* Region:  **Student Project**
* Name:  **vpc_bench_stud0x**
* Name: CIDR Block: **172.16.0.0/24**
* Tag key: **owner**; Tag value: **stud0x**
* Default Subnet:
  * Name: **subnet-bench-stud0x**
  * CIDR Block: **172.16.0.0/24**

#### ECS creation

Basic Informations:

* Region: **Student Project**
* AZ: **eu-west-0a**
* Flavor: **s3.xlarge.4**
* Image: **Public image**
  * **OBS Ubuntu 22.04(40GB)**
* System Disk: **Common I/O 40GB**
* VPC: **vpc_bench_stud0x**
* Primary NIC: **subnet-bench-stud0x**
* Security Goup: **sg_front_stud0x**
* EIP: **Automatically assign**
* Bandwith: **1000 Mbit/s**
* Key pair: **kp_stud0x**
* Cloud Backup Recovery: **Do not use**
* Advanced Settings: **Configure now**
  * User Data: **As text**

    ```bash
    #!/bin/bash

    sudo apt update
    sudo apt install apache2-utils -y

    # Cloud user password initialization (useful for ECS Remote Login with English Keyboard, if required)
    sudo usermod -p $(openssl passwd -1 "P@ssword1234") "cloud"
   
    ```

* Tag key: **owner**; Tag value: **stud0x**
* ECS Name: **ecs_bench_stud0x**

#### Connect to ECS

1. Accessing the created ECS  ecs_bench_stud0x (with ECS EIP) and Apache server (with ELB EIP): [Logging in to an ECS](https://docs.prod-cloud-ocb.orange-business.com/en-us/usermanual/ecs/en-us_topic_0092494193.html)
1. From Apache server session launch this command:

    ```shell
    top
    ```

1. From ECS  ecs_bench_stud0x session launch this command after replacing \<ELB EIP\> with the right EIP:

    ```shell
    while (true); do ab -k -n 30000000 -c 1000 http://<ELB EIP>/index.html || break; done
    ```

1. Notice the cpu consumption increase on Apache server and also the CPU Usage of AS GROUPs *as-group-stud0x* (AS GROUPS + as-group-stud0x + Monitoring) .
1. After few minutes, notice the increase of Number of instances (AS GROUPS + as-group-stud0x + Monitoring).
1. stop the **ecs_bench_stud0x**
1. In a HTTP navigator reload several time the page http://\<ELB EIP\>, and notice the change of ECS in the top of the page

## Resources deletion

Control the resources created:

* go to *"My Resources"*

Resources deletion:

1. Auto Scaling (AS)
    * Modify the AS Group configuration
      * Expected Instances: 0
      * Min. Instances: 0
1. Image Management Service (IMG)
1. Elastic Cloud Server (ECS)
1. Auto Scaling
    * AS Groups
    * AS Configuration
1. Elastic Load Balance (ELB)
1. Security Groups (SG)
1. Subnets
1. Virtual Private Cloud (VPC)
