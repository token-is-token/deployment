region         = "ap-northeast-1"
environment    = "prod"
vpc_cidr       = "10.2.0.0/16"

cluster_name    = "llm-share-prod"
cluster_version = "1.28"

desired_size = 3
max_size     = 6
min_size     = 3
instance_types = ["t3.large"]

db_name     = "llm_share_prod"
db_username = "llmadmin"

redis_cluster_name = "llm-share-prod-redis"
redis_node_type    = "cache.r6g.large"
redis_num_cache_nodes = 2
