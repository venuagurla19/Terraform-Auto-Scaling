variable "cluster_name" {
    description = "name of the EKS cluster"
    type        = string

}

variable "cluster_version" {
    description = "version of the EKS cluster"
    type        = string 
}

variable "subnet_ids" {
    description = "list of subnet IDs for the EKS cluster"
    type        = list(string)
}

variable "node_group" {
    description = "node group configuration"
    type = map(object({
        instance_types = list(string)
        capacity_types = string
        scaling_config = object({
            desired_size = number
            max_size = number
            min_size = number
            })
        }))
    }
