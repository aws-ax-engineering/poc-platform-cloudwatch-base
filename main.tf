data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
    # make sure to add an condition for principal organization
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda/slack-notification/main.py"
  output_path = "slack_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "slack_function_payload.zip"
  function_name = "slack-notification"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"

  environment {
    variables = {
      slackChannel = var.slack_channel
      kmsEncryptedHookUrl = var.slack_token
    }
  }
}

# create sns topic 
resource "aws_sns_topic" "slack_notification_topic" {
    name = "slack_notification_topic"
}

resource "aws_lambda_permission" "slack_lambda_permission" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal = "sns.amazonaws.com"
  source_arn = aws_sns_topic.slack_notification_topic.arn
}


resource "aws_sns_topic_subscription" "lambda_sns_subscription" {
  topic_arn = aws_sns_topic.slack_notification_topic.arn
  protocol = "lambda"
  endpoint = aws_lambda_function.test_lambda.arn
}