## S3 bucket

# ✅ Creates an S3 bucket named "teja-world-terraform-bucket"
resource "aws_s3_bucket" "teja_world_bucket" {
  bucket = "teja-world-terraform-bucket"
}

# ✅ Ensures the bucket owner has full control (required in Terraform 4+)
resource "aws_s3_bucket_ownership_controls" "teja_world_bucket_controls" {
  bucket = aws_s3_bucket.teja_world_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# ✅ Blocks any public access to prevent accidental exposure
resource "aws_s3_bucket_public_access_block" "teja_world_bucket_block" {
  bucket = aws_s3_bucket.teja_world_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}