# LAB: Deploying a phpmyadmin and attaching it to MySQL RDS

## Description

Deploying a phpmyadmin server accessible from Internet and attaching it to MySQL RDS.

Requested FE Services:
* 1 KeyPair
* 1 EIP
* 1 ECS
* 1 RDS
* 1 VPC
* 2 Subnet
* 2 SG

## Targeted architecture 
![Infra_ECS_RDS](images/Infra_ECS_RDS.png)

## Procedure

Follow these steps:
1. Key-pairs creation
2. Network creation
3. Security groups creation
4. Relational Database Service (RDS) creation
5. Elastic Cloud Server (ECS) creation
6. Connect to ECS
7. Database Mysql creation
8. Phpmyadmin installation 
9. Test
10. Resources deletion

## Key-pairs creation

Basic Informations:
* Name: **kp_stud000x**
* Download the private key file

## Network creation: Virtual Private Cloud (VPC) and Subnet creation 

Basic Informations:
* Region: **Student Project**
* Name: **vpc_stud000x**
* CIDR Block: **192.168.0.0/16**
* Tag: key=**owner** ;value=**stud000x**
* Default Subnet: 
  * AZ: **eu-west-0a**
  * Name: **subnet-front-stud000x**
  * CIDR Block: **192.168.0.0/24**
  * Tag: key=**owner** ;value=**stud000x**  
* Add Subnet: 
  * AZ: **eu-west-0b**
  * Name: **subnet-back-stud000x**
  * CIDR Block: **192.168.100.0/24**
  * Tag: key=**owner** ;value=**stud000x**

## Security groups creation

Basic Informations:
* Name: **sg_front_stud000x**
  * Add  2 Inbound rules (Port **80**/source **"0.0.0.0/0"**; Port **22**/source **"0.0.0.0/0"**)
* Name **sg_back_stud000x**
  * Add  1 Inbound rule (Port **3306**/source **"sg_front_web_stud000x"**)

## Relational Database Service (RDS) creation

Basic Informations:
* Region: **Student Project**
* DB Instance Name: **rds_stud000x**
* DB Engine: **MySQL** 
* DB Engine Version: **5.7**
* DB Engine Type: **Primary/Standby**
* Primary AZ: **eu-west-0b**
* Standby AZ: **eu-west-0a**
* Instance Class: **1vCPU/4GB**
* Storage Type: **Common I/O**
* Storage Space (GB): **40GB**
* VPC: **vpc_stud000x**
  * Subnet: **subnet-back-stud000x**
* Security Group: **sg_back_stud000x**
* Administrator Passowrd: **P@ssword1234**
* Confirm Password: **P@ssword1234**
* Parameter Template: **Default-MySQL-5.7**
* Tag: key=**owner** ;value=**stud000x**

  
## Elastic Cloud Server (ECS) creation

Basic Informations:
* Region: **Student Project**
* AZ: **eu-west-0a**
* Flavor: **s3.small.1**
* Image: **Public image**
  * **OBS Ubuntu 18.04(40GB)**
* Disk: **Common I/O 40GB**
* VPC: **vpc_stud000x**
* Primary NIC: **subnet-front-stud000x**
* Security Goup: **sg_front_stud000x**
* EIP: **Automatically assign**
* Bandwith: **1000 Mbit/s**
* Key pair: **kp_stud000x**
* Advanced Settings: **Do not Configure**
* ECS Name: **ecs_stud000x**

## Connect to ECS

Accessing the created ECS (use the EIP, keypair and the 'cloud' user): [Logging in to an ECS](https://docs.prod-cloud-ocb.orange-business.com/en-us/usermanual/ecs/en-us_topic_0092494193.html)

## Database Mysql creation 
Downloading files, from ECS session launch these 2 commands:
```
curl -o importMySQL.sql https://obs-formation-imt.oss.eu-west-0.prod-cloud-ocb.orange-business.com/obs-imt-lab1/importMySQL.sql
curl -o config-db.php https://obs-formation-imt.oss.eu-west-0.prod-cloud-ocb.orange-business.com/obs-imt-lab1/config-db.php
```

Edit the *config-db.php* file and customize *$dbserver* value  with your **PRIVATE IP RDS**:
```
sudo apt-get update
sudo apt-get install mysql-client -y
```

* Restart services during package upgrades without asking? **YES**

Launch this command after replacing *<@IP RDS>* with your **PRIVATE IP RDS**:
```
sudo mysql -u root --password -h <@IP RDS> -P 3306 <importMySQL.sql
```

* Enter the RDS administrator password **P@ssword123**

## Phpmyadmin installation 

### Phpmyadmin installation

From ECS session launch this command:
```
sudo apt-get install phpmyadmin -y
```
* Select **apache2** with space bar
* Configure database for phpmyadmin with dbconfig-common? **No**

### Phpmyadmin /Mysql authentification

From ECS session launch these commands:
```
sudo cp /etc/phpmyadmin/config-db.php /etc/phpmyadmin/config-db.php.org
sudo cp /home/cloud/config-db.php /etc/phpmyadmin/
```

## Test

### Apache installation verification
*http://\<EIP\>*


### Verification of the interconnection of Phpmyadmin to the Mysql database

*http://\<EIP\>/phpmyadmin*
* User: **root**
* Password: **P@ssword123**

**Note:** If *"phpmyadmin error count(): Parameter must be an array or an object that implements Countable"* go to: 

https://github.com/phpmyadmin/phpmyadmin/issues/14332



## Resources deletion
Control the resources created:
* go to *"My Resources"*

Resources deletion:
1. Elastic Cloud Server (ECS)
2. Relational Database Service (RDS)
3. Security Groups (SG)
4. Subnets
5. Virtual Private Cloud (VPC)

