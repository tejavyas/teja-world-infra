## modules/dynamodb/main.tf
### DynamoDB table

# DynamoDB Table
resource "aws_dynamodb_table" "real_time_data" {
  name           = "RealTimeData"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
