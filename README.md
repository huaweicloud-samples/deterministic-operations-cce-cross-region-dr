# Multi-Region Disaster Recovery (DR) Architecture: Huawei Cloud Best Practices

![License](https://img.shields.io/badge/license-MIT--0-blue.svg)

[中文版](./README.cn.md)
![Huawei Cloud](https://img.shields.io/badge/Huawei%20Cloud-Best%20Practice-ff4d00.svg)
![Terraform](https://img.shields.io/badge/Terraform->=1.5-7B42BC.svg)

> Huawei Cloud Best Practice (Architecture-equivalent Replica, Not Code Translation)

---

## Introduction

Multi-region Disaster Recovery (DR) architecture built on Huawei Cloud CCE + SFS. Containerized microservices architecture with cross-region file storage synchronization for stateful workloads, suitable for enterprises requiring disaster recovery capabilities.

---

## Table of Contents

- [Architecture Diagram](#architecture-diagram)
- [Key Features](#key-features)
- [Cloud Services](#cloud-services)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Step-by-Step Deployment](#step-by-step-deployment)
- [Usage](#usage)
- [Cleanup](#cleanup)
- [Detailed Explanation](#detailed-explanation)
- [Dependencies](#dependencies)
- [FAQ](#faq)
- [License](#license)
- [Contact](#contact)

---

## Architecture Diagram

```
Primary Region
  │
  ├─ VPC (10.0.0.0/16)
  │   ├─ Public Subnet AZ1 (10.0.1.0/24)
  │   ├─ Public Subnet AZ2 (10.0.2.0/24)
  │   ├─ Private Subnet AZ1 (10.0.3.0/24)
  │   └─ Private Subnet AZ2 (10.0.4.0/24)
  │
  ├─ NAT Gateway (2)
  ├─ CCE Cluster
  │   └─ Node Pool (s6.large.2 x 2)
  │
  └─ SFS File System
          │
          └─ Cross-Region Replication ──► DR Region

DR Region
  │
  └─ VPC (10.0.0.0/16)
      ├─ CCE Cluster
      └─ SFS File System (synced from Primary)
```

---

## Key Features

- **Multi-Region Deployment**: Primary + DR region active-active architecture
- **Container Orchestration**: CCE managed Kubernetes cluster
- **File Storage Sync**: SFS cross-region replication for data synchronization
- **High Availability**: Multi-AZ deployment with automatic failover
- **Infrastructure as Code**: Terraform unified management

---

## Cloud Services

| Reference Service | Huawei Cloud | Status |
|-------------|--------------|--------|
| EKS | CCE (Cloud Container Engine) | 🟢 |
| EFS | SFS (Scalable File Service) | 🟢 |
| VPC | VPC | 🟢 |
| NAT Gateway | NAT Gateway | 🟢 |
| EC2 | ECS (Elastic Cloud Server) | 🟢 |
| ELB | ELB | 🟢 |
| Security Group | Security Group | 🟢 |

---

## Prerequisites

- Huawei Cloud account (CCE, SFS, VPC services enabled)
- Terraform >= 1.5.0
- kubectl (for CCE cluster interaction)
- Docker (for image building)

---

## Quick Start

```bash
# Enter infrastructure directory
cd infra

# Initialize Terraform
terraform init

# Preview deployment plan
terraform plan

# Execute deployment
terraform apply
```

---

## Step-by-Step Deployment

### 1. Configure Credentials

```bash
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
export HW_REGION="cn-north-4"
```

### 2. Initialize

```bash
terraform init
```

### 3. Plan

```bash
terraform plan
```

### 4. Apply

```bash
terraform apply
```

---

## Usage

### Accessing CCE Cluster

```bash
# Configure kubeconfig
CCE_CLUSTER_ID=$(terraform output -raw primary_cce_cluster_id)

# Get credentials from CCE console
```

### SFS File System

```bash
# Get SFS ID
SFS_ID=$(terraform output -raw primary_sfs_id)

# Use in Kubernetes
kubectl apply -f storageclass.yaml
kubectl apply -f pvc.yaml
```

### Failover Testing

1. Verify primary region application is running
2. Trigger failover
3. Verify DR region takes over
4. Perform failback

---

## Cleanup

```bash
# Destroy all resources
terraform destroy
```

**Note**: Ensure data is backed up before destruction.

---

## Detailed Explanation

### Infrastructure Components

1. **VPC**: One VPC for primary and DR regions
2. **Subnets**: 4 subnets per region (2 public + 2 private)
3. **NAT Gateway**: One per availability zone
4. **CCE Cluster**: Managed Kubernetes cluster
5. **SFS**: Cross-region replicated file storage
6. **Security Group**: Network access control

---

## Dependencies

- [huaweicloud terraform-provider](https://registry.terraform.io/providers/huaweicloud/huaweicloud) >= 1.60
- Huawei Cloud CCE, SFS, VPC, ELB services

---

## FAQ

### Q: How to configure cross-region replication?

A: Create replication policy in SFS console, select source file and target region.

### Q: What to do if CCE cluster creation fails?

A: Check IAM agency configuration, ensure sufficient permissions to create clusters.

### Q: How to monitor DR status?

A: Use LTS log service to collect cluster and application logs.

---

## License

MIT License

---

## Contact

For issues, please submit an Issue in the repository.
