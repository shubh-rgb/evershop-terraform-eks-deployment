#!/bin/bash
set -e

# Variables
REGION="ap-south-1"  # Replace with your region
CLUSTER_NAME="evershop-eks-cluster"  # Replace with your cluster name

# Fetch latest versions for each addon
fetch_latest_version() {
  local addon_name=$1
  aws eks describe-addon-versions \
    --addon-name "$addon_name" \
    --query 'addons[0].addonVersions[-1].addonVersion' \
    --region "$REGION" \
    --output text
}

# Fetch versions for all addons
vpc_cni=$(fetch_latest_version "vpc-cni")
# pod_identity=$(fetch_latest_version "amazon-eks-pod-identity-webhook")
kube_proxy=$(fetch_latest_version "kube-proxy")
# ebs_csi_driver=$(fetch_latest_version "ebs-csi-driver")
coredns=$(fetch_latest_version "coredns")

# Output the versions in JSON format
echo "{
  \"vpc_cni\": \"$vpc_cni\",
  \"pod_identity\": \"$pod_identity\",
  \"kube_proxy\": \"$kube_proxy\",
  \"ebs_csi_driver\": \"$ebs_csi_driver\",
  \"coredns\": \"$coredns\"
}"
