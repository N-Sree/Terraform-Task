provider "aws" {
region = "us-east-1"
}

resource "aws_s3_bucket" "tf_state" {
bucket = "your-terraform-state-bucket"

versioning {
enabled = true
}

server_side_encryption_configuration {
rule {
apply_server_side_encryption_by_default {
sse_algorithm = "AES256"
}
}
}

lifecycle {
prevent_destroy = true
}
}

resource "aws_dynamodb_table" "tf_locks" {
name = "terraform-lock-table"
billing_mode = "PAY_PER_REQUEST"
hash_key = "LockID"

attribute {
name = "LockID"
type = "S"
}
}
