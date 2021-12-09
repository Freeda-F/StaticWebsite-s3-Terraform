#Creating S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket-name
  acl    = "public-read"
  policy = "${data.template_file.my-data.rendered}"

   website {
    index_document = "index.html"
    error_document = "error.html"
}
tags = {
    Name        = var.bucket-name
  }
}

#uploading files to S3 bucket
resource "null_resource" "remove_and_upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync ${path.module}/${var.location} s3://${aws_s3_bucket.bucket.id}"
  }
}

#Output of the S3 website URL
output "website-url" {
    value = aws_s3_bucket.bucket.website_endpoint
}
