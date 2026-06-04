# Plan: K3s Dual-Stack Cluster Setup with Cloudflare Cert-Manager

## Objective
Deploy a fully functional k3s cluster on four nodes (`pinode01-04`) with:
- Dual-stack (IPv4/IPv6) local networking.
- Traefik as the Ingress controller.
- `cert-manager` with Cloudflare DNS-01 for TLS.
- `external-dns` for automated Cloudflare DNS management.
- `cloudflared` (Cloudflare Tunnel) for secure internet exposure.

## Key Files & Context
- **Inventory:** `ansible/inventory/hosts.ini` (uses local IPs: 192.168.0.201-204).
- **Domain:** `akrami.xyz` (Cloudflare).
- **Cluster Networking:**
    - Service CIDR: `10.43.0.0/16,fd00:43::/112`
    - Cluster CIDR: `10.42.0.0/16,fd00:42::/48`
- **Inter-node Communication:** Uses local physical network (`eth0`).

## Proposed Solution

### 1. Ansible Roles
- **`k3s_server`**: Installs k3s master on `pinode01` with dual-stack flags.
- **`k3s_agent`**: Joins `pinode02-04` to the cluster.
- **`k3s_apps`**: Orchestrates Helm deployments for add-ons.

### 2. Dual-Stack & OS Config
- Enable IPv6 forwarding and standard k3s prerequisites.
- Configure k3s with dual-stack CIDRs and bind to local `eth0` IPs.

### 3. Cloudflare Integration Stack
- **Cert-Manager**: Handles `*.akrami.xyz` certs via DNS-01 challenge.
- **External-DNS**: Monitors Ingresses and creates CNAME/A records in Cloudflare.
- **Cloudflare Tunnel**: Deploys a `cloudflared` pod that routes traffic from `*.akrami.xyz` to the Traefik service.

## Implementation Steps

### Phase 1: Preparation
1. Ensure `ansible/inventory/hosts.ini` is correct.
2. Create a `common` role task for IPv6 forwarding and dependencies.

### Phase 2: K3s Installation
1. Implement `k3s_server` and `k3s_agent` roles.
2. Run `ansible/playbooks/setup_k3s.yml`.

### Phase 3: Add-ons
1. Deploy `cert-manager` and `ClusterIssuer`.
2. Deploy `external-dns` configured for Cloudflare.
3. Deploy `cloudflared` and configure the tunnel to point to Traefik.

## Verification & Testing
1. `kubectl get nodes -o wide`: Verify dual-stack addresses.
2. Deploy a test app (e.g., `whoami.akrami.xyz`):
   - Check if DNS record is created by `external-dns`.
   - Check if TLS cert is issued by `cert-manager`.
   - Check if accessible via the internet through the tunnel.

