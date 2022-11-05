data "http" "myip"{
    url="http://ipv4.icanhazip.com"
    }

resource "aws_security_group" "bastion" {
    name="allow_ssh"
    description = "allow ssh inbound traffic"
vpc_id=data.aws_vpc.vpc.id
ingress {
    description = "ssh from admin"
    from_port=22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${chomp(data.http.myip.body)}/32" ]

}

egress {
    from_port=0
    to_port = 0
    protocol = "-1"
    cidr_blocks=["0.0.0.0/0"] 
   ipv6_cidr_blocks = ["::/0"] 
}
tags={
    Name="stage-bastion-sg",
    terraform="true"
    }
}












