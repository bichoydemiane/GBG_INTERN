# Create an S3 bucket
resource "aws_s3_bucket" "MyS3Bucket" {
  bucket = "mybucket14021997bebo"

  tags = {
    Name        = "mybucket14021997bebo"
  }
}

# Create an SNS topic
resource "aws_sns_topic" "MyTopic" {
  name = "myfirsttopic14021997bebo"
}

resource "aws_sns_topic_subscription" "MySubscription" {
  topic_arn = aws_sns_topic.MyTopic.arn
  protocol  = "email"
  endpoint  = "bichoydemiane@gmail.com"
}


# Create an IAM role for Lambda
resource "aws_iam_role" "MyLambdaRole" {
  name = "my-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach IAM Policies to IAM Role
resource "aws_iam_role_policy_attachment" "MyattachmentPtoR" {
  role       = aws_iam_role.MyLambdaRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}
resource "aws_iam_role_policy_attachment" "MyattachmentPtoR2" {
  role       = aws_iam_role.MyLambdaRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Create an AWS Lambda function
resource "aws_lambda_function" "MyLambdaFunction" {
  function_name = "mylambdafunction-bebo"
  role          = aws_iam_role.MyLambdaRole.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = "lambda_function.zip"  # Path to your Lambda function code ZIP file

}
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.MyLambdaFunction.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.MyS3Bucket.arn
}
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.MyS3Bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.MyLambdaFunction.arn
    events              = ["s3:ObjectCreated:Put"]
  }
    depends_on = [
    aws_lambda_permission.allow_bucket
  ]
}
/*
# Subscribe Lambda function to SNS topic
resource "aws_sns_topic_subscription" "my_subscription" {
  topic_arn = aws_sns_topic.my_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.my_lambda.arn
}
*/