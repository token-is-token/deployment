region         = "ap-northeast-1"
environment    = "staging"
vpc_cidr       = "10.1.0.0/16"

cluster_name    = "llm-share-staging"
cluster_version = "1.28"

desired_size = 2
max_size     = 4
min_size     = 2
instance_types = ["t3.medium"]

db_name     = "llm_share_staging"
db_username = "llmadmin"

redis_cluster_name = "llm-share-staging-redis"
redis_node_type    = "cache.t3.small"
redis_num_cache_nodes = 2
