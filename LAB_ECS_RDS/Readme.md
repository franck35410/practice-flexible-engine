# LAB: Deploying a phpmyadmin and attaching it to MySQL RDS

## Description

Deploying a phpmyadmin server accessible from Internet and attaching it to MySQL RDS.

Requested FE Services:

* 1 KeyPair
* 1 EIP
* 1 ECS
* 1 RDS
* 1 DAS login
* 1 VPC
* 2 Subnet
* 2 SG

## Targeted architecture

![Infra_ECS_RDS](images/Infra_ECS_RDS.png)

## Procedure

Follow these steps:

1. Key-pairs creation
1. Network creation
1. Security groups creation
1. Relational Database Service (RDS) creation
1. Data Admin Service (DAS): Add login
1. Data Admin Service-Console (DAS): Database Mysql creation
1. Elastic Cloud Server (ECS) creation
1. Connect to ECS
1. Phpmyadmin installation
1. Test
1. Resources deletion

## Key-pairs creation

Basic Informations:

* Name: **kp_stud0x**
* Download the private key file

## Network creation: Virtual Private Cloud (VPC) and Subnet creation

Basic Informations:

* Region: **eu-west-0/stud0x**
* Name: **vpc_stud0x**
* IPv4 CIDR Block: **192.168.0.0/16**
* Tag: key=**owner**;value=**stud0x**
* Description: **VPC for lab**
* Default Subnet:
  * Name: **subnet-front-stud0x**
  * IPv4 CIDR Block: **192.168.0.0/24**
  * Gateway: **192.168.0.1**
  * DNS Server Address: **100.125.0.41,100.126.0.41**
  * Tag: key=**owner**;value=**stud0x**
  * Description: **Front subnet for web server**  
* Add Subnet:
  * Name: **subnet-back-stud0x**
  * IPv4 CIDR Block: **192.168.1.0/24**
  * Gateway: **192.168.1.1**
  * DNS Server Address: **100.125.0.41,100.126.0.41**
  * Tag: key=**owner**;value=**stud0x**
  * Description: **Back subnet for web server**

## Security groups creation

Basic Informations:

* Name: **sg_front_stud0x**
* Template: **Custom**
* Description: **Web server SG**
  * Add  2 Inbound rules (Port **80**/Type **IPv4**/source **"0.0.0.0/0"**/Description **Allow HTTP from everywhere**; Port **22**/Type **IPv4**/source **"0.0.0.0/0"**/Description **Allow SSH from everywhere**)
* Name **sg_back_stud0x**
* Template: **Custom**
* Description: **RDS SG**
  * Add  1 Inbound rule (Port **3306**/Type **IPv4**/source **"sg_front_stud0x"**/Description **Allow MySQL(3306) from sg_front_stud0x (Web server)**)

## Relational Database Service (RDS) creation

Basic Informations:

* Region: **eu-west-0/stud0x**
* DB Instance Name: **rds_stud0x**
* DB Engine: **MySQL**
* DB Engine Version: **8.0**
* DB Engine Type: **Primary/Standby**
* Primary AZ: **eu-west-0a**
* Standby AZ: **eu-west-0b**
* Time Zone: **(UTC+01:00 Amsterdam,...)**
* Instance Class: **General-enhanced II**, **2vCPU/4GB**
* Storage Type: **Ultra-high I/O**
* Storage Space (GB): **40GB**
* Disk Encryption: **Disable**
* VPC: **vpc_stud000x**
  * Subnet: **subnet-back-stud0x**
  * @IP: **192.168.1.10**
* Security Group: **sg_back_stud0x**
* Administrator Passowrd: **P@ssword1234**
* Confirm Password: **P@ssword1234**
* Parameter Template: **Default-MySQL-8.0**
* Table Name: **Case insentitive**
* Tag: key=**owner**;value=**stud0x**

## Data Admin Service (DAS): Add login

Add Login:

* DB Engine: **MySQL**
* Source Database: **RDS**
* Check the DB:
  * DB Instance Name: **rds_stud0x**, DB Engine Version: **MySQL 8.0**, DB Instance Type: **Primary/Standby**
* Login Username: **root**
* Password: **P@ssword1234**
  * Test Connection: **Connection is successful.**
  * Check **Remenber Password**
* Collect Metadata Periodically: **Enabled**
* Show Executed SQL Statements : **Enabled**

## Data Admin Service-Console (DAS): Database Mysql creation

From DAS:

* **Log In** on the DB instance **rds_stud0x(192.168.1.10:3306)**

From DAS-Console:

* SQL Operations: **SQL Window**

  ```sql
  CREATE DATABASE formation;
  USE formation;
  CREATE TABLE student (
      FirstName varchar(255),
      EMail varchar(255));
  INSERT INTO student VALUES
  ("student01", "formation.orange.ocb.STUD0001@gmail.com"),
  ("student02", "formation.orange.ocb.STUD0002@gmail.com"),
  ("student03", "formation.orange.ocb.STUD0003@gmail.com"),
  ("student04", "formation.orange.ocb.STUD0004@gmail.com"),
  ("student05", "formation.orange.ocb.STUD0005@gmail.com"),
  ("student06", "formation.orange.ocb.STUD0006@gmail.com"),
  ("student07", "formation.orange.ocb.STUD0007@gmail.com"),
  ("student08", "formation.orange.ocb.STUD0008@gmail.com");
  ```

  * Execute SQL (F8)

## Elastic Cloud Server (ECS) creation

Basic Informations:

* Region: **eu-west-0/stud0x**
* AZ: **eu-west-0a**
* Flavor: **General-purpose**, **s6.small.1**
* Image: **Public image**
  * **OBS Ubuntu 22.04(40GB)**
* System Disk: **High I/O 40GB**
* Network: **vpc_stud0x (192.168.0.0/16), subnet-front-stud0x (192.168.0.0/24), Automatically assignIP address**
* Security Goup: **sg_front_stud0x**
* EIP: **Auto assign**
* Bandwith: **10 Mbit/s**
* ECS Name: **ecs_stud0x**
* Key pair: **kp_stud0x**
  * Check the box **I acknowledge that...**
* Cloud Backup and Recovery: **Do not use**
* Advanced Settings: **Configure now**
  * User Data: **As text**

    ```bash
    #!/bin/sh
    sudo apt update
    # Cloud user password initialization (useful for ECS Remote Login with English Keyboard, if required)
    sudo echo -e "P@ssword1234\nP@ssword1234" | passwd  cloud
    ```

* Tag: key=**owner**;value=**stud0x**

## Connect to ECS

Accessing the created ECS (use the EIP, keypair and the 'cloud' user, or ECS Remote Login): [Logging in to an ECS](https://docs.prod-cloud-ocb.orange-business.com/en-us/usermanual/ecs/en-us_topic_0092494193.html)

## Phpmyadmin installation

From ECS session launch this command:



### Phpmyadmin /Mysql authentification

From ECS session launch these commands:

```bash
sudo export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<<'phpmyadmin phpmyadmin/dbconfig-install boolean false'
sudo debconf-set-selections <<<'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'
sudo apt install libapache2-mod-php8.1 phpmyadmin -y
```


```bash
sudo cat <<EOF >/home/cloud/config-db.php
<?php
\$dbuser='root';
\$dbpass='P@ssword1234';
\$basepath='';
\$dbname='formation';
\$dbserver='192.168.1.10';
\$dbport='3306';
\$dbtype='mysql';
EOF

sudo cp /home/cloud/config-db.php /etc/phpmyadmin/

```

## Test

### Apache installation verification

http://\<EIP\>

### Verification of the interconnection of Phpmyadmin to the Mysql database

http://\<EIP\>/phpmyadmin

* User: **root**
* Password: **P@ssword1234**

**Note:** If *"phpmyadmin error count(): Parameter must be an array or an object that implements Countable"* go to:

[https://github.com/phpmyadmin/phpmyadmin/issues/14332](https://github.com/phpmyadmin/phpmyadmin/issues/14332)

## Resources deletion

Control the resources created:

* go to *Homepage* -> *Search for Services* -> *Service List*

Resources deletion:

1. Elastic Cloud Server (ECS)
1. Data Admin Service (DAS)
1. Relational Database Service (RDS)
1. Security Groups (SG)
1. Subnets
1. Virtual Private Cloud (VPC)
1. Key Pair
