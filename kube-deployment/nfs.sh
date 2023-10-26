helm repo add nfs-subdir-external-provisioner <https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/>
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner --set nfs.server=192.168.178.203 --set nfs.path=/storage --create-namespace --namespace nfs

