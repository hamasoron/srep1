region_name                       = "ap-northeast-1" ########## [変更不可](リージョンによってAZの数が異なるため正しく動作しない)［AZの数とbackend.tfを調整すれば変更可能］
system_name                       = "srep1"      ########## [変更可能](例: terraform, hamasoron)
environment_name                  = "prod"           ########## [変更可能](例: prod, stg, dev)
create_protected_ngw_associations = false             ########## [変更可能](例: true, false)
vpc_cidr                          = "10.0.0.0/19"    ########## [変更可能](例: 10.0.0.0/19, 10.0.32.0/19, 10.0.64.0/19)
subnet_list = [                                      ########## [変更可能](vpc_cidrの変更によって変更が必要)
  { name = "1a", cidr_block = "10.0.0.0/24", type = "public" },
  { name = "1c", cidr_block = "10.0.1.0/24", type = "public" },
  { name = "1a", cidr_block = "10.0.2.0/24", type = "protected" },
  { name = "1c", cidr_block = "10.0.3.0/24", type = "protected" },
  { name = "1a", cidr_block = "10.0.4.0/24", type = "private" },
  { name = "1c", cidr_block = "10.0.5.0/24", type = "private" },
]
route_table_list = [ ########## [変更可能](vpc_cidrの変更によって変更が必要)
  { name = "public", subnet = "1a", gateway_type = "internet_gateway" },
  { name = "public", subnet = "1c", gateway_type = "internet_gateway" },
  { name = "protected", subnet = "1a", gateway_type = "nat_gateway" },
  { name = "protected", subnet = "1c", gateway_type = "nat_gateway" },
  { name = "private", subnet = "1a", gateway_type = "none" },
  { name = "private", subnet = "1c", gateway_type = "none" },
]
sg_definitions = { ########## [変更可能](セキュリティグループの定義を変更する場合) 
  "ecs" = {
    description = "ECS Security Group"
    ingress = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = []
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = []
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
  "alb" = {
    description = "ALB Security Group"
    ingress = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
  "rds" = {
    description = "RDS Security Group"
    ingress = [
      {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = []
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
  "ec2" = {
    description = "EC2 Security Group"
    ingress = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    egress = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}

# 注意: RDSパスワードはセキュリティ上の理由からこのファイルに含めないでください
# db_password = "password" # 代わりに環境変数 TF_VAR_db_password や -var オプションで渡してください
db_password = "i7V956YP"
github_repo = "hamasoron/srep1"

# ECSサービスのタスク数
# 初回デプロイ時は0に設定し、ECRにイメージがプッシュされた後に1に変更してください
api_desired_count = 0
front_desired_count = 0