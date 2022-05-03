resource "aws_iam_role" "role" {
  name = "mskconnect-role-${var.env_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "kafkaconnect.amazonaws.com"
        }
      },
    ]
  })
}

## Policy for kafka

data "aws_iam_policy_document" "kafka_policy" {
  statement {
    effect = "Allow"

    actions = [
      "kafka-cluster:Connect",
      "kafka-cluster:DescribeCluster"
    ]

    resources = [
      data.aws_msk_cluster.msk.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kafka-cluster:ReadData",
      "kafka-cluster:DescribeTopic"
    ]

    resources = [
      "*",
    ]

  }

  statement {
    effect = "Allow"
    actions = [
      "kafka-cluster:WriteData",
      "kafka-cluster:DescribeTopic",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kafka-cluster:WriteData",
      "kafka-cluster:DescribeTopic",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kafka-cluster:CreateTopic",
      "kafka-cluster:WriteData",
      "kafka-cluster:ReadData",
      "kafka-cluster:DescribeTopic"

    ]
    resources = [
      "arn:aws:kafka:${var.aws_region}:${var.account_id}:topic/${var.msk_cluster_name}/*/__amazon_msk_connect_*"

    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kafka-cluster:AlterGroup",
      "kafka-cluster:DescribeGroup"
    ]
    resources = [
      "arn:aws:kafka:${var.aws_region}:${var.account_id}:group/${var.msk_cluster_name}/*/__amazon_msk_connect_*",
      "arn:aws:kafka:${var.aws_region}:${var.account_id}:group/${var.msk_cluster_name}/*/connect-*"
    ]
  }

}

resource "aws_iam_policy" "policy" {
  name   = "MSKAccessForConnector"
  path   = "/"
  policy = data.aws_iam_policy_document.kafka_policy.json
}


resource "aws_iam_role_policy_attachment" "attach_msk_policy" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

data "aws_iam_policy_document" "awssecret_policy" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = [
      data.aws_secretsmanager_secret.secret.arn
    ]
  }
}
