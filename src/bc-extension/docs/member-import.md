# Bulk member registration

After publishing the extension, open **Members** from the PensionFlow Role Center.

1. Choose **Download Member Template**.
2. Keep the worksheet named **Members** and preserve all ten column headers.
3. Add one member per row, starting at row 2.
4. Choose **Import Members** and select the completed .xlsx workbook.
5. If validation fails, use the downloaded error report to correct the original
   workbook, then upload the original again. The error workbook has extra report
   columns and is not itself an import template.

| Column | Requirements |
| --- | --- |
| Import Reference | Required, stable unique identifier from the source, maximum 50 characters. Codes are normalized to uppercase. |
| Member No. | Optional, maximum 20 characters. Blank uses Member Nos. in PFE Setup. Explicit numbers require Manual Nos. on that series. |
| Member Name | Required, maximum 100 characters. |
| Date of Birth | Optional text in YYYY-MM-DD format. Cannot be after WorkDate or registration date. |
| Email Address | Optional, maximum 100 characters. |
| Phone No. | Optional text, maximum 30 characters. |
| Address | Optional, maximum 100 characters. |
| City | Optional, maximum 50 characters. |
| Date Registered | Optional text in YYYY-MM-DD format. Blank defaults to WorkDate. |
| Status | Active or Inactive, case insensitive. Blank defaults to Active. |

Format date columns as **Text** before entering or pasting ISO dates. Keep phone
numbers, references, and explicit member numbers as text to preserve leading zeros.
Do not use formulas. Header comments in the template also describe these rules.

The import accepts up to 10000 data rows and ignores wholly blank rows. The
Member Nos. series must be configured with available numbers for automatic
numbering. Missing/wrong sheets, headers, or extra columns cause a workbook-level
error; invalid data rows are listed with their original Excel row number and
first validation error.

## Duplicate and transaction behavior

Import Reference identifies a source member across uploads. Keep it unchanged
when correcting/retrying the source workbook. Duplicate references or explicit
member numbers in the file or existing member table are rejected. Existing
records are never overwritten. Member name or email alone is not considered a
reliable identity; different references can represent different people with the
same name/email. Import Reference is visible on the member card and cannot be
changed after insertion.

All rows are validated before any members or number series are updated. A
validation error means zero members are inserted. Successful rows are inserted
with table triggers enabled in a single transaction; unexpected database errors,
concurrent duplicate references, or number-series exhaustion roll back the
whole import rather than leaving a partial batch.

The error report includes only rejected rows, their original values (limited to
the Excel Buffer's 250-character cell limit), original row numbers, and first
errors. Correct all errors in the original workbook. Workbooks are downloaded
directly to the client; the importer does not send them to document sharing.

PFE USER includes the import codeunit and temporary staging table. Normal BC
permissions for member numbering and standard Excel facilities are still needed.
Imports register members only; they do not create scheme enrollments.

## Verification

Run `./tests/Build-Tests.ps1` to compile the extension and separate test package.
Publish to a dedicated sandbox test company and run test codeunit 50201 with
**TestIsolation = Function**. Its seven tests cover valid imports, all-or-nothing
validation, duplicate references, reuploads, manual-number restrictions, bad
status/lengths, formulas, and headers.

Also verify the browser upload/download flow with a downloaded template, a valid
two-member file, and a file containing one invalid row. Confirm the error file
identifies the original row and no members are saved on failure. Runtime tests
and browser flow verification require the published extension.
