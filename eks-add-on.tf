# data "external" "eks_addon_versions" {
#   program = ["bash", "${path.module}/fetch_latest_addon_versions.sh"]
# }

# # Amazon VPC CNI
# resource "aws_eks_addon" "vpc_cni" {
#   cluster_name = aws_eks_cluster.eks.name
#   addon_name   = "vpc-cni"
#   addon_version = data.external.eks_addon_versions.result.vpc_cni # Specify the version of VPC CNI

#   tags = {
#     Name = "vpc-cni"
#   }
# }

# # Amazon EKS Pod Identity Agent
# resource "aws_eks_addon" "pod_identity" {
#   cluster_name = aws_eks_cluster.eks.name
#   addon_name   = "amazon-eks-pod-identity-webhook"
#   addon_version = data.external.eks_addon_versions.result.pod_identity # Specify the version of Pod Identity Agent

#   tags = {
#     Name = "eks-pod-identity"
#   }
# }

# # kube-proxy
# resource "aws_eks_addon" "kube_proxy" {
#   cluster_name = aws_eks_cluster.eks.name
#   addon_name   = "kube-proxy"
#   addon_version = data.external.eks_addon_versions.result.kube_proxy # Specify the version of kube-proxy

#   tags = {
#     Name = "kube-proxy"
#   }
# }

# # Amazon EBS CSI Driver
# resource "aws_eks_addon" "ebs_csi_driver" {
#   cluster_name = aws_eks_cluster.eks.name
#   addon_name   = "ebs-csi-driver"
#   addon_version = "v1.37.0-eksbuild.1" # Specify the version of EBS CSI Driver

#   tags = {
#     Name = "ebs-csi-driver"
#   }
# }

# # CoreDNS
# resource "aws_eks_addon" "coredns" {
#   cluster_name = aws_eks_cluster.eks.name
#   addon_name   = "coredns"
#   addon_version = data.external.eks_addon_versions.result.coredns # Specify the version of CoreDNS

#   tags = {
#     Name = "coredns"
#   }
# }

# # IAM Role for EBS CSI Driver
# resource "aws_iam_role" "eks_ebs_csi_role" {
#   name = "AmazonEKSPodIdentityAmazonEBSCSIDriverRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action    = "sts:AssumeRole"
#         Effect    = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
#   tags = {
#     Name = "AmazonEKSPodIdentityAmazonEBSCSIDriverRole"
#   }
# }

# # Attach the role to EBS CSI Driver
# resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
#   policy_arn = aws_iam_policy.ebs_csi_driver_policy.arn
#   role       = aws_iam_role.eks_ebs_csi_role.name
# }
# # Attach IAM Role to the EBS CSI Driver addon
# resource "aws_eks_addon" "ebs_csi_driver_role_attachment" {
#   cluster_name = aws_eks_cluster.eks.name
#   addon_name   = "ebs-csi-driver"
#   service_account_role_arn = aws_iam_role.eks_ebs_csi_role.arn

#   tags = {
#     Name = "AttachEBSCSIDriverRole"
#   }
# }

# resource "aws_iam_policy" "ebs_csi_driver_policy" {
#   name        = "AmazonEBSCSIDriverPolicy"
#   description = "Policy for Amazon EBS CSI Driver"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = "ebs:CreateVolume"
#         Resource = "*"
#       },
#       {
#         Effect   = "Allow"
#         Action   = "ebs:DeleteVolume"
#         Resource = "*"
#       }
#     ]
#   })
# }