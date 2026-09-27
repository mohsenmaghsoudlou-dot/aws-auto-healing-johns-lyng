# Terraform plan review

On 27 September 2026, the project author ran the following command against the
deployed Sydney environment:

```powershell
$env:AWS_PROFILE = "autoheal"
terraform plan -no-color -detailed-exitcode
```

The captured output confirms:

```text
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
```

See the [captured plan output](evidence/terraform-plan.txt), including resource
refresh lines. The AWS account ID has been replaced with `<AWS_ACCOUNT_ID>`;
no other output was changed except line-ending normalization. The source file
was last written at 17:17 on 27 September 2026 (Australia/Sydney).

This verifies a repeat plan proposed no changes to the deployed Sydney
configuration at the time of the run. It is not an initial creation plan or a
validation of the proposed Mumbai configuration. No apply was performed.
The exit code was not included in the captured file.

To reproduce, follow the README authentication and initialization steps, then
run the command above. With `-detailed-exitcode`, 0 means no changes, 1 means an
error and 2 means proposed changes. A fresh checkout without the deployment's
local state will instead propose creating resources.
