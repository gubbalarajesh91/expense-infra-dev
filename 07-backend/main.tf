module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"

  instance_type          = "t3.micro"
 

  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  #covert StringList to list and get first element
  subnet_id              = local.private_subnet_id
  ami = data.aws_ami.ami_info.id

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
    }
  )
}


resource "null_resource" "backend" {
    triggers = {
        instance_id = module.backend.id # this will be triggered everytime instance created
    }

    connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = module.backend.private_ip
  }

  provisioner "file" {
    source = "${var.common_tags.Component}.sh"
    destination = "/tmp/${var.common_tags.Component}.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/${var.common_tags.Component}.sh",
      "sudo sh /tmp/${var.common_tags.Component}.sh ${var.common_tags.Component}${var.environment}",
      
    ]
  }
}

resource "aws_ec2_instance_state" "backend" {
  instance_id = module.backend.id
  state       = "stopped"
  #stop the server only when null resorce completed
  depends_on = [ null_resource.backend ]
}

resource "aws_ami_from_instance" "backend" {
  name               = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  source_instance_id = module.backend.id
  depends_on = [ aws_ec2_instance_state.backend ]
}

resource "null_resource" "backend" {
    triggers = {
        instance_id = module.backend.id # this will be triggered everytime instance created
    }

    connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = module.backend.private_ip
  }



  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${module.backend.id}"
  }
  depends_on = [ aws_ami_from_instance.backend ]
}

resource "aws_lb_target_group" "backend" {
  name     = "${var.common_tags.Component}${var.common_tags.Component}${var.environment}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  health_check {
    path = "/health"
    port = 8080
    healthy_threshold = 2
    unhealthy_threshold = 2
    matcher = "200"  # has to be HTTP 200 or fails
  }
}

resource "aws_launch_template" "backend" {
  name = "${var.common_tags.Component}${var.common_tags.Component}${var.environment}"


  image_id = aws_ami_from_instance.backend.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t3.micro"
  update_default_version = true
  vpc_security_group_ids = [data.aws_ssm_parameter.vpc_id.value]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
        var.common_tags,
        {
         Name = "${var.common_tags.Component}${var.common_tags.Component}${var.environment}"
        }
    ) 
  }
}


resource "aws_autoscaling_group" "backend" {
  name                      = "${var.common_tags.Component}${var.common_tags.Component}${var.environment}"
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 1
  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
  vpc_zone_identifier       = split(",", data.aws_ssm_parameter.private_subnet_ids.value)

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }


  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-${var.common_tags}"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Project"
    value               = "${var.project_name}"
    propagate_at_launch = false
  }
}