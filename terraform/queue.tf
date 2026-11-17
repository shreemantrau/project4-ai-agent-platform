// Storage account that holds the job queue. Separate from the state account
// so destroying the queue can never touch Terraform's own state. The name
// must be globally unique: 3-24 characters, lowercase letters and digits only.
resource "azurerm_storage_account" "queue" {
  name                            = "stp4queueshreyas"
  resource_group_name             = data.azurerm_resource_group.main.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS" // cheapest redundancy tier
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = local.tags
}

// The queue itself: the API adds one message per job, workers read and
// delete them. KEDA will watch this queue's length to scale the workers.
resource "azurerm_storage_queue" "jobs" {
  name               = "jobs"
  storage_account_id = azurerm_storage_account.queue.id
}