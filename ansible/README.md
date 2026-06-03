# Homelab Ansible

Ansible configuration for managing a 4-node Raspberry Pi cluster running Debian Trixie.

## 🚀 Quick Start

### Prerequisites
- SSH access to nodes as user `nick`.
- Nodes should be running Debian Trixie.
- `ansible` installed on your local machine.

### Connectivity Test
```bash
ansible-playbook playbooks/ping.yml
```

## 🏗️ Project Structure

- `inventory/`: Host definitions and group variables.
- `playbooks/`: Individual playbooks for various tasks.
- `roles/`: Reusable logic for specific software/configurations.

## 📜 Available Playbooks

### 1. Baseline Setup
Configures system locales to `en_US.UTF-8` and sets hostnames to match the inventory names (`pinode01`-`04`).
```bash
ansible-playbook playbooks/baseline.yml
```

### 2. Oh My Bash
Installs Oh My Bash for the `nick` user with the `font` theme.
```bash
ansible-playbook playbooks/setup_omb.yml
```

### 3. Tailscale
Installs and authenticates the Tailscale client.
```bash
ansible-playbook playbooks/setup_tailscale.yml -e "tailscale_auth_key=tskey-auth-..."
```

## 📋 Inventory
The cluster is organized into two groups for future K3s installation:
- **k3s_master**: `pinode01` (192.168.0.201)
- **k3s_worker**: `pinode02`, `pinode03`, `pinode04` (192.168.0.202-204)

## 🛠️ Configuration
Global settings like `ansible_user` and `os_release` are stored in `inventory/group_vars/all.yml`.
Individual role defaults are located in their respective `roles/<role_name>/defaults/main.yml`.
