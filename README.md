# Google Sheets Excel Template Looker Action Hub

A standalone Looker Action Hub hosting the Google Sheets Excel Template action (`google-sheet-xlsx-template`).

Merges query data from Looker into pre-formatted Excel (`.xlsx`) templates stored in Google Drive, or exports custom Looker [Report Table visualizations](https://www.lkr.dev/docs/visualizations/viz-report-table-marketplace2/) directly into Google Drive spreadsheets.

---

## Why Use This Action

Standard CSV or Excel exports from Looker don't include custom spreadsheet formatting, formulas, or pre-designed visual layouts. This action enables you to:

- Fill pre-designed `.xlsx` templates that contain company logos, custom typography, specific column widths, and color schemes.
- Preserve live Excel formulas such as `=SUM()` or `=VLOOKUP()`. As data rows expand during exports, cell references and summary formulas adjust automatically.
- Export Looker Report Table visualizations directly into `.xlsx` files with multi-level row subtotals, custom themes (`Looker` or `Traditional`), and number formatting.
- Deliver completed workbooks directly to specific Google Drive folders or Shared Drives.

---

## Template Placeholders

Design templates using these placeholder patterns in any cell:

| Expression Pattern | Description | Example |
| :--- | :--- | :--- |
| `{{ _built_in.run_at }}` | Timestamp when the query ran | `2026-06-24T18:20:22Z` |
| `{{ _built_in.title }}` | Scheduled plan title | `Weekly Sales Report` |
| `{{ _built_in.description }}` | Scheduled plan description | `Quarterly update` |
| `{{ _filters.view_name.field_name }}` | Applied query filter value | `California` |
| `{{ fields.view_name.field_name.label }}` | Field label string | `State` |
| `{{ fields._columns[index].label }}` | Label of the N-th column in query schema (0-indexed) | `{{ fields._columns[0].label }}` |
| `{{ data[index].view_name.field_name }}` | Zero-indexed explicit row lookup | `{{ data[0].products.brand }}` |
| `{{ data.view_name.field_name }}` | Field value for current row in repeating data section | `{{ data.users.state }}` |
| `{{ data._columns[index] }}` | N-th column value in current row (0-indexed) | `{{ data._columns[0] }}` |
| `{{ report_table }}` | Embeds the Report Table visualization starting at that cell | `{{ report_table }}` |

---

## Deployment

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?shellonly=true&cloudshell_git_repo=https://github.com/lkrdev/google-sheets-excel-template)


Deploy directly to Google Cloud Run using the deployment script:

```bash
./deploy.sh
```

To view all CLI flags, options, and automated registration parameters, run:

```bash
./deploy.sh --help
```

The script provisions required Google Cloud APIs (`run`, `secretmanager`, `drive`), configures Secret Manager credentials (`cipher-master`, `action-hub-secret`, `google-drive-client-secret`), deploys the service to Cloud Run, and can optionally register the Action Hub in your Looker instance.

---

## Local Development

```bash
# Install dependencies and copy environment file
yarn install && cp .env.example .env

# Run dev server with hot reload
yarn dev

# Run dev server with Cloudflare tunnel
make dev-tunnel

# Run unit tests and linter
yarn test
```
