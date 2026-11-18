#!/bin/bash
# CCE Cluster Bootstrap Script for DR Architecture
# 在 CCE 集群创建后执行

set -e

# 配置变量
SFS_ID=${SFS_ID:-"your-sfs-filesystem-id"}
CCE_CLUSTER_NAME=${CCE_CLUSTER_NAME:-"dr-cce-cluster"}

echo "=== CCE Cluster Bootstrap ==="
echo "SFS ID: $SFS_ID"
echo "CCE Cluster: $CCE_CLUSTER_NAME"

# 1. 安装 SFS CSI Driver (Helm)
echo "[1/4] Installing SFS CSI Driver..."
helm repo add huawei-cci https://huaweic.github.io/huaweicloud-cci-charts/
helm install cce-sfs-driver huawei-cci/sfs-csi-driver \
  --namespace kube-system \
  --set timeout=60s

# 2. 等待 CSI Driver 就绪
echo "[2/4] Waiting for CSI Driver..."
kubectl wait pod -l app=sfs-csi-driver -n kube-system \
  --for=condition=Ready --timeout=120s || true

# 3. 创建 StorageClass
echo "[3/4] Creating StorageClass..."
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: huawei-sfs
provisioner: driver.sfs.huaweicloud.com
parameters:
  backendType: "sfs"
  fileSystemId: "${SFS_ID}"
volumeBindingMode: Immediate
allowVolumeExpansion: true
EOF

# 4. 创建 PVC
echo "[4/4] Creating PVC..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-app-claim
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: huawei-sfs
  resources:
    requests:
      storage: 1Gi
EOF

echo "=== Bootstrap Complete ==="
echo "StorageClass and PVC created successfully"
