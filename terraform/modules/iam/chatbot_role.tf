resource "aws_iam_role" "chatbot-notification-only" {
  name = "chatbot-notification-only"
  assume_role_policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Sid : "",
          Effect : "Allow",
          Principal : {
            Service : "chatbot.amazonaws.com"
          },
          Action : "sts:AssumeRole"
        }
      ]
    }
  )
  description          = "AWS Chatbot Execution Role for Only Notification"
  max_session_duration = "3600"
  path                 = "/service-role/"
}

resource "aws_iam_role_policy_attachment" "chatbot-notification-only-attach" {
  policy_arn = aws_iam_policy.chatbot-notification-only.arn
  role       = aws_iam_role.chatbot-notification-only.name
}

resource "aws_iam_policy" "chatbot-notification-only" {
  name = "chatbot-notification-only"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement : [
        {
          Sid : "",
          Effect : "Allow",
          Action : [
            "logs:DescribeQueryDefinitions",
            "logs:DescribeLogGroups"
          ],
          Resource : "*"
        }
      ]
    }
  )
}
