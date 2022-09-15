
resource "aws_security_group" "apache" {
    name="allow end user"
    description = "allow apache inbound traffic"
vpc_id=data.aws_vpc.vpc.id
ingress {
    description = "ssh from admin"
    from_port=22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.bastion.id]
}
ingress {
    description = "for alb end users"
    from_port=80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.alb.id]
}
tags={
    Name="stage-bastion-sg",
    terraform="true"
    }

}
