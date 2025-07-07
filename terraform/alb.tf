resource "aws_lb" "app" {
name = "simpletimeservice-lb"
load_balancer_type = "application"
subnets = module.vpc.public_subnets
security_groups = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "app" {
name = "simpletimeservice-tg"
port = 8080
protocol = "HTTP"
vpc_id = module.vpc.vpc_id
target_type = "ip"
health_check {
path = "/"
matcher = "200"
interval = 30
timeout = 5
healthy_threshold = 2
unhealthy_threshold = 2
}
}

resource "aws_lb_listener" "http" {
load_balancer_arn = aws_lb.app.arn
port = 80
protocol = "HTTP"

default_action {
type = "forward"
target_group_arn = aws_lb_target_group.app.arn
}
}
