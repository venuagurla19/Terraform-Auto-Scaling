provider "aws" {
    region = "us-west-2"
    }

resource "aws_s3_bucket" "venu-buckets" {
    bucket = "terraform-demotest-bucket"

lifecycle {
    prevent_destroy = false
    }
}


resource "aws_dynamodb_table" "basic-dynamodb-table" {
    name           = "GameScores"
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "UserId"
    

    attribute {
    name = "UserId"
    type = "S"
    }
}