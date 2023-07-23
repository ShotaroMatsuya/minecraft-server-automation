# when creating task definition using terraform, we have the option to provide either a task role or an execution roll or both depending on your needs

# former one is  for the IAM role that allows ECS container to make calls to other aws services

# latter one is for the role that the ecs contianer agent & the docker daemon can assume

# we're going to create the latter with a policy tha gives permissions to S3 because that's where the actual docker image layers are stored

# permision to ECR to pull the images, and lastly  permission to push logs to cloudWatch
resource "aws_iam_role" "main_ecs_tasks" {
  name               = "ecs_tasks-${local.name}-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# the policy that will actually be attached to this particular role
# giving permissions to S3 and ECR to be able to authorize & in additino to be able to actually pull the relevant images, and lastly to be able to have logs being pushed through to cloud watch 
resource "aws_iam_role" "task_execution_role" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ],
  "Version": "2008-10-17"
}
POLICY

  max_session_duration = "3600"
  name                 = "${local.name}-ecs_tasks_execution-role"
  path                 = "/"
}

resource "aws_iam_role_policy" "execution_policy" {
  name = "${local.name}-task-execution-policy"
  role = aws_iam_role.task_execution_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": ["*"]
        },
        {
            "Effect": "Allow",
            "Resource": [
              "*"
            ],
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:CreateLogGroup",
                "logs:DescribeLogStreams"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
              "ssm:Getparameters",
              "secretsmanager:GetSecretValue",
              "kms:Descypt"
            ]
        }
    ]
}
EOF
}

# ExecuteCommandPolicy
resource "aws_iam_role_policy" "ExecuteCommand" {
  name = "${local.name}-ExecuteCommand"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  role = aws_iam_role.main_ecs_tasks.id
}

# firelensPolicy
resource "aws_iam_role_policy" "firelensPolicy" {
  name = "${local.name}-firelensPolicy"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "s3:ListBucketMultipartUploads",
        "kms:Decrypt",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "s3:ListBucket",
        "logs:CreateLogGroup",
        "logs:PutLogEvents",
        "s3:PutObject",
        "s3:GetObject",
        "logs:CreateLogStream",
        "s3:AbortMultipartUpload",
        "kms:GenerateDataKey",
        "s3:GetBucketLocation"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Sid": "VisualEditor0"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  role = aws_iam_role.main_ecs_tasks.id
}