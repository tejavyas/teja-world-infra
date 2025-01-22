## modules/lambda/main.tf
###S3 bucket, IAM role, and Lambda function.

# S3 Bucket for Lambda Code
resource "aws_s3_bucket" "lambda_code" {
  bucket = "teja-world-lambda-code"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM Policy for Lambda
resource "aws_iam_policy_attachment" "lambda_logs" {
  name       = "lambda_logs"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function
resource "aws_lambda_function" "backend_api" {
  function_name    = "teja_backend_api"
  role            = aws_iam_role.lambda_role.arn
  runtime         = "python3.9"
  handler         = "main.lambda_handler"
  s3_bucket       = aws_s3_bucket.lambda_code.id
  s3_key          = "backend.zip"
}
