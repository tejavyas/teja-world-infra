############################################
# BTC FETCH LAMBDA FUNCTION
############################################
resource "aws_lambda_function" "btc_fetch_lambda" {
  function_name    = "btc-fetch-lambda"
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  filename         = "../backend/btc_fetch/lambda.zip"
  source_code_hash = filebase64sha256("../backend/btc_fetch/lambda.zip")
  role             = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      WEBSOCKET_MANAGEMENT_URL = "https://${aws_apigatewayv2_api.teja_world_websocket.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_apigatewayv2_stage.teja_world_websocket_stage.name}"
    }
  }
}

############################################
# NASA FETCH LAMBDA FUNCTION
############################################
resource "aws_lambda_function" "nasa_fetch_lambda" {
  function_name    = "nasa-fetch-lambda"
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  filename         = "../backend/nasa_fetch/lambda.zip"
  source_code_hash = filebase64sha256("../backend/nasa_fetch/lambda.zip")
  role             = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      WEBSOCKET_MANAGEMENT_URL = "https://${aws_apigatewayv2_api.teja_world_websocket.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_apigatewayv2_stage.teja_world_websocket_stage.name}"
    }
  }
}

############################################
# WEBSOCKET HANDLER LAMBDA FUNCTION
############################################
resource "aws_lambda_function" "websocket_handler_lambda" {
  function_name = "websocket-handler"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  filename      = "../backend/websocket_handler/lambda.zip"
  source_code_hash = filebase64sha256("../backend/websocket_handler/lambda.zip")
  role          = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      WEBSOCKET_MANAGEMENT_URL = "https://${aws_apigatewayv2_api.teja_world_websocket.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_apigatewayv2_stage.teja_world_websocket_stage.name}",
      DDB_TABLE = aws_dynamodb_table.websocket_connections.name
    }
  }
}

############################################
# LAMBDA EXECUTION ROLE (WITH WEBSOCKET & DYNAMODB PERMISSIONS)
############################################
resource "aws_iam_role" "lambda_exec" {
  name = "teja-world-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

############################################
# IAM POLICY: ALLOW LAMBDA TO MANAGE WEBSOCKETS
############################################
resource "aws_iam_policy" "lambda_api_gateway_invoke" {
  name        = "LambdaAPIGatewayInvoke"
  description = "Allow Lambda to invoke API Gateway WebSocket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "execute-api:ManageConnections",
        "execute-api:Invoke"
      ],
      Resource = [
        "${aws_apigatewayv2_api.teja_world_websocket.execution_arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_apigateway_attachment" {
  policy_arn = aws_iam_policy.lambda_api_gateway_invoke.arn
  role       = aws_iam_role.lambda_exec.name
}

############################################
# DYNAMODB TABLE FOR CONNECTION STORAGE
############################################
resource "aws_dynamodb_table" "websocket_connections" {
  name         = "websocket_connections"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "connectionId"

  attribute {
    name = "connectionId"
    type = "S"
  }
}

############################################
# IAM POLICY: ALLOW LAMBDA TO ACCESS DYNAMODB
############################################
resource "aws_iam_policy" "lambda_dynamodb_access" {
  name        = "LambdaDynamoDBAccess"
  description = "Allow Lambda to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "dynamodb:Scan",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      Resource = aws_dynamodb_table.websocket_connections.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  policy_arn = aws_iam_policy.lambda_dynamodb_access.arn
  role       = aws_iam_role.lambda_exec.name
}

############################################
# ATTACH AWS-MANAGED BASIC EXECUTION ROLE (RECOMMENDED)
############################################
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}

############################################
# PERMISSION FOR API GATEWAY TO INVOKE LAMBDAS
############################################
resource "aws_lambda_permission" "api_gateway_btc" {
  statement_id  = "AllowAPIGatewayInvokeBTC"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.btc_fetch_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "api_gateway_nasa" {
  statement_id  = "AllowAPIGatewayInvokeNASA"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nasa_fetch_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "api_gateway_websocket" {
  statement_id  = "AllowAPIGatewayInvokeWebsocket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.websocket_handler_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}
