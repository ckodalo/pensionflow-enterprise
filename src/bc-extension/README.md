# PensionFlow

A Business Central 27 extension for pension member registration, employer and
scheme enrollment, monthly payroll contributions, and accounting.

## What it does

- Imports members and monthly contributions from Excel.
- Calculates contributions or checks supplied payroll deductions against enrollment rates.
- Validates, approves, and posts batches to the employer receivable, general ledger,
  and individual member contribution history.
- Supports selectable currencies, including KES, and matching posted customer payments.
- Provides a Finance section in the PensionFlow Role Center.

## Getting started

1. Publish the extension to a BC sandbox and assign **PFE ADMIN** or **PFE USER**
   alongside the required standard BC permissions.
2. In **PensionFlow Setup**, create number series and contribution accounts.
3. Create employers and schemes, configure employer participation, and enroll members.
4. On each employer card, choose **Set Up Contribution Accounting**.
5. Create a monthly batch, select its currency and posting date, then download the
   contribution template, fill it, and upload.
6. Review, validate, approve, and post. Record receipts through BC and match them to the batch.

Posting debits **PFE-1300 Contributions Receivable** and credits **PFE-2300 Member
Balances Control** by default. Employer and scheme overrides are supported.
Member balances include posted contributions still owed by employers; they are
not investment-valued or cash-received balances. The G/L records local-currency
equivalents using BC exchange rates.

## Build and tests

Requires the Microsoft AL compiler and BC 27 symbols in `.alpackages`.

```powershell
./tests/Build-Tests.ps1
```

This compiles the extension and test package. Run runtime tests separately in a
sandbox with **TestIsolation = Function**.

See [member imports](docs/member-import.md), [enrollments](docs/member-enrollments.md),
and [monthly contributions](docs/monthly-contributions.md) for details.

Next planned integration: payroll API submissions using the same validation and
approval workflow as Excel. The API is not implemented yet.
