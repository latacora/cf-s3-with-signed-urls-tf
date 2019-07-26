data "aws_caller_identity" "current" {}

locals {
  acct_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
}

resource "aws_s3_bucket" "backend" {
  bucket = "${var.bucket_name}"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket  = "${var.bucket_name}"
  key     = "index.html"
  content = "This is the index for ${var.bucket_name}"
}

data "aws_iam_policy_document" "s3_signer_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Account"
      identifiers = ["${local.acct_arn}"]
    }
  }
}

resource "aws_iam_role" "s3_signer" {
  name               = "s3_signer_role"
  assume_role_policy = "${data.aws_iam_policy_document.s3_signer_role_policy.json}"
}

resource "aws_iam_policy" "s3_signer" {
  name        = "s3_signer_policy"
  description = "A policy for the S3 Signed URL signing role."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["${aws_s3_bucket.backend.arn}", "${aws_s3_bucket.backend.arn}/*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_signer_policy_attachment" {
  role = "${aws_iam_role.s3_signer.name}"
  policy_arn = "${aws_iam_policy.s3_signer.arn}"
}
