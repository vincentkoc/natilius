# Terraform Integration

Provision Mac developer environments with Terraform.

## Quick Start

```hcl
resource "null_resource" "mac_setup" {
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s devops"
    ]
  }
}
```

## Full Example

```hcl
variable "mac_host" {
  type = string
}

variable "mac_user" {
  default = "admin"
}

variable "ssh_key_path" {
  type = string
}

variable "profile" {
  default = "devops"
}

resource "null_resource" "mac_setup" {
  connection {
    type        = "ssh"
    host        = var.mac_host
    user        = var.mac_user
    private_key = file(var.ssh_key_path)
    timeout     = "30m"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/scripts/terraform-provision.sh | bash -s ${var.profile}"
    ]
  }
}
```

## Custom Configuration

```hcl
resource "null_resource" "mac_setup" {
  connection {
    type = "ssh"
    host = var.mac_host
    user = var.mac_user
  }

  # Upload custom config
  provisioner "file" {
    source      = "configs/${var.team}.natiliusrc"
    destination = "~/.natiliusrc"
  }

  # Install and run
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh | SKIP_RUN=true bash",
      "NONINTERACTIVE=true ~/.natilius/natilius.sh setup"
    ]
  }
}
```

## Multiple Macs

```hcl
variable "macs" {
  type = map(object({
    host    = string
    profile = string
  }))
  default = {
    "dev-1" = { host = "192.168.1.10", profile = "developer" }
    "dev-2" = { host = "192.168.1.11", profile = "devops" }
  }
}

resource "null_resource" "mac_setup" {
  for_each = var.macs

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL .../terraform-provision.sh | bash -s ${each.value.profile}"
    ]
  }
}
```
