#############################################################################
#                                 AZURE                                     #
#############################################################################
resource "azurerm_resource_group" "eshop_rg" {
  provider = azurerm.azure
  name     = var.az_resource_group
  location = var.az_location
}

resource "azurerm_sql_server" "eshop-mssqlserver" {
  provider                     = azurerm.azure
  name                         = "eshop-mssqlserver"
  resource_group_name          = azurerm_resource_group.eshop_rg.name
  location                     = azurerm_resource_group.eshop_rg.location
  version                      = "12.0"
  administrator_login          = "ecanarys14"
  administrator_login_password = "Canarys@14"
}

#############################################################################
#                                   AWS                                     #
#############################################################################
resource "aws_instance" "eshoponweb" {
  provider               = aws.aws

  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_pair
  vpc_security_group_ids = [aws_security_group.eshop_sg.id]
  user_data              = <<-EOF
    #!/bin/bash
    
    sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
    sudo yum install dotnet-sdk-7.0 -y
    sudo yum install aspnetcore-runtime-7.0 -y
    echo 'export PATH=$PATH:/usr/share/dotnet' >> ~/.bash_profile
    # Load the updated shell configuration
    source ~/.bash_profile
    sudo yum install perl -y
    sudo mkdir /home/ec2-user/publish

    # installing github runner in ec2
    # mkdir actions-runner && cd actions-runner
    # curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
    # echo "29fc8cf2dab4c195bb147384e7e2c94cfd4d4022c793b346a6175435265aa278  actions-runner-linux-x64-2.311.0.tar.gz" | shasum -a 256 -c
    # tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
    # ./config.sh --url https://github.com/DevOpsathon/eShop --token A3MSHZIAZRQDXRDBV6L2EDTFN3CVG
    # sudo ./svc.sh install
    # sudo ./svc.sh start

    sudo cat > /etc/systemd/system/myeshop.service << EOL
    [Unit]
    Description=Example of ASP.NET Core MVC App running on Amazon Linux

    [Service]
    WorkingDirectory=/home/ec2-user/publish
    ExecStart=/usr/bin/dotnet /home/ec2-user/publish/Web.dll --urls "http://0.0.0.0:80"
    Restart=always
    RestartSec=10
    KillSignal=SIGINT
    SyslogIdentifier=my-mvc-app
    Environment=ASPNETCORE_ENVIRONMENT=Production

    [Install]
    WantedBy=multi-user.target
    EOL
EOF

  tags = {
    "Name" = "eshoponweb"
  }
}

resource "aws_security_group" "eshop_sg" {
  provider    = aws.aws
  name        = "eshop_sg"
  description = "Allow inbound traffic"

  dynamic "ingress" {
    for_each = [80, 22, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "eshop_sg"
  }
}
