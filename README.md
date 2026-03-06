# SimilarWeb Salesforce Core

Salesforce DX project containing the core Salesforce customizations for SimilarWeb.

## Project Structure

```
force-app/
└── main/
    └── default/
        ├── applications/     # Custom applications
        ├── classes/          # Apex classes
        ├── triggers/         # Apex triggers
        ├── pages/            # Visualforce pages
        ├── objects/          # Custom objects and fields
        ├── permissionsets/   # Permission sets
        ├── staticresources/  # Static resources
        └── tabs/             # Custom tabs
```

## Prerequisites

- [Salesforce CLI](https://developer.salesforce.com/tools/sfdxcli)
- Access to SimilarWeb Salesforce org

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/similarweb/salesforce.git
   cd salesforce
   ```

2. **Authenticate with your Salesforce org**
   ```bash
   sf org login web --alias my-org
   ```

3. **Deploy to your org**
   ```bash
   sf project deploy start --target-org my-org
   ```

## Development Workflow

### Retrieve metadata from org
```bash
sf project retrieve start --target-org my-org
```

### Deploy changes to org
```bash
sf project deploy start --target-org my-org
```

### Deploy specific metadata
```bash
sf project deploy start --source-dir force-app/main/default/classes --target-org my-org
```

## Configuration

- `sfdx-project.json` - Project configuration
- `manifest/package.xml` - Package manifest for deployments

## Resources

- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
