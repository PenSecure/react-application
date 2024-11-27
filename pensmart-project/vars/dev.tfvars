region     = "us-west-1"

az_count = 2
vpc_cidr = "172.24.0.0/16"

######## mysql ############
publicly_accessible = true # Make False for Production
port                = 5432 # For Production change to non default Port
deletion_protection = false
db_instance_class   = "db.t3.micro" # Change to your desired Instance Type
db_name             = "postgres"
engine_version      = "15.7"
multi_az            = false  ## Set as true for Production

############ ecr ################
ecr_names = [
  "spring",
  "dotnet"
]
force_delete = true

