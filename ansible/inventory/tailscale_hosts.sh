#!/usr/bin/env bash

# Exit on error or unbound variables
set -euo pipefail

# Define your target nodes
TARGET_NODES=("pinode01" "pinode02" "pinode03" "pinode04")

# Check for tailscale CLI
if ! command -v tailscale &> /dev/null; then
    # Return an empty inventory structure if tailscale isn't found
    echo '{"_meta": {"hostvars": {}}}'
    exit 0
fi

# Fetch Tailscale status once
TAILSCALE_STATUS=$(tailscale status)

# Initialize JSON building variables
HOSTS_JSON=""
HOSTVARS_JSON=""
MASTER_HOSTS=""
WORKER_HOSTS=""

# Loop through the nodes to extract IPs and build JSON fragments
for node in "${TARGET_NODES[@]}"; do
    NODE_IP=$(echo "$TAILSCALE_STATUS" | awk -v name="$node" '$2 == name {print $1}')

    if [ -n "$NODE_IP" ]; then
        # Append node to the hosts array list
        if [ -z "$HOSTS_JSON" ]; then
            HOSTS_JSON="\"$node\""
        else
            HOSTS_JSON="$HOSTS_JSON, \"$node\""
        fi

        # Determine local_ip based on node name (pinode0X -> 192.168.0.20X)
        NODE_NUM="${node#pinode}"
        # Remove leading zero if any, though here it's 01, 02...
        NODE_NUM_CLEAN=$(echo "$NODE_NUM" | sed 's/^0//')
        LOCAL_IP="192.168.0.20$NODE_NUM_CLEAN"

        # Separate into master and workers
        if [ "$node" == "pinode01" ]; then
            MASTER_HOSTS="\"$node\""
        else
            if [ -z "$WORKER_HOSTS" ]; then
                WORKER_HOSTS="\"$node\""
            else
                WORKER_HOSTS="$WORKER_HOSTS, \"$node\""
            fi
        fi

        # Append node variables (ansible_host and local_ip)
        NODE_VAR="\"$node\": {\"ansible_host\": \"$NODE_IP\", \"local_ip\": \"$LOCAL_IP\"}"
        if [ -z "$HOSTVARS_JSON" ]; then
            HOSTVARS_JSON="$NODE_VAR"
        else
            HOSTVARS_JSON="$HOSTVARS_JSON, $NODE_VAR"
        fi
    fi
done

# Output the exact JSON format Ansible expects
cat << EOF
{
  "k3s_master": {
    "hosts": [ $MASTER_HOSTS ]
  },
  "k3s_worker": {
    "hosts": [ $WORKER_HOSTS ]
  },
  "k3s_cluster": {
    "children": ["k3s_master", "k3s_worker"]
  },
  "pi_cluster": {
    "hosts": [ $HOSTS_JSON ]
  },
  "_meta": {
    "hostvars": {
      $HOSTVARS_JSON
    }
  }
}
EOF
