# AWS S3 Static Website using Terraform

Hosting a Static Website on AWS S3 using Terraform v1.0.11


## Description 
This session covers on how to provision an S3-backed Websites. This can be a very cost-effective way of hosting a website.
IMPORTANT: This script provisions a globally accessible S3 bucket for unauthenticated users because it is designed for hosting public static websites.


## Features
This module allows for Hosting a Static Website on Amazon S3, provisioning the following:

- S3 Bucket for static public files.
- Uploading files from a local directory to designated s3 bucket.
- Assigning required IAM policies for the bucket.

## Requirements 

1. Basic knowledge of Terraform
2. Terraform vv1.0.11 installed
3. AWS CLI installed


## How to configure 
1. Create an S3 bucket to store the static files which is publically accessible. Also, this bucket has the static website option 'enabled'.

```
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
```

2. Create an IAM policy document (policy.json) to manage bucket permissions and assiging this policy to S3 bucket.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${bucket_name}/*"
        }
    ]
}
```

3. Uploading files from a mentioned directory to the newly created S3 bucket. There are multiple ways to do the file upload, I have mentioned a few of them below

3.1) In this script, we will be using awscli commands using [null_resource](https://www.terraform.io/docs/language/resources/provisioners/local-exec.html#example-usage) provisioner to upload files to s3.
```
resource "null_resource" "remove_and_upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync ${path.module}/${var.location} s3://${aws_s3_bucket.bucket.id}"
  }
}
```

3.2) You may also use the [fileset](https://www.terraform.io/docs/language/functions/fileset.html) function to get multiple files from a given path. As we have a variety of objects with different content-types to upload, it will be better to use shared [module hashicorp/dir/template](https://registry.terraform.io/modules/hashicorp/dir/template/latest) as well. 

```
module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "${var.location}" 
}

resource "aws_s3_bucket_object" "file_upload" {
  for_each = module.template_files.files

  bucket       = aws_s3_bucket.bucket.id
  key          = each.key
  content_type = each.value.content_type
  source  = each.value.source_path
  content = each.value.content
  etag = each.value.digests.md5
}
```

## Provisioning
1. Modify the variables.tf file with the values : access_key, secret_key, bucket-name and location of the website files.

2. Navigate to the project directory where the files are to be installed and follow the below steps
```
git clone https://github.com/Freeda-F/StaticWebsite-s3-Terraform.git
cd StaticWebsite-s3-Terraform
terraform init
terraform apply
```

## Result

![image](https://user-images.githubusercontent.com/93197553/145415642-72882e78-f804-4729-a5a2-2781519d2129.png)




