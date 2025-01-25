resource "aws_codebuild_project" "tf-plan" {
  name         = "tf-cicd-plan"
  description  = "Plan stage for terraform"
  service_role = "arn:aws:iam::216989108476:role/codebuild_fullaccess"
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml")
  }
}

resource "aws_codebuild_project" "tf-apply" {
  name         = "tf-cicd-apply"
  description  = "Apply stage for terraform"
  service_role = "arn:aws:iam::216989108476:role/codebuild_fullaccess"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml")
  }

}

resource "aws_codepipeline" "cicd_pipeline" {

  name     = "tf-cicd"
  role_arn = "arn:aws:iam::216989108476:role/codepipeline_fullaccess"

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.artifacts.id
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["tf-code"]
      configuration = {
        FullRepositoryId     = "yogendrahj/HealthCare-North"
        BranchName           = "main"
        ConnectionArn        = var.github_connection_arn
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Plan"
    action {
      name            = "Build"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tf-code"]
      configuration = {
        ProjectName = "tf-cicd-plan"
      }
    }
  }

  # Deploy to Dev stage (Deploy first to dev)
  stage {
    name = "DeployToDev"
    action {
      name            = "dev-deployment"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      version         = "1"
      input_artifacts = ["tf-code"]
      configuration = {
        BucketName = var.dev_bucket
        Extract    = "true"
      }
    }
  }

  # Manual approval before Deploy to Prod
  stage {
    name = "ManualApproval"
    action {
      name     = "manual-approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
      configuration = {
        ExternalEntityLink = "https://healthcarenorth-devs3.s3.eu-west-2.amazonaws.com"
      }
      input_artifacts = []
    }
  }

  # Deploy to Prod stage (after manual approval)
  stage {
    name = "DeployToProd"
    action {
      name     = "prod-deployment"
      category = "Deploy"
      owner    = "AWS"
      provider = "S3"
      version  = "1"
      configuration = {
        BucketName = var.prod_bucket
        Extract    = "true"
      }
      input_artifacts = ["tf-code"]
    }
  }

}