region         = "ap-northeast-1"
environment    = "dev"
vpc_cidr       = "10.0.0.0/16"

cluster_name    = "llm-share-dev"
cluster_version = "1.28"

desired_size = 1
max_size     = 2
min_size     = 1
instance_types = ["t3.medium"]

db_name     = "llm_share_dev"
db_username = "llmadmin"

redis_cluster_name = "llm-share-dev-redis"
redis_node_type    = "cache.t3.micro"
redis_num_cache_nodes = 1
