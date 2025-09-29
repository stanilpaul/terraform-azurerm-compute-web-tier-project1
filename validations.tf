###############Validation help us to detect and put the conditions from plan###################
variable "instances" {
  type = map(object({
    name              = string
    subnet_id         = string
    size              = optional(string, "Standard_B1s")
    admin_username    = string
    password          = string
    cloud_init_file   = optional(string)
    data_disk_size_gb = optional(number, 4)
  }))

  validation {
    condition = alltrue([
      for i in values(var.instances) : can(regex("^[a-zA-Z0-9-]{1,30}$", i.name))
    ])
    error_message = "Le nom de chaque instance doit comporter 1–30 caractères alphanumériques ou '-'."
  }

  validation {
    condition = alltrue([
      for i in values(var.instances) : (
        length(i.password) >= 6 &&
        can(regex("[A-Z]", i.password)) &&
        can(regex("[0-9]", i.password))
      )
    ])
    error_message = "Chaque mot de passe doit faire min 6 caractères, contenir au moins une majuscule et un chiffre."
  }

  validation {
    condition = alltrue([
      for i in values(var.instances) : (
        i.data_disk_size_gb >= 1 && i.data_disk_size_gb <= 1024
      )
    ])
    error_message = "La taille des disques doit être comprise entre 1 et 1024 Go."
  }
}

