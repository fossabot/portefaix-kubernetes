# Copyright (C) 2021 Nicolas Lamirault <nicolas.lamirault@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "1.13.4"

  bus_name = local.eventbridge_bus_name

  rules = {
    orders = {
      description   = "Capture SecurityHub data"
      event_pattern = jsonencode({ "source" : ["aws.securityhub"] })
      enabled       = true
    }
  }

  targets = {
    orders = [
      {
        name = "send-orders-to-sns"
        arn  = module.sns_topic.sns_topic_arn
      },
      # {
      #   name            = "send-orders-to-sqs"
      #   arn             = module.queue.sqs_queue_arn
      #   # dead_letter_arn = aws_sqs_queue.dlq.arn
      # },
      # {
      #   name = "log-orders-to-cloudwatch"
      #   arn  = aws_cloudwatch_log_group.this.arn
      # }
    ]
  }

  tags = merge({
    Name = local.eventbridge_bus_name,
  }, var.tags)
}