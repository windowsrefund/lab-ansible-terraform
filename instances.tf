# Get AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.region_master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ssm_parameter" "linuxAmiOregon" {
  provider = aws.region_worker
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Add public SSH key to EC2 instances in us-east-1
resource "aws_key_pair" "master_key" {
  provider   = aws.region_master
  key_name   = "jenkins"
  public_key = file("~/.ssh/linuxacademy_6975.pub")
}

# Add public SSH key to EC2 instances in us-weast-2
resource "aws_key_pair" "worker_key" {
  provider   = aws.region_worker
  key_name   = "jenkins"
  public_key = file("~/.ssh/linuxacademy_6975.pub")
}

# Bootstrap EC2 instance in us-east-1
resource "aws_instance" "jenkins_master" {
  provider                    = aws.region_master
  ami                         = data.aws_ssm_parameter.linuxAmi.value
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.master_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  subnet_id                   = aws_subnet.subnet_1_master.id

  tags = {
    Name = "jenkins_master_tf"
  }

  depends_on = [aws_main_route_table_association.set_master_default_rt_assoc]

  provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.aws_profile} ec2 wait instance-status-ok --region ${var.aws_region_master} --instance-ids ${self.id}
ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/jenkins-master-sample.yaml
EOF
  }

}

# Bootstrap EC2 instances in us-west-2
resource "aws_instance" "jenkins_worker" {
  count = var.workers_count

  provider                    = aws.region_worker
  ami                         = data.aws_ssm_parameter.linuxAmiOregon.value
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.worker_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins_sg_worker.id]
  subnet_id                   = aws_subnet.subnet_1_worker.id

  tags = {
    Name = join("_", ["jenkins_worker_tf", count.index + 1])
  }

  depends_on = [aws_main_route_table_association.set_worker_default_rt_assoc, aws_instance.jenkins_master]

  provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.aws_profile} ec2 wait instance-status-ok --region ${var.aws_region_worker} --instance-ids ${self.id}
ansible-playbook --extra-vars 'passed_in_hosts=tag_Name_${self.tags.Name}' ansible_templates/jenkins-worker-sample.yaml
EOF
  }
}
