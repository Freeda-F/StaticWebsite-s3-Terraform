data "template_file" "my-data" {
  template = "${file("policy.json")}"
  vars = {
    bucket_name = "${var.bucket-name}"
  }
}
