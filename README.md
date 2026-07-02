# Google Sheets Excel Template Looker Action Hub

A standalone Looker Action Hub hosting the Google Sheets Excel Template action (`google-sheet-xlsx-template`).

This action merges query data from Looker into pre-formatted Excel (`.xlsx`) templates stored in Google Drive. It allows you to build custom branded reports with existing Excel layouts, formulas, and formatting.

---

## What It Does

When Looker sends a query payload via webhook, the service:
1. Authenticates user credentials against Google Drive APIs (requiring `drive` and `userinfo.email` scopes) and checks optional domain allowlists (`domain_allowlist`).
2. Downloads the selected `.xlsx` template file from Google Drive.
3. Fills in the template or renders a Report Table visualization:
   - Template Mode: Parses handlebars placeholders (such as `{{ data.field_name }}` or `{{ _built_in.run_at }}`) using ExcelJS, expanding repeating data rows while preserving existing styles, formulas, and headers.
   - Report Table Visualization Mode: Renders Looker [Report Table visualizations](https://www.lkr.dev/docs/visualizations/viz-report-table-marketplace2/) using JSDOM with supported themes (`Looker`, `Traditional`), computing multi-level row subtotals and applying number formatting (currency, percentages, thousand separators).
4. Saves user OAuth credentials to `/tmp/last_state_json.json` on initial UI runs so background API calls and scheduled plans run without re-authentication errors.
5. Uploads the finished `.xlsx` file to the targeted Google Drive folder.

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
| `{{ data[index].view_name.field_name }}` | Zero-indexed row value | `{{ data[0].products.brand }}` |
| `{{ data.view_name.field_name }}` | Field value for current row in repeating data sections | `{{ data.users.state }}` |
| `{{ data._columns[index] }}` | N-th column value in current row | `{{ data._columns[0] }}` |

The repeating row section is detected by matching cell patterns like `{{ data.users.state }}`. The row expands downwards for each data record, and Excel formulas referencing those ranges update automatically.

---

## Prerequisites

Local development:
- Node.js (>= 20.16.0) and Yarn (>= 1.19.1)
- Astral uv for Python scripts

Google Cloud deployment:
- Google Cloud SDK (`gcloud` CLI)

---

## Looker Action Registration

1. Go to **Admin** > **Platform** > **Actions** in Looker.
2. Click **Add Action Hub**.
3. Enter your server URL (for example, `https://google-sheets-excel-template-xxx-uc.a.run.app`).
4. Set the Authorization Token (`ACTION_HUB_SECRET`).
5. Enable the **Google Sheets Excel Template** action.

---

## Google OAuth Setup

Configure OAuth 2.0 credentials in GCP to handle Google Drive authentication:

1. Open the GCP Console.
2. Go to **APIs & Services** > **OAuth consent screen** and select **Internal** or **External**.
3. Add the required scopes:
   - `https://www.googleapis.com/auth/drive`
   - `https://www.googleapis.com/auth/userinfo.email`
4. Go to **Credentials** > **Create Credentials** > **OAuth client ID**.
5. Select **Web application**.
6. Add the authorized redirect URI:
   - Local: `http://localhost:8080/actions/google-sheet-xlsx-template/oauth_redirect`
   - Cloud Run: `https://<your-cloud-run-domain>/actions/google-sheet-xlsx-template/oauth_redirect`
7. Save the Client ID and Client Secret to `GOOGLE_DRIVE_CLIENT_ID` and `GOOGLE_DRIVE_CLIENT_SECRET`.

---

## Deployment

### Deploy with Cloud Shell

Run the deployment script interactively or pass flags:

```bash
./deploy.sh --project-id="my-project-id" --drive-client-id="my-client-id" --drive-client-secret="my-client-secret"
```

The script enables required APIs (Cloud Run, Secret Manager, Drive API), creates secrets for `cipher-master` and `action-hub-secret`, and deploys the service.

---

## CLI Options

| Option | Shorthand | Type | Description |
| :--- | :--- | :--- | :--- |
| `--project-id` | `-p` | `TEXT` | GCP Project ID |
| `--drive-client-id` | | `TEXT` | Google Drive Client ID |
| `--drive-client-secret` | | `TEXT` | Google Drive Client Secret |
| `--region` | `-r` | `TEXT` | Cloud Run region (`us-central1`) |
| `--service-account-email` | | `TEXT` | Custom service account email |
| `--register-looker` | | `FLAG` | Auto-register action in Looker |
| `--looker-url` | | `TEXT` | Looker instance URL |
| `--looker-client-id` | | `TEXT` | Looker API Client ID |
| `--looker-client-secret` | | `TEXT` | Looker API Client Secret |

---

## Local Development

```bash
# Install dependencies
yarn install

# Environment setup
cp .env.example .env

# Run dev server with hot reload
yarn dev

# Run dev server with Cloudflare tunnel
make dev-tunnel
```

Run tests and linter:
```bash
yarn test
```
