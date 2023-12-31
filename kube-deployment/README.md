## Kubernetes

### Installing K3s

Master Node:
```BASH
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --token xxx-some-strong-key-xxx --bind-address 192.168.178.201 --disable-cloud-controller
```

Worker Nodes:
```BASH
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.178.201.10:6443 K3S_TOKEN=xxx-some-strong-key-xxx sh -
```

### Configuring the NFS
```BASH
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=192.168.178.203 --set nfs.path=/storage --create-namespace --namespace nfs
```

### Install ingress-nginx
```BASH
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/baremetal/deploy.yaml
kubectl apply -f ingress.nginx.yml
```
