# 部署指南：多区域 DR 架构

## 概述

本文档详细说明如何在华为云上部署多区域灾难恢复架构。

## 前置条件

1. 华为云账号
2. 已开通以下服务：
   - CCE (云容器引擎)
   - SFS (弹性文件存储)
   - VPC
   - ELB
   - NAT 网关

## 部署步骤

### 步骤 1: 准备环境

```bash
# 安装 Terraform
brew install terraform

# 配置华为云凭证
export HW_ACCESS_KEY="your-access-key"
export HW_SECRET_KEY="your-secret-key"
```

### 步骤 2: 初始化

```bash
cd infra
terraform init
```

### 步骤 3: 预览计划

```bash
terraform plan
```

### 步骤 4: 部署

```bash
terraform apply
```

### 步骤 5: 验证部署

```bash
# 查看输出
terraform output

# 验证 CCE 集群状态
kubectl get nodes -A
```

## 配置说明

### 区域配置

默认配置：
- 主区域: cn-north-4 (华北-北京四)
- DR 区域: cn-east-3 (华东-上海一)

如需修改，编辑 `variables.tf`:

```hcl
variable "primary_region" {
  default = "cn-north-4"
}

variable "dr_region" {
  default = "cn-east-3"
}
```

### 节点配置

默认节点规格: s6.large.2 (2vCPU/4GB)

如需修改，编辑 `main.tf`:

```hcl
resource "huaweicloud_cce_node_pool" "primary" {
  flavor_id = "s6.large.2"  # 修改为需要的规格
}
```

## 部署后操作

### 1. 配置 SFS 跨区域复制

1. 登录华为云控制台
2. 进入 SFS 控制台
3. 选择主区域文件系统
4. 创建复制策略，选择目标区域

### 2. 部署示例应用

```bash
kubectl apply -f application.yaml
```

### 3. 配置故障转移

详见 Kubernetes 文档中的故障转移配置。

## 清理资源

```bash
terraform destroy
```

**警告**: 销毁操作不可恢复，请确保数据已备份。
