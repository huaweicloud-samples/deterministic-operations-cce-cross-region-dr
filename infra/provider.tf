# Provider configurations for multi-region deployment
provider "huaweicloud" {
  region = var.primary_region
}

provider "huaweicloud" {
  region = var.dr_region
  alias  = "dr"
}
