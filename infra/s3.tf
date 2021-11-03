resource "aws_s3_bucket" "pipeline_artifact_store" {
  bucket                      = "codepipeline-artifactstore-${data.aws_caller_identity.self.account_id}-${local.resource_name}" 
  acl                         = "private"
  tags                        = {} 
  versioning {
    enabled    = false 
    mfa_delete = false 
  }
}


resource "aws_s3_bucket_policy" "pipeline_artifact_store_policy" {
  bucket = aws_s3_bucket.pipeline_artifact_store.bucket
  policy =  <<-EOT
{
  "Id": "Policy1635944673752",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1635944596505",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Deny",
      "Resource": "${aws_s3_bucket.pipeline_artifact_store.arn}/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      },
      "Principal": "*"
    },
    {
      "Sid": "Stmt1635944671178",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": "${aws_s3_bucket.pipeline_artifact_store.arn}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
    }
  ]
}  
  EOT
}
