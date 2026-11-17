// The Azure subscription Terraform builds in. No default on purpose: the
// value comes from terraform.tfvars (which stays out of git), so the ID
// is never hardcoded in the repo.
variable "subscription_id"{
    description = "Azure Subscription ID which we need to use"
    type = string
}

// Region for everything in this project. Kept as a variable so a region
// change (quota or capacity issues) is a one-line edit, not a code hunt.
variable "location" {
  description = "Azure region for all resources"
  type = string
  default = "westus2"
}

// The resource group already exists (created with the CLI because the
// state storage lives inside it). Terraform looks it up by name instead
// of creating it, so a destroy never tries to delete the group holding
// its own state.
variable "resource_group_name" {
  description = "Resource Group to be used for this project"
  type = string
  default = "rg-project4-ai-platform"
}