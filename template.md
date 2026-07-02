# Excel Template Action Specification & Results

The Google Sheets Excel Template action handles template parsing, layout rendering, and streaming query results as .xlxs files and stores them on Google Drive.

## 1. Action Specification
- Action name: `google-sheet-xlsx-template` (registered in [src/actions/index.ts](src/actions/index.ts))
- Core implementation: [google_sheet_xlsx_template.ts](src/actions/google_sheet_xlsx_template/google_sheet_xlsx_template.ts)
- Supported format: `json_detail_lite_stream` (streams metadata, field types, and row tuples efficiently)
- Download mode: `url` (streams data directly for large query result sets)

## 2. Template Parsing Test Results
Parsed [template-example.xlsx](simulate/template-example.xlsx) using `exceljs`. Mapped cells and placeholders:

### Template Placeholders
| Cell | Raw Template Value | Target Mapping Source |
| :--- | :--- | :--- |
| **B4** | `{{ _built_in.run_at }}` | Query execution timestamp |
| **B5** | `{{ _built_in.title }}` | `scheduledPlan.title` |
| **B6** | `{{ _built_in.description }}` | `scheduledPlan.description` |
| **B7** | `{{ _filters.users.state }}` | `appliedFilters["users.state"].value` |
| **B8** | `{{ data[0].products.brand }}` | `data[0]["products.brand"].value` |
| **C10** | `{{ fields.users.state.label }}` | `fields.dimensions` or `fields.measures` label |
| **A11** | `{{ data._columns[0] }}` | First column value in the current row |
| **B11** | `{{ data._columns[2] }}` | Third column value in the current row |
| **C11** | `{{ data.users.state }}` | `row["users.state"].value` in the current row |
| **D11** | `{{ data.order_items.count }}` | `row["order_items.count"].value` in the current row |

Row 11 serves as the repeating data section.

### Layout & Styles
- PNG logo anchored at cell **`A1`**
- Column widths: A, B, D, E, F set to `12.63`; C set to `17.00` to prevent text clipping
- Header fills: Yellow (`#FFFF00`) for metadata labels A4:A8, Blue (`#3C78D8`) for table headers A10:D10, Gray (`#FFD9D9D9`) for repeating row template A11:D11

---

## 3. Webhook Payload Structure
Payload structure stored during streaming runs:

```json
{
  "webhookId": "test_webhook_123",
  "lookerVersion": "23.0.0",
  "type": "query",
  "params": {},
  "formParams": {},
  "scheduledPlan": {
    "title": "Test Scheduled Plan",
    "scheduledPlanId": 456,
    "downloadUrl": "..."
  },
  "fields": {
    "dimensions": [
      { "name": "order_items.created_week", "label": "Order Items Created Week" }
    ],
    "measures": [
      { "name": "order_items.total_sale_price", "label": "Order Items Total Sale Price" }
    ]
  },
  "appliedFilters": {
    "products.brand": { "value": "-EMPTY", "field": {} },
    "order_items.created_week": { "value": "NOT NULL", "field": {} }
  },
  "data": [
    {
      "order_items.created_week": { "value": "2022-12-26" },
      "order_items.total_sale_price": { "value": 2499.45 }
    }
  ]
}
```

## 4. Test Verification
Unit tests are located in [test_google_sheet_xlsx_template.ts](src/actions/google_sheet_xlsx_template/test_google_sheet_xlsx_template.ts):
1. Verifies payload stream harvesting and metadata extraction.
2. Streams sample dataset `example-json_detail_lite_stream.json` and verifies parsing accuracy across all 183 rows.
