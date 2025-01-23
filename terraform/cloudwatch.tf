resource "aws_cloudwatch_event_rule" "btc_price_schedule" {
  name                = "btc-price-schedule"
  schedule_expression = "rate(1 minute)"  # ✅ Fix: AWS doesn't allow seconds, use minutes
}

resource "aws_cloudwatch_event_target" "btc_lambda_trigger" {
  rule      = aws_cloudwatch_event_rule.btc_price_schedule.name
  target_id = "btc_fetch_lambda"
  arn       = aws_lambda_function.btc_fetch_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_btc_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.btc_fetch_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.btc_price_schedule.arn
}
