############################################
# HTTP API GATEWAY FOR LAMBDAS
############################################
resource "aws_apigatewayv2_api" "teja_world_http_api" {
  name          = "teja-world-http-api"
  protocol_type = "HTTP"
}

############################################
# INTEGRATIONS WITH LAMBDA
############################################
resource "aws_apigatewayv2_integration" "btc_lambda_integration" {
  api_id             = aws_apigatewayv2_api.teja_world_http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.btc_fetch_lambda.invoke_arn  # ✅ Updated reference
}

resource "aws_apigatewayv2_integration" "nasa_lambda_integration" {
  api_id             = aws_apigatewayv2_api.teja_world_http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.nasa_fetch_lambda.invoke_arn  # ✅ Updated reference
}

############################################
# ROUTES (ENDPOINTS)
############################################
resource "aws_apigatewayv2_route" "btc_route" {
  api_id    = aws_apigatewayv2_api.teja_world_http_api.id
  route_key = "GET /btc"
  target    = "integrations/${aws_apigatewayv2_integration.btc_lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "nasa_route" {
  api_id    = aws_apigatewayv2_api.teja_world_http_api.id
  route_key = "GET /nasa"
  target    = "integrations/${aws_apigatewayv2_integration.nasa_lambda_integration.id}"
}

############################################
# DEPLOY API GATEWAY
############################################
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.teja_world_http_api.id
  name        = "$default"
  auto_deploy = true
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.teja_world_http_api.api_endpoint
}

############################################
# WEBSOCKET API GATEWAY (FOR REAL-TIME UPDATES)
############################################
resource "aws_apigatewayv2_api" "teja_world_websocket" {
  name                       = "teja-world-websocket"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_integration" "teja_world_websocket_integration" {
  api_id           = aws_apigatewayv2_api.teja_world_websocket.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.btc_fetch_lambda.invoke_arn  # ✅ Pick one Lambda for WebSocket
}

############################################
# WEBSOCKET ROUTES ($connect, $disconnect, $default)
############################################
resource "aws_apigatewayv2_route" "teja_world_websocket_connect" {
  api_id    = aws_apigatewayv2_api.teja_world_websocket.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.teja_world_websocket_integration.id}"
}

resource "aws_apigatewayv2_route" "teja_world_websocket_disconnect" {
  api_id    = aws_apigatewayv2_api.teja_world_websocket.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.teja_world_websocket_integration.id}"
}

resource "aws_apigatewayv2_route" "teja_world_websocket_default" {
  api_id    = aws_apigatewayv2_api.teja_world_websocket.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.teja_world_websocket_integration.id}"
}

############################################
# DEPLOY WEBSOCKET API GATEWAY
############################################
resource "aws_apigatewayv2_stage" "teja_world_websocket_stage" {
  api_id      = aws_apigatewayv2_api.teja_world_websocket.id
  name        = "prod"
  auto_deploy = true
}

output "websocket_url" {
  value = aws_apigatewayv2_api.teja_world_websocket.api_endpoint
}

output "websocket_management_url" {
  value = "https://${aws_apigatewayv2_api.teja_world_websocket.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_apigatewayv2_stage.teja_world_websocket_stage.name}"
}
