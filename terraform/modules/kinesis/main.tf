## modules/kinesis/main.tf
### Kinesis stream

# Kinesis Stream
resource "aws_kinesis_stream" "data_stream" {
  name        = "teja-stream"
  shard_count = 1
}