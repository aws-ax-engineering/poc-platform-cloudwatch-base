# poc-platform-cloudwatch-base.

This pipeline manages those CloudWatch configurations which are Account level and shared across multiple resource specific configurations. This will be an evolving pipeline.   

### SNS topics for sending message to pre-defined slack channels  

_nonprod account_ (pocdev)
arn:aws:sns:us-east-1:<prod-aws-account-id>:slack_notification_topic  >> Slack #aws-engineering-poc-events

_prod account_ (nonprod, prod, mapi)
arn:aws:sns:us-east-1:<prod-aws-account-id>:slack_notification_topic  >> Slack #aws-engineering-poc-events

**example simple usage**  

aws sns publish \
    --topic-arn "arn:aws:sns:$AWS_REGION:$AWS_ACCOUNT_ID:slack_notification_topic" \
    --message '{ "message": "message to appear on slack channel goes here" }'  
