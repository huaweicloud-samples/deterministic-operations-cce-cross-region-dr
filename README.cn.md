# 多区域灾难恢复 (DR) 架构：华为云最佳实践

![License](https://img.shields.io/badge/license-MIT--0-blue.svg)

[English](./README.md)
![Huawei Cloud](https://img.shields.io/badge/华为云-最佳实践-ff4d00.svg)
![Terraform](https://img.shields.io/badge/Terraform->=1.5-7B42BC.svg)

> 华为云最佳实践（同构架构，非代码平移）

---

## 简介

基于华为云CCE + SFS构建的多区域灾难恢复 (DR) 架构。采用容器化微服务架构，通过跨区域文件存储同步实现有状态工作负载的高可用，适用于需要构建灾难恢复能力的企业。

---

## 目录

- [架构图](#架构图)
- [方案亮点](#方案亮点)
- [涉及云服务](#涉及云服务)
- [前置条件](#前置条件)
- [快速开始](#快速开始)
- [分步部署](#分步部署)
- [使用方法](#使用方法)
- [清理资源](#清理资源)
- [详细说明](#详细说明)
- [参考实现](#参考实现)
- [FAQ](#faq)
- [许可证](#许可证)
- [联系方式](#联系方式)

---

## 架构图

```
主区域 (Primary Region)
  │
  ├─ VPC (10.0.0.0/16)
  │   ├─ 公网子网 AZ1 (10.0.1.0/24)
  │   ├─ 公网子网 AZ2 (10.0.2.0/24)
  │   ├─ 私网子网 AZ1 (10.0.3.0/24)
  │   └─ 私网子网 AZ2 (10.0.4.0/24)
  │
  ├─ NAT Gateway (2个)
  ├─ CCE 集群
  │   └─ 节点池 (s6.large.2 x 2)
  │
  └─ SFS 文件系统
          │
          └─ 跨区域复制 ──► 灾难恢复区域

灾难恢复区域 (DR Region)
  │
  └─ VPC (10.0.0.0/16)
      ├─ CCE 集群
      └─ SFS 文件系统 (从主区域同步)
```

---

## 方案亮点

- **多区域部署**: 主区域 + 灾难恢复区域双活架构
- **容器化编排**: CCE 托管 Kubernetes 集群
- **文件存储同步**: SFS 跨区域复制实现数据同步
- **高可用**: 多可用区部署，自动故障转移
- **基础设施即代码**: Terraform 统一管理

---

## 涉及云服务

| 参照服务 | 华为云 | 状态 |
|---------|--------|------|
| EKS | CCE (云容器引擎) | 🟢 |
| EFS | SFS (弹性文件存储) | 🟢 |
| VPC | VPC | 🟢 |
| NAT Gateway | NAT 网关 | 🟢 |
| EC2 | ECS (弹性云服务器) | 🟢 |
| ELB | ELB | 🟢 |
| Security Group | 安全组 | 🟢 |

---

## 前置条件

- 华为云账号（已开通 CCE、SFS、VPC 服务）
- Terraform >= 1.5.0
- kubectl（用于 CCE 集群交互）
- Docker（用于镜像构建）

---

## 快速开始

```bash
# 进入基础设施目录
cd infra

# 初始化 Terraform
terraform init

# 预览部署计划
terraform plan

# 执行部署
terraform apply
```

---

## 分步部署

### 1. 配置凭证

```bash
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
export HW_REGION="cn-north-4"
```

### 2. 初始化

```bash
terraform init
```

### 3. 预览

```bash
terraform plan
```

### 4. 部署

```bash
terraform apply
```

---

## 使用方法

### 访问 CCE 集群

```bash
# 配置 kubeconfig
CCE_CLUSTER_ID=$(terraform output -raw primary_cce_cluster_id)

# 从 CCE 控制台获取凭据
```

### SFS 文件系统

```bash
# 获取 SFS ID
SFS_ID=$(terraform output -raw primary_sfs_id)

# 在 Kubernetes 中使用
kubectl apply -f storageclass.yaml
kubectl apply -f pvc.yaml
```

### 故障转移测试

1. 验证主区域应用正常运行
2. 触发故障转移
3. 验证 DR 区域应用接管
4. 执行故障恢复

---

## 清理资源

```bash
# 销毁所有资源
terraform destroy
```

**注意**: 销毁前请确保数据已备份。

---

## 详细说明

### 基础设施组件

1. **VPC**: 主区域和 DR 区域各一个 VPC
2. **子网**: 每个区域 4 个子网（2 公网 + 2 私网）
3. **NAT 网关**: 每个可用区一个
4. **CCE 集群**: 托管 Kubernetes 集群
5. **SFS**: 跨区域复制的文件存储
6. **安全组**: 网络访问控制

---

## 参考实现

- [huaweicloud terraform-provider](https://registry.terraform.io/providers/huaweicloud/huaweicloud) >= 1.60
- 华为云 CCE, SFS, VPC, ELB 服务

---

## FAQ

### Q: 如何配置跨区域复制？

A: 在 SFS 控制台创建复制策略，选择源文件和目标区域。

### Q: CCE 集群创建失败怎么办？

A: 检查 IAM 委托配置，确保有足够的权限创建集群。

### Q: 如何监控 DR 状态？

A: 使用 LTS 日志服务收集集群和应用日志。

---

## 许可证

MIT License

---

## 联系方式

如有问题，请在仓库中提交 Issue。
