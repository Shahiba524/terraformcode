
resource "aws_security_group" "alb" {
    name="allow_end user"
    description = "allow end user  inbound traffic"
vpc_id=data.aws_vpc.vpc.id
ingress {
    description = "end user"
    from_port=80
    to_port =80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0"]
}

egress {
    from_port=0
    to_port = 0
    protocol = "-1"
    cidr_blocks=["0.0.0.0/0"] 
   ipv6_cidr_blocks = ["::/0"] 
}
tags={
    names="alb-sg",
    terraform="true"
    }
}



