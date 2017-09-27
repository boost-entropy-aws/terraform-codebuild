resource "aws_s3_bucket" "codebuild_source" {
  acl    = "private"
  bucket = "${var.source_bucket_name}"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "codebuild_artifacts" {
  acl    = "private"
  bucket = "${var.artifacts_bucket_name}"

  versioning {
    enabled = true
  }
}

data "aws_iam_policy_document" "codebuild_service_role" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]

    resources = [
      "${aws_s3_bucket.codebuild_source.arn}/*",
    ]
  }

  statement {
    actions = [
      "s3:GetObject*",
      "s3:PutObject*",
    ]

    resources = [
      "${aws_s3_bucket.codebuild_artifacts.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["codebuild.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "codebuild" {
  assume_role_policy = "${data.aws_iam_policy_document.codebuild_assume_role.json}"
  name               = "${var.role_name}"
}

resource "aws_iam_role_policy" "codebuild" {
  policy = "${data.aws_iam_policy_document.codebuild_service_role.json}"
  role   = "${aws_iam_role.codebuild.name}"
}

resource "aws_codebuild_project" "default" {
  build_timeout = "${var.build_timeout}"
  description   = "${var.project_description}"
  name          = "${var.project_name}"
  service_role  = "${aws_iam_role.codebuild.arn}"

  artifacts {
    location       = "${aws_s3_bucket.codebuild_artifacts.bucket}"
    namespace_type = "BUILD_ID"
    namespace_type = "NONE"
    packaging      = "NONE"
    type           = "S3"
  }

  environment {
    compute_type    = "${var.codebuild_compute_type}"
    image           = "${var.codebuild_image}"
    privileged_mode = "true"
    type            = "LINUX_CONTAINER"
  }

  source {
    type     = "S3"
    location = "${aws_s3_bucket.codebuild_source.arn}/project-src"
  }
}

data "aws_iam_policy_document" "starter" {
  statement {
    actions = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds",
      "codebuild:BatchGetProjects",
      "codebuild:StopBuild",
    ]

    resources = ["${aws_codebuild_project.default.id}"]
  }

  statement {
    actions = ["s3:GetBucket*"]

    resources = [
      "${aws_s3_bucket.codebuild_source.arn}",
    ]
  }

  statement {
    actions = ["s3:GetObject", "s3:PutObject"]

    resources = [
      "${aws_s3_bucket.codebuild_source.arn}/*",
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.codebuild_artifacts.arn}",
    ]
  }

  statement {
    actions = [
      "logs:GetLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_user" "starter" {
  name = "${var.starter_user_name}"
}

resource "aws_iam_user_policy" "starter" {
  policy = "${data.aws_iam_policy_document.starter.json}"
  user   = "${aws_iam_user.starter.name}"
}

resource "aws_iam_access_key" "starter" {
  user = "${aws_iam_user.starter.name}"
}
