resource "aws_eks_cluster" "eks" {
  name     = "evershop-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = concat(module.vpc.public_subnets)

    endpoint_public_access = true
    endpoint_private_access = false
  }
#   depends_on = [aws_iam_role_policy_attachment.eks_worker_role_policy]

  tags = {
    Name = "evershop-eks-cluster"
  }
}


# creating EKS Managed Node Group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "evershop-eks-node-group"
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = module.vpc.public_subnets
  instance_types = ["t3.medium"]
  disk_size      = 20

   scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }
  remote_access {
    ec2_ssh_key               = "dev-shree" # Existing Key Pair
    source_security_group_ids = [aws_security_group.eks_worker_nodes.id]
  }
  tags = {
    Name = "eks-node-group"
  }
  depends_on = [aws_eks_cluster.eks]
}


resource "aws_security_group" "eks_worker_nodes" {
  name   = "eks-worker-nodes-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow all traffic from EKS control plane"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "eks-worker-nodes-sg"
  }
}



# load balancer security group
resource "aws_security_group" "eks_lb_sg" {
  name        = "eks-lb-sg"
  description = "Allow inbound HTTP and HTTPS traffic to the load balancer"
  vpc_id      = module.vpc.vpc_id
  

  // Allow inbound HTTP traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow inbound HTTPS traffic from anywhere (if needed)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the load balancer
resource "aws_lb" "evershop_lb" {
  name               = "evershop-lb"
  internal           = false
  load_balancer_type = "application"  # "application" or "network" based on your requirements
  security_groups    = [aws_security_group.eks_lb_sg.id]  # Make sure to define the security group for the LB
  subnets            = module.vpc.public_subnets
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "evershop-alb"
  }
}


#  create a load balancer target_group
resource "aws_lb_target_group" "evershop_lb_tg" {
  name        = "evershop-lb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = {
    Name = "evershop-alb-target-group"
  }
}

# ALB Listener for HTTP
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.evershop_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      status_code = 200
      content_type = "text/plain"
      message_body = "OK"
    }
  }
}



# # setting up the CPU target/threshold
# resource "aws_autoscaling_policy" "cpu_target_tracking" {
#   name                   = "cpu-target-tracking"
#   autoscaling_group_name = aws_autoscaling_group.eks_asg.name
#   policy_type            = "TargetTrackingScaling"

#   target_tracking_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ASGAverageCPUUtilization"
#     }
#     target_value = 70.0  # Target 60% CPU utilization
#   }
# }