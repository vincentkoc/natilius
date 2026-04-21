# Enterprise & MDM Support

Natilius is designed to work seamlessly in enterprise environments with MDM (Mobile Device Management) solutions.

---

## Supported MDM Providers

| Provider                 | Detection | Integration Level             |
| ------------------------ | --------- | ----------------------------- |
| **Jamf Pro**             | Full      | Agent status, policies, recon |
| **JumpCloud**            | Full      | Agent status, system key      |
| **Kandji**               | Detection | Agent detection               |
| **Mosyle**               | Detection | Profile detection             |
| **Microsoft Intune**     | Detection | Company Portal check          |
| **VMware Workspace ONE** | Detection | Profile detection             |
| **Generic MDM**          | Basic     | Enrollment status only        |

---

## How It Works

### Automatic Detection

Run `natilius doctor` to see your MDM status:

```bash
natilius doctor
```

Output includes:

```
Enterprise/MDM
  ✓ MDM: Enrolled (JumpCloud)
    https://apple.mdm.jumpcloud.com/command
  ○ DEP/ABM: Not enrolled
  ✓ JumpCloud Agent: Installed
    System Key: a1b2c3d4...
```

### MDM-Aware Behavior

When Natilius detects an MDM enrollment:

1. **Warns about restrictions** — Some settings may be managed by your organization
2. **Respects policies** — Won't override MDM-managed configurations (when `RESPECT_MDM_POLICIES=true`)
3. **Provides visibility** — Shows MDM status in `doctor` output

---

## Configuration

Add these options to your `~/.natiliusrc`:

```bash
# Enterprise/MDM Configuration
ENTERPRISE_MODE=false          # Set true for managed environments
RESPECT_MDM_POLICIES=true      # Skip settings that conflict with MDM
JAMF_RECON_ON_COMPLETE=false   # Run Jamf inventory update after setup
```

---

## Jamf Pro Integration

### Features

- **Agent Detection** — Detects Jamf binary and version
- **Policy Triggers** — Run Jamf policies from Natilius
- **Recon Support** — Update Jamf inventory after setup
- **Jamf Connect** — Detects Jamf Connect installation
- **Jamf Protect** — Detects Jamf Protect status

### Using with Jamf

```bash
# Check Jamf status
natilius doctor

# Run setup with Jamf recon on completion
JAMF_RECON_ON_COMPLETE=true natilius setup
```

### Programmatic Access

The `lib/mdm_utils.sh` provides functions for Jamf integration:

```bash
# Source the utilities
source /path/to/natilius/lib/mdm_utils.sh

# Check enrollment
if is_jamf_enrolled; then
    echo "Device is managed by Jamf"
fi

# Run a policy
run_jamf_policy "install_dev_tools"

# Update inventory
jamf_recon
```

---

## JumpCloud Integration

### Features

- **Agent Detection** — Detects JumpCloud agent installation
- **System Key** — Shows truncated system key for verification
- **MDM Profile** — Detects JumpCloud MDM enrollment

### Using with JumpCloud

```bash
# Check JumpCloud status
natilius doctor
```

Output:

```
Enterprise/MDM
  ✓ MDM: Enrolled (JumpCloud)
    https://apple.mdm.jumpcloud.com/command
  ✓ JumpCloud Agent: Installed
    System Key: a1b2c3d4...
```

### Programmatic Access

```bash
source /path/to/natilius/lib/mdm_utils.sh

# Check enrollment
if is_jumpcloud_enrolled; then
    echo "Device is managed by JumpCloud"
fi

# Get system key
system_key=$(get_jumpcloud_system_key)
```

---

## Terraform/Automation Integration

### Environment Variables

| Variable                    | Description                           |
| --------------------------- | ------------------------------------- |
| `SKIP_SUDO=true`            | Skip sudo prompts (for NOPASSWD sudo) |
| `NONINTERACTIVE=true`       | No interactive prompts                |
| `ENTERPRISE_MODE=true`      | Enable enterprise-aware behavior      |
| `RESPECT_MDM_POLICIES=true` | Don't override MDM settings           |

### Terraform Example

```hcl
resource "null_resource" "mac_setup" {
  connection {
    type        = "ssh"
    host        = var.mac_host
    user        = var.mac_user
    private_key = file(var.ssh_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh | bash",
      "ENTERPRISE_MODE=true SKIP_SUDO=true natilius --quiet setup"
    ]
  }
}
```

### Ansible Example

```yaml
- name: Setup Mac with Natilius
  hosts: macs
  tasks:
    - name: Install Natilius
      shell: |
        curl -fsSL https://raw.githubusercontent.com/vincentkoc/natilius/main/install.sh | bash

    - name: Run Natilius setup
      environment:
        ENTERPRISE_MODE: "true"
        SKIP_SUDO: "true"
        NONINTERACTIVE: "true"
      shell: natilius --quiet setup
```

---

## MDM Utility Functions

The `lib/mdm_utils.sh` library provides these functions:

### Generic MDM

| Function                 | Description                                   |
| ------------------------ | --------------------------------------------- |
| `is_mdm_enrolled`        | Check if device is MDM enrolled               |
| `is_dep_enrolled`        | Check if enrolled via DEP/ABM                 |
| `get_mdm_provider`       | Get MDM provider name (jamf, jumpcloud, etc.) |
| `get_mdm_provider_name`  | Get human-readable provider name              |
| `get_mdm_server_url`     | Get MDM server URL                            |
| `is_managed_environment` | Check if device is managed                    |
| `warn_if_managed`        | Log warning if managed                        |
| `has_profile`            | Check if a config profile is installed        |

### Jamf-Specific

| Function                  | Description                        |
| ------------------------- | ---------------------------------- |
| `is_jamf_enrolled`        | Check if enrolled in Jamf          |
| `get_jamf_binary`         | Get path to jamf binary            |
| `get_jamf_version`        | Get Jamf agent version             |
| `has_jamf_connect`        | Check if Jamf Connect is installed |
| `has_jamf_protect`        | Check if Jamf Protect is running   |
| `run_jamf_policy`         | Run a Jamf policy by trigger       |
| `check_jamf_connectivity` | Check connection to Jamf server    |
| `jamf_recon`              | Update Jamf inventory              |

### JumpCloud-Specific

| Function                   | Description                    |
| -------------------------- | ------------------------------ |
| `is_jumpcloud_enrolled`    | Check if enrolled in JumpCloud |
| `get_jumpcloud_binary`     | Get path to JumpCloud agent    |
| `check_jumpcloud_status`   | Check agent status             |
| `get_jumpcloud_system_key` | Get system key                 |

---

## Best Practices

### For IT Administrators

1. **Test in staging** — Run `natilius setup --check` before deploying
2. **Use profiles** — Create organization-specific profiles
3. **Respect MDM** — Enable `RESPECT_MDM_POLICIES=true` to avoid conflicts
4. **Update inventory** — Enable `JAMF_RECON_ON_COMPLETE=true` if using Jamf

### For Developers

1. **Check MDM status** — Run `natilius doctor` to understand your environment
2. **Report issues** — Some tools may fail due to MDM restrictions
3. **Use enterprise profile** — Ask IT for an organization-approved profile

---

## Troubleshooting

### "Permission denied" errors

Your MDM may be restricting certain operations. Check with your IT department.

### Settings keep reverting

Your MDM is likely enforcing configuration profiles. These take precedence over local settings.

### Jamf policy not running

```bash
# Check Jamf connectivity
/usr/local/jamf/bin/jamf checkJSSConnection

# Check policy exists
/usr/local/jamf/bin/jamf policy -trigger <trigger_name> -verbose
```

### JumpCloud agent not detected

```bash
# Check if agent is installed
ls -la /opt/jc/bin/jumpcloud-agent

# Check agent status
/opt/jc/bin/jumpcloud-agent --status
```
