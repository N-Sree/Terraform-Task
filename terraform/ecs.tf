resource "aws_ecs_cluster" "main" {
name = "${var.project_name}-cluster"
}

resource "aws_iam_role" "ecs_task_execution" {
name = "${var.project_name}-ecs-task-execution-role"

assume_role_policy = jsonencode({
Version = "2012-10-17",
Statement = [
{
Effect = "Allow",
Principal = {
Service = "ecs-tasks.amazonaws.com"
},
Action = "sts:AssumeRole"
}
]
})
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
role = aws_iam_role.ecs_task_execution.name
policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "app" {
family = "${var.project_name}-task"
requires_compatibilities = ["FARGATE"]
network_mode = "awsvpc"
cpu = "256"
memory = "512"
execution_role_arn = aws_iam_role.ecs_task_execution.arn

container_definitions = jsonencode([
{
name = "simpletimeservice"
image = var.container_image
portMappings = [
{
containerPort = 8080
hostPort = 8080
protocol = "tcp"
}
]
}
])
}

resource "aws_ecs_service" "app" {
name = "${var.project_name}-service"
cluster = aws_ecs_cluster.main.id
task_definition = aws_ecs_task_definition.app.arn
launch_type = "FARGATE"
desired_count = 1

network_configuration {
subnets = module.vpc.private_subnets
security_groups = [aws_security_group.ecs_sg.id]
assign_public_ip = false
}

load_balancer {
target_group_arn = aws_lb_target_group.app.arn
container_name = "simpletimeservice"
container_port = 8080
}

depends_on = [
aws_lb_listener.http
]
}