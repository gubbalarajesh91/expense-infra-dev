resource "aws_ssm_parameter" "vpc_id" {
    name = "/${var.project_name}/${var.environment}/vpc_id"
    type = "String" #CAP S is AWS notation
    value = module.vpc.vpc_id
  
}

resource "aws_ssm_parameter" "public_subnet_ids" {
    name = "/${var.project_name}/${var.environment}/public_subnet_ids"
    type = "StringList" #CAP S is AWS notation
    value = join(",",module.vpc.public_subnet_ids) # converting list StringList
  
}

#["id1","id2"] terraform format
# id1, id2 -> AWS SSM format
resource "aws_ssm_parameter" "private_subnet_ids" {
    name = "/${var.project_name}/${var.environment}/private_subnet_ids"
    type = "StringList" #CAP S is AWS notation
    value = join(",",module.vpc.private_subnet_ids)
  
}

resource "aws_ssm_parameter" "db_subnet_group_name" {
    name = "/${var.project_name}/${var.environment}/db_subnet_group_name"
    type = "String" #CAP S is AWS notation
    value = module.vpc.Database_subnet_group_name
  
}

