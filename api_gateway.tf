# 1️⃣ Create the API Gateway
resource "aws_apigatewayv2_api" "teja_world_api" {
  name          = "teja-world-api"
  protocol_type = "HTTP"
}

# 2️⃣ Integrate API Gateway with Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.teja_world_api.id  # ✅ Reference the declared API
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.teja_world_lambda.invoke_arn
}

# 3️⃣ Define a Route (Sets up /data endpoint)
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.teja_world_api.id  # ✅ Reference the API correctly
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# 4️⃣ Deploy API Gateway
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.teja_world_api.id  # ✅ Reference the API correctly
  name        = "$default"
  auto_deploy = true
}

# 5️⃣ Output API Gateway URL
output "api_gateway_url" {
  value = aws_apigatewayv2_api.teja_world_api.api_endpoint
}
