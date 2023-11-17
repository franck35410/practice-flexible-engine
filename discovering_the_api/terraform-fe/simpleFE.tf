# Provider Settings
## flexibleengine
#------------------
terraform {
  required_providers {
    flexibleengine = {
      source = "FlexibleEngineCloud/flexibleengine"
      version = "1.43.0"
    }
  }
}
provider "flexibleengine" {
  user_name    = "${var.USERNAME}"
  password     = "${var.PASSWORD}"
  auth_url     = "${var.authurl}"
  domain_id    = "${var.DOMAIN_ID}"
}

# Creating Network elements
## router / network / subnet
## attach router<->subnet
#---------------------------
resource "flexibleengine_vpc_v1" "api-tffe-vpc" {
  name             = "api-tffe-vpc"
  cidr             = "192.168.0.0/24"
#  external_gateway = "0a2228f2-7f8a-45f1-8e09-9039e1d09975"
}

resource "flexibleengine_networking_network_v2" "api-tffe-net" {
  name = "api-tffe-net"
  admin_state_up = "true"
  region = "${var.region}"
}

resource "flexibleengine_networking_subnet_v2" "api-tffe-subnet" {
  name = "api-tffe-subnet"
  network_id = "${flexibleengine_networking_network_v2.api-tffe-net.id}"
  cidr = "192.168.0.0/24"
  gateway_ip = "192.168.0.1"
  dns_nameservers = ["100.125.0.41","100.126.0.41"]
  ip_version = 4
  region = "${var.region}"
}

resource "flexibleengine_networking_router_interface_v2" "router_interface_1" {
  router_id = "${flexibleengine_vpc_v1.api-tffe-vpc.id}"
  subnet_id = "${flexibleengine_networking_subnet_v2.api-tffe-subnet.id}"
}

# Create Security Group
## & Create Rules for SG
#-----------------------

resource "flexibleengine_networking_secgroup_v2" "api-tffe-sg" {
  name = "api-tffe-sg"
  description = "my security group made by terraform with flexibleengine provider"
  delete_default_rules = "true"
}

resource "flexibleengine_networking_secgroup_rule_v2" "tffe_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${flexibleengine_networking_secgroup_v2.api-tffe-sg.id}"
}

resource "flexibleengine_networking_secgroup_rule_v2" "tffe_rule_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${flexibleengine_networking_secgroup_v2.api-tffe-sg.id}"
}


resource "flexibleengine_networking_secgroup_rule_v2" "tffe_rule_3" {
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${flexibleengine_networking_secgroup_v2.api-tffe-sg.id}"
}

# Create EIP(floating+bandwidth FE API)
# Create port (nic)
# Bind floating IP & Port
# Create instance (ECS)
#-------------------------

resource "flexibleengine_vpc_eip_v1" "api-tffe-eip" {
  publicip {
    type             = "5_bgp"
    port_id          = "${flexibleengine_networking_port_v2.api-tffe-port.id}"
  }
  bandwidth {
    name             = "api-tffe-bandwidth"
    size = 100
    share_type       = "PER"
    charge_mode      = "traffic"
  }
}

resource "flexibleengine_networking_port_v2" "api-tffe-port" {
  name               = "api-tffe-port"
  fixed_ip {
    subnet_id        = "${flexibleengine_networking_subnet_v2.api-tffe-subnet.id}"
    ip_address       = "192.168.0.10"
  }
  network_id         = "${flexibleengine_networking_network_v2.api-tffe-net.id}"
  admin_state_up     = "true"
  security_group_ids = ["${flexibleengine_networking_secgroup_v2.api-tffe-sg.id}"]
}

resource "flexibleengine_compute_instance_v2" "api-tffe-ecs" {
  availability_zone = "${var.az}"
  region            = "${var.region}"
  name              = "ecs-api-terraformFEc"
  image_name        = "OBS Ubuntu 18.04"
  flavor_id         = "s3.large.2"
  key_pair          = "${var.key_pair}"
  network {
    port = "${flexibleengine_networking_port_v2.api-tffe-port.id}"
  }
}
