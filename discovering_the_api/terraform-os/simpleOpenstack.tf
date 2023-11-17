# Provider Settings
## openstack
#------------------
terraform {
  required_providers {
    flexibleengine = {
      source = "FlexibleEngineCloud/flexibleengine"
      version = "1.43.0"
    }
  }
}
provider "openstack" {
  user_name    = "${var.USERNAME}"
  password     = "${var.PASSWORD}"
  auth_url     = "${var.authurl}"
  domain_id    = "${var.DOMAIN_ID}"
}


# Creating Network elements
## router / network / subnet
## attach router<->subnet
#----------------------------

resource "openstack_networking_router_v2" "api-tfos-vpc" {
  name             = "api-tfos-vpc"
  external_gateway = "0a2228f2-7f8a-45f1-8e09-9039e1d09975"
}

resource "openstack_networking_network_v2" "api-tfos-net" {
  name = "api-tfos-net"
  admin_state_up = "true"
  region = "${var.region}"
}
resource "openstack_networking_subnet_v2" "api-tfos-subnet" {
  name = "api-tfos-subnet"
  network_id = "${openstack_networking_network_v2.api-tfos-net.id}"
  cidr = "192.168.0.0/24"
  gateway_ip = "192.168.0.1"
  dns_nameservers = ["100.125.0.41","100.126.0.41"]
  ip_version = 4
  region = "${var.region}"
}
resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = "${openstack_networking_router_v2.api-tfos-vpc.id}"
  subnet_id = "${openstack_networking_subnet_v2.api-tfos-subnet.id}"
}

# Create Security Group
## & Create Rules for SG
#-----------------------

resource "openstack_networking_secgroup_v2" "api-tfos-sg" {
  name = "api-tfos-sg"
  description = "my security group made by terraform with Openstack provider"
  delete_default_rules = "true"
}

resource "openstack_networking_secgroup_rule_v2" "tfos_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.api-tfos-sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "tfos_rule_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.api-tfos-sg.id}"
}


resource "openstack_networking_secgroup_rule_v2" "tfos_rule_3" {
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.api-tfos-sg.id}"
}

# Create floating IP (EIP)
# Create port (nic)
# Bind floating IP & Port
# Create instance (ECS)
#-------------------------

resource "openstack_networking_floatingip_v2" "api-tfos-eip" {
  pool = "admin_external_net"
  region = "${var.region}"
  port_id = "${openstack_networking_port_v2.api-tfos-port.id}"
}

resource "openstack_networking_port_v2" "api-tfos-port" {
  name               = "api-tfos-port"
  fixed_ip {
    subnet_id        = "${openstack_networking_subnet_v2.api-tfos-subnet.id}"
    ip_address       = "192.168.0.10"
  }
  network_id         = "${openstack_networking_network_v2.api-tfos-net.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_networking_secgroup_v2.api-tfos-sg.id}"]
}

resource "openstack_compute_instance_v2" "api-tfos-ecs" {
  availability_zone = "${var.az}"
  region            = "${var.region}"
  name              = "ecs-api-terraformOS"
  image_name        = "OBS Ubuntu 18.04"
  flavor_id         = "s3.large.2"
  key_pair          = "${var.key_pair}"
  network {
    port = "${openstack_networking_port_v2.api-tfos-port.id}"
  }
}
