# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# ALARM variables
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

variable "unique_name" {}
variable "stack_prefix" {}

variable "rds_instance" {
  description = "RDS Instance to monitor"
}
variable "up_threshold" {
  # TODO: Change this accordingly, present 80.0
  default     = "60.0"
  description = "CPU High Alarm threshold"
}
variable "up_evaluations" {
  # TODO: Change this accordingly, present 10
  default     = "5"
  description = "CPU High Alarm evaluations periods"
}
variable "down_threshold" {
  # TODO: Change this accordingly, present 10.0
  default     = "20.0"
  description = "CPU Low Alarm threshold"
}
variable "down_evaluations" {
  # TODO: Change this accordingly, present 5
  default     = "2"
  description = "CPU Low Alarm evaluation periods"
}
variable "credit_threshold" {
  # TODO: Change this accordingly, present 2.0
  default     = "2.0"
  description = "CPU Credits Exhausted Alarm threshold"
}
variable "credit_evaluations" {
  # TODO: Change this accordingly, present 10
  default     = "10"
  description = "CPU Credits Exhausted Alarm evaluation periods"
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# ALARM resources
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

# Create Cloudwatch Alarm for RDS CPU HIGH
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "aws_cloudwatch_metric_alarm" "reds-alarms-ReDSAlarmHigh" {
  alarm_name          = "${var.stack_prefix}-alarms-ReDSAlarmHigh-${var.unique_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.up_evaluations}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.up_threshold}"
  alarm_description   = "CPU High Alarm"
  dimensions = {
    DBInstanceIdentifier = "${var.rds_instance}"
  }
}

# Create Cloudwatch Alarm for RDS CPU LOW
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "aws_cloudwatch_metric_alarm" "reds-alarms-ReDSAlarmLow" {
  alarm_name          = "${var.stack_prefix}-alarms-ReDSAlarmLow-${var.unique_name}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.down_evaluations}"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.down_threshold}"
  alarm_description   = "CPU Low Alarm"
  dimensions = {
    DBInstanceIdentifier = "${var.rds_instance}"
  }
}

# Create Cloudwatch Alarm for "Credits"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

resource "aws_cloudwatch_metric_alarm" "reds-alarms-ReDSNoCredits" {
  alarm_name          = "${var.stack_prefix}-alarms-ReDSNoCredits-${var.unique_name}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "${var.credit_evaluations}"
  # TODO: change this to DatabaseConnections or add new alarm
  metric_name       = "CPUCreditBalance"
  namespace         = "AWS/RDS"
  period            = "60"
  statistic         = "Maximum"
  threshold         = "${var.credit_threshold}"
  alarm_description = "CPU Credits Exhausted Alarm"
  dimensions = {
    DBInstanceIdentifier = "${var.rds_instance}"
  }
}

# Output all alarm IDs
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

output "reds-alarms-ReDSAlarmHigh_id" {
  value = "${aws_cloudwatch_metric_alarm.reds-alarms-ReDSAlarmHigh.id}"
}
output "reds-alarms-ReDSAlarmLow_id" {
  value = "${aws_cloudwatch_metric_alarm.reds-alarms-ReDSAlarmLow.id}"
}
output "reds-alarms-ReDSNoCredits_id" {
  value = "${aws_cloudwatch_metric_alarm.reds-alarms-ReDSNoCredits.id}"
}
