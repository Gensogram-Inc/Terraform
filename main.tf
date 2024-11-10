terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
  backend "s3" {
    bucket         = "gensogram-terraform-state-bucket"    # Replace with your S3 bucket name
    key            = "Terraform/terraform.tfstate" # Adjust the key (path) as needed
    region         = "us-east-1"
    dynamodb_table = "gensogram-terraform-state-lock"         # Replace with your DynamoDB table name
    encrypt        = true                           # Enable encryption at rest
  }
}

provider "aws" {
  region  = "us-east-1"
}

variable "ingressrules" {
  description = "List of ingress port rules"
  type        = list(number)
  default     = [80, 443] # Example ports; update as needed
}

variable "egressrules" {
  description = "List of egress port rules"
  type        = list(number)
  default     = [0] # Example ports; update as needed
}

resource "aws_security_group" "gensogram_sg" {
  name        = "gensogram_sg"
  description = "Allow specified inbound and outbound traffic"

  dynamic "ingress" {
    for_each = var.ingressrules
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = var.egressrules
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name = "gensogram_sg"
  }
}

resource "aws_instance" "gensogram_server" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t2.micro"
  key_name      = "docker"
  vpc_security_group_ids = [aws_security_group.gensogram_sg.id]

  tags = {
    Name = var.instance_name2
  }
}

# resource "aws_instance" "gensogram_server" {
#   ami           = "ami-06b21ccaeff8cd686"
#   instance_type = "t2.micro"
#   key_name = "docker"

#   tags = {
#     Name = "Kunle-Instance"
#   }
# }
# # Retrieve the API Key from Secrets Manager
# data "aws_secretsmanager_secret" "api_key_secret" {
#   name = "MyApiKeySecret"  # Replace with the actual secret name in Secrets Manager
# }

# data "aws_secretsmanager_secret_version" "api_key_version" {
#   secret_id = data.aws_secretsmanager_secret.api_key_secret.id
# }

# # API Gateway Rest API
# resource "aws_api_gateway_rest_api" "slack_api" {
#   name        = "SlackPostAPI"
#   description = "API Gateway to post messages to a Slack channel"
# }

# # Resource (endpoint path)
# resource "aws_api_gateway_resource" "post_to_slack" {
#   rest_api_id = aws_api_gateway_rest_api.slack_api.id
#   parent_id   = aws_api_gateway_rest_api.slack_api.root_resource_id
#   path_part   = "post-to-slack"
# }

# # Method (POST) with API Key required
# resource "aws_api_gateway_method" "post_method" {
#   rest_api_id      = aws_api_gateway_rest_api.slack_api.id
#   resource_id      = aws_api_gateway_resource.post_to_slack.id
#   http_method      = "POST"
#   authorization    = "NONE"
#   api_key_required = true
# }

# # Integration with Slack Incoming Webhook (HTTP Proxy)
# resource "aws_api_gateway_integration" "slack_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.slack_api.id
#   resource_id             = aws_api_gateway_resource.post_to_slack.id
#   http_method             = aws_api_gateway_method.post_method.http_method
#   integration_http_method = "POST"
#   type                    = "HTTP"
#   uri                     = "https://hooks.slack.com/services/AAAAAAAAAAAA"  # Replace with your Slack Webhook URL

#   request_templates = {
#     "application/json" = <<EOF
#       {
#         "text": "$input.body"
#       }
#     EOF
#   }
# }

# # Usage Plan to manage API key and rate limits
# resource "aws_api_gateway_usage_plan" "my_usage_plan" {
#   name = "MySlackAPIUsagePlan"
# }

# # Create an API Key in API Gateway with the value from Secrets Manager
# resource "aws_api_gateway_api_key" "my_api_key" {
#   name   = "MyApiKey"
#   value  = data.aws_secretsmanager_secret_version.api_key_version.secret_string
#   enabled = true
# }

# # Attach the API Key to the Usage Plan
# resource "aws_api_gateway_usage_plan_key" "my_usage_plan_key" {
#   key_id        = aws_api_gateway_api_key.my_api_key.id
#   key_type      = "API_KEY"
#   usage_plan_id = aws_api_gateway_usage_plan.my_usage_plan.id
# }

# # Deployment of API Gateway
# resource "aws_api_gateway_deployment" "slack_api_deployment" {
#   depends_on  = [aws_api_gateway_integration.slack_integration]
#   rest_api_id = aws_api_gateway_rest_api.slack_api.id
#   stage_name  = "prod"
# }

# # Output the API Gateway Endpoint URL
# output "api_gateway_url" {
#   value       = "https://${aws_api_gateway_rest_api.slack_api.id}.execute-api.us-west-1.amazonaws.com/prod/post-to-slack"
#   description = "The endpoint URL for posting messages to Slack through API Gateway"
# }

# resource "aws_secretsmanager_secret" "api_key_secret" {
#   name = "example"
#   name_prefix = "gensogram"
#   description = "This is a secret key for AWS"
# }
# Retrieve the API Key from Secrets Manager
data "aws_secretsmanager_secret" "api_key_secret" {
  name = "MyApiKeySecret"  # Ensure this matches the exact name in Secrets Manager
}

data "aws_secretsmanager_secret_version" "api_key_version" {
  secret_id = data.aws_secretsmanager_secret.api_key_secret.id
}

# API Gateway Rest API
resource "aws_api_gateway_rest_api" "slack_api" {
  name        = "SlackPostAPI"
  description = "API Gateway to post messages to a Slack channel"
}

# Resource (endpoint path)
resource "aws_api_gateway_resource" "post_to_slack" {
  rest_api_id = aws_api_gateway_rest_api.slack_api.id
  parent_id   = aws_api_gateway_rest_api.slack_api.root_resource_id
  path_part   = "post-to-slack"
}

# Method (POST) with API Key required
resource "aws_api_gateway_method" "post_method" {
  rest_api_id      = aws_api_gateway_rest_api.slack_api.id
  resource_id      = aws_api_gateway_resource.post_to_slack.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

# Integration with Slack Incoming Webhook (HTTP Proxy)
resource "aws_api_gateway_integration" "slack_integration" {
  rest_api_id             = aws_api_gateway_rest_api.slack_api.id
  resource_id             = aws_api_gateway_resource.post_to_slack.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "HTTP"
  uri                     = "https://hooks.slack.com/services/XXXXXXXXXXXXXXXXX"  # Replace with your Slack Webhook URL

  request_templates = {
  "application/json" = <<EOF
  {
    "text": "$util.escapeJavaScript($input.body)"
  }
  EOF
}
}

# Usage Plan to manage API key and rate limits
resource "aws_api_gateway_usage_plan" "my_usage_plan" {
  name = "MySlackAPIUsagePlan"
}

# Create an API Key in API Gateway with the value from Secrets Manager
resource "aws_api_gateway_api_key" "my_api_key" {
  name   = "MyApiKey"
  value  = data.aws_secretsmanager_secret_version.api_key_version.secret_string
  enabled = true
}

# Attach the API Key to the Usage Plan
resource "aws_api_gateway_usage_plan_key" "my_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.my_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.my_usage_plan.id
}

# Deployment of API Gateway
resource "aws_api_gateway_deployment" "slack_api_deployment" {
  depends_on  = [aws_api_gateway_integration.slack_integration]
  rest_api_id = aws_api_gateway_rest_api.slack_api.id
  stage_name  = "prod"
}

# Method Response
resource "aws_api_gateway_method_response" "post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.slack_api.id
  resource_id = aws_api_gateway_resource.post_to_slack.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"
}

# Integration Response
resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = aws_api_gateway_rest_api.slack_api.id
  resource_id = aws_api_gateway_resource.post_to_slack.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"
  selection_pattern = ".*"

  response_templates = {
    "application/json" = ""
  }
}


# Output the API Gateway Endpoint URL
output "api_gateway_url" {
  value       = "https://${aws_api_gateway_rest_api.slack_api.id}.execute-api.us-east-1.amazonaws.com/prod/post-to-slack"
  description = "The endpoint URL for posting messages to Slack through API Gateway"
}

module "ec2_instance" {
  source  = "../Terraform/module/ec2_instance" 

   
}
