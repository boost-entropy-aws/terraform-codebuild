output "codebuild_starter_user_access_key_id" {
  value = "${aws_iam_access_key.starter.id}"
}

output "codebuild_starter_user_secret_access_key" {
  value = "${aws_iam_access_key.starter.secret}"
}
