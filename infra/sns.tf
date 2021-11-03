resource "aws_sns_topic" "notify" {
  content_based_deduplication = false
  display_name                = "${local.resource_name}" 
  fifo_topic                  = false 
  name                        = "${local.resource_name}" 
  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "SNS:GetTopicAttributes",
        "SNS:SetTopicAttributes",
        "SNS:AddPermission",
        "SNS:RemovePermission",
        "SNS:DeleteTopic",
        "SNS:Subscribe",
        "SNS:ListSubscriptionsByTopic",
        "SNS:Publish",
        "SNS:Receive"
      ],
      "Resource": "arn:aws:sns:ap-northeast-1:${data.aws_caller_identity.self.account_id}:${local.resource_name}",
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "${data.aws_caller_identity.self.account_id}"
        }
      }
    }
  ]
}  
  POLICY
  tags                        = {}
}

resource "aws_sns_topic_subscription" "notify_subscription" {
  endpoint                       = var.notify_email
  protocol                       = "email-json" 
  raw_message_delivery           = false 
  topic_arn                      = aws_sns_topic.notify.arn
}