# Kubernetes Homelab Stack

This directory contains the documentation and core manifests for the k3s cluster.

## Architecture

- **Distribution:** K3s (v1.30.1+k3s1)
- **Nodes:** 4x Raspberry Pi (pinode01-04)
- **Networking:** Dual-stack (IPv4/IPv6) on local physical network (`192.168.0.x`).
- **Access:** Managed via Tailscale (connection) and Cloudflare Tunnel (external exposure).

## Core Components

The following components are managed via Ansible but manifests are provided in `core/` for reference:

1.  **Traefik:** Default k3s ingress controller (Dual-stack enabled).
2.  **Cert-Manager:** Automated TLS certificates via Cloudflare DNS-01 challenge.
3.  **External-DNS:** Automatically syncs Ingress hosts with Cloudflare DNS records.
4.  **Cloudflare Tunnel:** Securely exposes `*.akrami.xyz` to the internet.

## Management

### Ansible Setup
To re-deploy or update the cluster, use the playbooks in the `ansible/` directory:

```bash
# Apply baseline (cgroups, dependencies, forwarding)
ansible-playbook -i inventory/tailscale_hosts.sh playbooks/baseline.yml

# Install/Update K3s and Core Apps
ansible-playbook -i inventory/tailscale_hosts.sh playbooks/setup_k3s.yml -e @playbooks/k3s_vars.yml
```

### Direct Access
Access the cluster using `kubectl` from your local machine using the provided kubeconfig. Note that since we are connecting via Tailscale, you need to skip TLS verification:
```bash
export KUBECONFIG=kubernetes/kubeconfig
kubectl get nodes --insecure-skip-tls-verify
```

## Legacy Configuration
The old manifests and previous setup files have been moved to the `archive/` directory.
