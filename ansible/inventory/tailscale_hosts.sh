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

        # Append node variables (ansible_host)
        NODE_VAR="\"$node\": {\"ansible_host\": \"$NODE_IP\"}"
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
