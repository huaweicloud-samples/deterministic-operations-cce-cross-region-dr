# 架构说明：跨区域容灾（CCE + SFS）

## 参照架构

```
┌─────────────────────────────────────────────────────────────┐
│                      Primary Region                          │
│  ┌──────────────┐    ┌──────────────────────────────────┐ │
│  │     EKS      │    │           EFS                     │ │
│  │  Cluster     │───►│  (跨区域复制)                     │ │
│  └──────────────┘    └──────────────┬───────────────────┘ │
│        │                            │                       │
│        └──────────┬─────────────────┘                       │
│                   ▼                                          │
│            ALB / NLB                                        │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    ▼
              User Traffic
```

## 华为云适配架构

```
┌─────────────────────────────────────────────────────────────┐
│                   主区域 (cn-north-4)                       │
│  ┌──────────────┐    ┌──────────────────────────────────┐ │
│  │     CCE      │    │           SFS                     │ │
│  │  集群        │───►│  (跨区域复制)                     │ │
│  └──────────────┘    └──────────────┬───────────────────┘ │
│        │                            │                       │
│        └──────────┬─────────────────┘                       │
│                   ▼                                          │
│              ELB                                            │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    ▼
              User Traffic
```

## 核心差异

| 参照组件 | 华为云组件 | 说明 |
|---------|-----------|------|
| EKS | CCE | 云容器引擎，完全托管 K8s |
| EFS | SFS | 弹性文件存储，支持 NFS |
| ALB/NLB | ELB | 负载均衡服务 |
| VPC | VPC | 虚拟私有云 |

## 多区域 DR 策略

1. **主区域**: 运行生产工作负载
2. **灾难恢复区域**: 待机状态，通过 SFS 同步数据
3. **故障转移**: 主区域故障时，切换到 DR 区域
4. **故障恢复**: 主区域恢复后，同步数据并切回

## Kubernetes 集成

使用 SFS CSI Driver 在 Kubernetes 中动态创建 PersistentVolume：

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: huawei-sfs
provisioner: driver.sfs.huaweicloud.com
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sfs-pvc
spec:
  storageClassName: huawei-sfs
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
```
