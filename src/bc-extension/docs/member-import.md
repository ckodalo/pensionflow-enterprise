# Bulk member registration

After publishing the extension, open **Members** from the PensionFlow Role Center.

1. Choose **Download Member Template**.
2. Keep the worksheet named **Members** and preserve all ten column headers.
3. Add one member per row, starting at row 2.
4. Choose an import action below and select the completed .xlsx or UTF-8 .csv file.
5. If validation fails, use the downloaded error report to correct the original
   workbook, then upload the original again. The error workbook has extra report
   columns and is not itself an import template.

## Registration options

- **Register Member** opens the member card without requiring an employer or
  scheme. An optional Import Reference can identify the member in later files.
- **Import Members Only** retains the original registration-only behavior.
  Existing references/numbers are rejected; it creates no enrollments.
- **Import Employer Members** asks for employer, scheme, and enrollment dates.
  Use an active Occupational or Umbrella scheme with an active Scheme Employer
  participation covering the enrollment period.
- **Import Individual Members** asks for an Individual scheme and dates.
  Employer stays blank and employer contribution rate is zero.

Both enrollment imports create active enrollments, require active members, and
copy scheme contribution rates. Each file uses one selected enrollment context;
rates can be adjusted afterward on the enrollment card. Existing members are
reused instead of duplicated, and an identical active enrollment is retained on
reupload. A different overlapping period is rejected.

| Column | Requirements |
| --- | --- |
| Import Reference | Required, stable unique identifier from the source, maximum 50 characters. Codes are normalized to uppercase. |
| Member No. | Optional, maximum 20 characters. Can identify an existing member in enrollment imports. For a new member, blank uses Member Nos.; explicit new numbers require Manual Nos. |
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

For CSV, use the same ten headers in the same order and comma separators.
UTF-8 files support quoted commas and doubled quotes within a single-line field.
Embedded line breaks in quoted fields are rejected. Extra columns and values
over 250 characters are rejected before field-length checks. The existing
sample workbook remains compatible with every import option.

## Duplicate and transaction behavior

Import Reference identifies a source member across uploads. Keep it unchanged
when correcting/retrying the source workbook. Duplicate references or explicit
member numbers within a file are rejected. Registration-only imports also reject
existing members. Enrollment imports resolve a member by reference or existing
member number, reject conflicting matches, and require matching names and any
birth dates supplied on both records. Existing member details and enrollment
rates are never overwritten. Member name or email alone is not considered a
reliable identity; different references can represent different people with the
same name/email. Import Reference is visible on the member card. A previously
blank reference may be assigned once when an existing member is first imported;
an established reference cannot be changed. If an existing member already has a
reference, the file must use that reference even when the employer has changed.

All rows are validated before any members or number series are updated. A
validation error means zero members or enrollments are inserted. Successful rows are inserted
with table triggers enabled in a single transaction; unexpected database errors,
concurrent duplicate references, or number-series exhaustion roll back the
whole import rather than leaving a partial batch.

The error report includes only rejected rows, their original values (limited to
the Excel Buffer's 250-character cell limit), original row numbers, and first
errors. Correct all errors in the original workbook. Workbooks are downloaded
directly to the client; the importer does not send them to document sharing.

PFE USER includes the import codeunit and temporary staging table. Normal BC
permissions for member numbering and standard Excel facilities are still needed.
Enrollment imports also require enrollment number series permissions.

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

Test codeunit 50202 adds nine scenario tests for optional employers, employer
participation and dates, voluntary contribution rates, reuse across employers,
repeat enrollment imports, identity mismatch rollback, unclassified schemes,
and quoted CSV input. Run all three test codeunits with function isolation.
