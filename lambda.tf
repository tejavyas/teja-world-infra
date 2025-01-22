resource "aws_lambda_function" "teja_world_lambda" {
  function_name = "teja-world-backend"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  filename      = "lambda.zip"
  role          = aws_iam_role.lambda_exec.arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "teja-world-lambda-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.teja_world_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}
