variable "artifacts_bucket_name" {
  description = "The name of the bucket that will be created to hold bucket artifacts"
}

variable "build_timeout" {
  default     = "20"
  description = "The amount of time in minutes before CodeBuild kills the task"
}

variable "codebuild_compute_type" {
  description = "Information about the compute resources the build project will use. Available values for this parameter are: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM or BUILD_GENERAL1_LARGE"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "codebuild_image" {
  description = "Docker image to be used to run CodeBuild jobs"
  default     = "aws/codebuild/docker:1.12.1"
}

variable "project_description" {
  description = "Description for the codebuild project"
}

variable "project_name" {
  description = "Codebuild project name"
}

variable "role_name" {
  description = "The IAM service role name for the CodeBuild projet"
}

variable "starter_user_name" {
  description = "Name of the IAM user to be created with permissions to start CodeBuild jobs"
}

variable "source_bucket_name" {
  description = "The name of the bucket that will be created to hold the source code"
}
