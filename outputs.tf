output "Jenkins-Main-Node-Public-IP" {
  value = aws_instance.jenkins_master.public_ip
}

output "Jenkins-Worker-Public-IPs" {
  value = {
    for instance in aws_instance.jenkins_worker :
    instance.id => instance.public_ip
  }
}
