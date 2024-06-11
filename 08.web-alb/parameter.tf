resource "aws_ssm_parameter" "web_alb_listener_arn" {
    name = "/${var.project_name}/${var.environment}/web_alb_listener_arn"
    type = "String" #CAP S is AWS notation
    value = aws_lb_listener.http.arn


resorce "aws_ssm_parameter" "web_alb_listener_arn_https" {
    name = "/${var.project_name}/${var.environment}/web_alb_listener_arn_https"
    type = "String" #CAP S is AWS notation
    value = aws_lb_listener.https.arn