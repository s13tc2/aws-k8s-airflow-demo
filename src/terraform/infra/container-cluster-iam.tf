# Now that our container registry is all set up and we can push images to it, we need to set up our Kubernetes cluster. That’s where AWS EKS comes in. The cluster’s configuration is relatively simple but there’s quite a bit of work we need to do with IAM to make it all work.
# Before we provision our EKS cluster, we need to set up the IAM role that it will use to interact with the rest of the AWS platform. This is not a role that our nodes or Kubernetes deployments will use. It’s the role that EKS will use to enact configuration changes made to the cluster across all the AWS resources that are being used:
data "aws_iam_policy_document" "container_cluster_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "container_cluster" {
  name               = "eks-${var.application_name}-${var.environment_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.container_cluster_assume_role.json

  tags = {
    application = var.application_name
    environment = var.environment_name
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.container_cluster.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks_vpc_controller_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.container_cluster.name
}
