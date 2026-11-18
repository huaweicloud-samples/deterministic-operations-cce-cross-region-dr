# =============================================
# 华为云实践：多区域灾难恢复 (DR) 架构
# 基于容器 + 共享文件存储跨区域容灾参考架构适配
# IaC: Terraform + huaweicloud Provider
# =============================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = ">= 1.60"
    }
  }
}

# =====================
# 1. Primary Region VPC Network
# =====================
resource "huaweicloud_vpc" "primary" {
  name = "${var.stack_name}-primary-vpc"
  cidr = var.vpc_cidr
}

resource "huaweicloud_vpc_subnet" "primary_public_1" {
  name          = "${var.stack_name}-primary-public-az1"
  vpc_id        = huaweicloud_vpc.primary.id
  cidr          = "10.0.1.0/24"
  gateway_ip    = "10.0.1.1"
  primary_dns   = "100.125.1.250"
  secondary_dns = "100.125.129.250"
}

resource "huaweicloud_vpc_subnet" "primary_public_2" {
  name          = "${var.stack_name}-primary-public-az2"
  vpc_id        = huaweicloud_vpc.primary.id
  cidr          = "10.0.2.0/24"
  gateway_ip    = "10.0.2.1"
  primary_dns   = "100.125.1.250"
  secondary_dns = "100.125.129.250"
}

resource "huaweicloud_vpc_subnet" "primary_private_1" {
  name          = "${var.stack_name}-primary-private-az1"
  vpc_id        = huaweicloud_vpc.primary.id
  cidr          = "10.0.3.0/24"
  gateway_ip    = "10.0.3.1"
  primary_dns   = "100.125.1.250"
  secondary_dns = "100.125.129.250"
}

resource "huaweicloud_vpc_subnet" "primary_private_2" {
  name          = "${var.stack_name}-primary-private-az2"
  vpc_id        = huaweicloud_vpc.primary.id
  cidr          = "10.0.4.0/24"
  gateway_ip    = "10.0.4.1"
  primary_dns   = "100.125.1.250"
  secondary_dns = "100.125.129.250"
}

# =====================
# 2. DR Region VPC Network
# =====================
resource "huaweicloud_vpc" "dr" {
  name = "${var.stack_name}-dr-vpc"
  cidr = var.vpc_cidr
}

resource "huaweicloud_vpc_subnet" "dr_public_1" {
  name          = "${var.stack_name}-dr-public-az1"
  vpc_id        = huaweicloud_vpc.dr.id
  cidr          = "10.0.101.0/24"
  gateway_ip    = "10.0.101.1"
  primary_dns   = "100.125.1.250"
  secondary_dns = "100.125.129.250"
}

resource "huaweicloud_vpc_subnet" "dr_public_2" {
  name          = "${var.stack_name}-dr-public-az2"
  vpc_id        = huaweicloud_vpc.dr.id
  cidr          = "10.0.102.0/24"
  gateway_ip    = "10.0.102.1"
  primary_dns   = "100.125.1.250"
  secondary_dns = "100.125.129.250"
}

resource "huaweicloud_vpc_subnet" "dr_private_1" {
  name          = "${var.stack_name}-dr-private-az1"
  vpc_id        = huaweicloud_vpc.dr.id
  cidr          = "10.0.103.0/24"
  gateway_ip    = "10.0.103.1"
  primary_dns   = "100.125.1.250"
  secondary_dns = "100.125.129.250"
}

resource "huaweicloud_vpc_subnet" "dr_private_2" {
  name          = "${var.stack_name}-dr-private-az2"
  vpc_id        = huaweicloud_vpc.dr.id
  cidr          = "10.0.104.0/24"
  gateway_ip    = "10.0.104.1"
  primary_dns   = "100.125.1.250"
  secondary_dns = "100.125.129.250"
}

# =====================
# 3. Security Groups
# =====================
resource "huaweicloud_networking_secgroup" "primary" {
  name        = "${var.stack_name}-primary-sg"
  description = "DR Architecture Security Group - Primary Region"
}

resource "huaweicloud_networking_secgroup_rule" "primary_allow_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = huaweicloud_networking_secgroup.primary.id
  ports             = "80"
  protocol          = "tcp"
}

resource "huaweicloud_networking_secgroup_rule" "primary_allow_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = huaweicloud_networking_secgroup.primary.id
  ports             = "443"
  protocol          = "tcp"
}

resource "huaweicloud_networking_secgroup" "dr" {
  name        = "${var.stack_name}-dr-sg"
  description = "DR Architecture Security Group - DR Region"
}

resource "huaweicloud_networking_secgroup_rule" "dr_allow_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = huaweicloud_networking_secgroup.dr.id
  ports             = "80"
  protocol          = "tcp"
}

resource "huaweicloud_networking_secgroup_rule" "dr_allow_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = huaweicloud_networking_secgroup.dr.id
  ports             = "443"
  protocol          = "tcp"
}

# =====================
# 4. 待手动配置的资源 (Terraform 无法创建)
# =====================
# 说明：以下资源需要手动在控制台配置或在 IAM 委托配置完成后部署
# 
# 4.1 NAT Gateway - 需要账户状态正常
# resource "huaweicloud_nat_gateway_v2" "primary_nat_1" { ... }
# 
# 4.2 SFS 文件存储 - 需要 SFS 服务可用
# resource "huaweicloud_sfs_file_system_v2" "primary" { ... }
# 
# 4.3 CCE 集群 - 需要 IAM 委托配置
# resource "huaweicloud_cce_cluster" "primary" { ... }

# =====================
# 5. Outputs
# =====================
output "primary_region" {
  description = "Primary region"
  value       = var.primary_region
}

output "dr_region" {
  description = "DR region"
  value       = var.dr_region
}

output "primary_vpc_id" {
  description = "Primary VPC ID"
  value       = huaweicloud_vpc.primary.id
}

output "dr_vpc_id" {
  description = "DR VPC ID"
  value       = huaweicloud_vpc.dr.id
}

output "primary_sg_id" {
  description = "Primary Security Group ID"
  value       = huaweicloud_networking_secgroup.primary.id
}

output "dr_sg_id" {
  description = "DR Security Group ID"
  value       = huaweicloud_networking_secgroup.dr.id
}
