# Monthly contributions

Use **PensionFlow > Contribution Batches** after member enrollment. A batch covers
one employer, one scheme, one currency and one calendar month. Choose the batch
Currency Code from Business Central Currencies, including KES. A blank code uses
company local currency (LCY), displayed separately on the card. GBP is not hardcoded;
it appears when the company LCY is GBP. KES is added to Currencies on first opening
the card if missing and not itself the LCY; existing currency settings are preserved.
Amounts use the selected currency's Amount Rounding Precision, or General Ledger
Setup for LCY. Selecting a currency labels the amounts; it does not convert them or
change company LCY. All six spreadsheet columns use the one selected batch currency.
Payroll posting uses the standard BC general journal engine to debit employer
contributions receivable and credit a member balance liability control account.
The employer customer ledger, general ledger and member contribution entries are
posted in the same transaction. Uploading the workbook alone only stages the return.

## Accounting setup

The PensionFlow Role Center has a **Finance** section with contribution batches,
member contribution history and payment matches; General Ledger (chart of accounts,
entries, registers and journals); Employer Receivables (customers, ledger entries
and Cash Receipt Journal); Banking (accounts, ledger entries and reconciliations);
and Financial Setup (contribution accounting, currencies/exchange rates, customer
posting groups and G/L setup). Journal, banking and setup actions respect the
user's existing BC data permissions. Navigation links do not grant additional
financial editing, bank posting or administration rights.

Finance activity cues drill down into batches to review (Open/Validated), approved
batches to post, and posted batches. They count batches rather than summing amounts
in different currencies.

After publishing version 1.1.0.0, open **PensionFlow Setup > Create Contribution
Accounts** as PFE ADMIN. This creates the following accounts if setup is empty:

| Account | Category | Purpose |
| --- | --- | --- |
| PFE-1300 | Assets / Balance Sheet | Pension contributions receivable; debited through the employer customer posting group. Direct Posting is disabled. |
| PFE-2300 | Liabilities / Balance Sheet | Pension member balances control; credited when the payroll is posted. |

It also creates source code PFE-CONT and a PFE-CONTR / PAYROLL general journal
template/batch. Existing configured account choices are preserved. A conflicting
default account number is rejected, not renamed or repurposed.

On **Wizz Solutions > Set Up Contribution Accounting**, the selected employer
receivable account defaults from Setup. If no BC Customer No. is linked, the action
creates a dedicated pension customer using the standard Customer Nos. series and a
customer posting group pointing to that receivable account. If a customer already
exists, its receivables account must match; its existing posting group is never
silently changed. Select a dedicated pension customer if the existing customer is
used for other business. An employer can override the default asset account with
another unblocked balance-sheet Assets posting account.

Separate G/L accounts for every employer are optional: the shared asset control
account is broken down by employer in the customer ledger. Fanaka is a scheme;
set its **Member Balance Account** to PFE-2300 or another balance-sheet Liabilities
posting account. Blank uses the default in Setup. This implements the requested
simple member-liability model, not a full actuarial or investment accounting model.

Set the batch Posting Date before approval. Foreign-currency payroll requires
standard BC exchange rates for that date; the extension does not invent exchange
rates. Approval snapshots the customer and control accounts. Changing those
mappings before posting requires reopening and approval again. The standard BC
posting engine enforces posting periods, dimensions, currencies and posting rules.
The batch exposes its G/L register, transaction and customer receivable entry.

For a KES 4,500 payroll, the entry is Dr employer receivable 4,500 / Cr member
balances control 4,500 in transaction currency, converted to LCY by BC. Individual
member credits total the control credit. Member LCY amounts use cumulative rounded
allocation so their sum matches the G/L control exactly.

## Wizz Solutions / Fanaka workflow

1. Create a contribution batch. Leave Batch No. blank for automatic numbering.
   Contribution Batch Nos. must be assigned in PensionFlow Setup and have available
   automatic numbers. Select Wizz Solutions, Fanaka and a date in the payroll month.
   The date is normalized to the first day of that month. Select KES for a Kenyan
   shilling payroll, or leave Currency Code blank for the company currency.
2. Choose **Download Contribution Template**. The `Contributions` worksheet is
   prefilled with eligible member numbers and import references for this context.
3. Enter each member's pensionable salary for the month. Either leave both payroll
   contribution columns blank to calculate from enrollment rates, or fill both to
   reconcile payroll's amounts. Enter zero explicitly when payroll deducted zero.
   Voluntary Contribution is optional and is additional to the employee amount.
4. Choose **Upload Contributions**. An open batch's lines can be replaced after a
   confirmation. Structural/format errors reject the entire upload and preserve
   existing lines. Business validation errors are retained on imported lines for
   correction. Nothing is posted during upload.
5. Review Validation Error, expected amounts, actual payroll amounts, individual
   variances and totals. Correct errors in the open lines or original workbook.
   Choose **Validate Contributions** after edits.
6. A valid batch becomes **Validated**. For payroll differences, choose **Reopen
   Batch**, enter a specific Variance Reason on each affected line, then validate
   again. Both employee and employer differences require review even if they
   cancel in the net total. Expected amounts are rounded separately using the
   batch currency amount rounding precision. Sub-precision input amounts are rejected.
7. Choose **Approve Batch**, then **Post Contributions**. Approval records the
   user and timestamp; it is a review action available to PFE USER, not a separate
   multi-person approval workflow. Posting creates G/L and customer ledger entries
   plus immutable contribution entries and records who posted and when. Rates,
   account mappings and eligibility are checked again:
   changes after approval require reopening and approval again.
8. Record receipt of money through the normal Business Central customer payment
   workflow. Link the employer's **Business Central Customer No.** first, then use
   **Match Customer Payment** on the posted batch to allocate an existing posted
   payment. The customer link and accounting setup are required before approval.
   Apply the customer payment to the batch receivable in standard BC as well.

## Member contribution history and balances

Open a **Member Card > Contribution History** to see payroll month, employer,
scheme, currency, posting date, employee/employer/voluntary contributions and G/L
transaction. The Contribution Balances group totals these components for one
selected currency and an optional scheme. Blank currency selects only LCY, not all
currencies. These balances are credits declared by posted payrolls, including
unpaid employer receivables. They are not bank-funded, investment-valued, vested or
withdrawable balances. Receiving payment settles the receivable and must not
credit the member contribution again.

This is an internal Business Central history screen; member self-service portal
authentication is not provided. Legacy pension-only entries with no G/L transaction
remain visible in history but are excluded from the new G/L-backed balance totals.
Do not repost legacy batches or manually journal an opening balance without a
separate reconciled migration: automatic back-posting of older batches is not performed.

## Excel contract

Keep the worksheet named `Contributions`. Row 1 must have exactly these six
headers, in this order; data begins in row 2. Do not add totals or report columns.

| Header | Rule |
| --- | --- |
| Member No. | Existing member number; optional when Import Reference is supplied. |
| Import Reference | Existing unique member reference; optional when Member No. is supplied. If both are supplied they must identify the same member. |
| Pensionable Salary | Required numeric amount, zero or greater. |
| Employee Contribution | Optional payroll amount. Fill this and Employer Contribution together, or leave both blank. |
| Employer Contribution | Optional payroll amount. Explicit zero is different from blank. |
| Voluntary Contribution | Optional additional amount; blank means zero. |

Identifiers are text. Amounts should be Excel numbers; text amounts must use a
decimal point without grouping separators or currency symbols. Formulas, negative
amounts, excessive lengths, extra columns and more than 10000 data rows are rejected.
Entirely blank rows are ignored. Line No. on uploaded lines is the source Excel row
number so validation errors can be located in the original workbook. Only `.xlsx`
is accepted by this contribution uploader.

## Calculation and period rules

- Contributions are salary times the respective enrollment rate, divided by 100,
  rounded separately using the batch currency amount rounding precision.
- Salary-only lines use those calculated amounts as the contributions due. Payroll
  lines retain the supplied amounts; differences are reviewed, never silently
  overwritten. Total due is employee plus employer plus voluntary contributions.
- Eligible enrollments cover the **last day of the month** and are Active or
  Closed. The member, employer, scheme and employer participation must be active
  when validating/posting, with participation covering month-end. This is an
  employer workflow; Individual schemes are not supported by these batches.
- There is no automatic salary proration. Payroll supplies the pensionable salary
  applicable to the month. An enrollment ending before month-end is rejected;
  final/leaver contributions need an explicit future policy rather than being
  silently treated as a full-month enrollment.
- Rates are current enrollment rates, copied into the approved/posted snapshot.
  The extension has no effective-dated historical rate schedule. For a backdated
  month, confirm that the enrollment rate is appropriate before approving.
- A member can appear only once in a batch. A scheme/member/month can be posted
  only once across batches, including across employers. Split employer payrolls,
  arrears, supplementary returns and reversals need separate future workflows;
  they cannot bypass this duplicate protection.
- Open batches can be edited or deleted. Validated/approved batches must be
  reopened to edit; reopening clears approval and calculated results. Posted
  batches and contribution entries cannot be edited, deleted or reposted.
  Posting is one transaction with no internal commits.

## Payment reconciliation

Payment matching is a separate pension allocation register. It does **not** create
invoices, G/L postings, bank transactions, or apply/unapply customer ledger entries.
Those receipt/application steps remain in the standard Business Central accounting
workflow. Payroll posting now creates the employer receivable and member control
credit; payment matching itself adds no further accounting entry. A standard receipt
debits the actual bank account and credits the employer customer receivable. Payroll
is not proof of receiving a cheque or clearing it through the bank.

Select an existing customer ledger Payment entry belonging to the employer's
linked customer, in the batch currency and not reversed. Enter a positive amount to match.
Partial payments and one payment covering several batches are supported. Allocations
cannot exceed either the batch's outstanding amount or the payment's original transaction-currency
amount across all contribution batches. Standard BC invoice applications are not
subtracted: these allocations track pension attribution separately. Different
currencies cannot be matched and no exchange-rate conversion is performed. Posted
entries and payment matches retain the batch Currency Code; blank retains legacy LCY behavior.

One payment entry has one match per batch. To change an allocation, open **Payment
Matches**, remove the match and create it again. Removing a match leaves the posted
customer payment unchanged. Recorded matches remain visible if the customer payment
is subsequently reversed, but **Valid Matched Payments** and **Outstanding Amount**
exclude reversed payments. Remove those obsolete matches after review. The matches
carry the matching user and timestamp; removed matches require the standard BC
change log if a deletion audit trail is required.

## Verification

Run `./tests/Build-Tests.ps1` to compile the extension and test package. Test codeunit
50204 covers salary calculation/rounding, explicit zero payroll amounts, reference
resolution, atomic malformed imports, formulas, review reasons for offsetting
variances, changed approval snapshots, duplicate months and members, immutable
posting, automatic card numbering, invalid-member blocking, partial payment caps,
cross-batch payment allocation and reversed/wrong-customer/foreign-currency payments.
It additionally tests standard G/L debit/credit/customer/member reconciliation,
LCY rounding allocation, account mapping changes after approval, repeatable setup
and rollback of G/L/customer postings if a member entry fails (manual subscriber
codeunit 50205). PFE USER includes the standard Receivables Journals - Post permission
set; account/customer setup actions require PFE ADMIN and normal BC customer setup.
Run with **TestIsolation = Function** in a dedicated sandbox company. Payment unit
fixtures construct customer ledger records; verify actual standard payment posting
and matching end to end in the sandbox as well.

Browser acceptance: create Wizz/Fanaka batch, download a prefilled template, upload
salary-only and payroll examples, correct a rejected row, explain a variance, approve
and post. Confirm the batch becomes read-only and duplicate reupload cannot be
posted. Match a partial then final posted customer payment, remove a match, and
reverse a matched payment in standard BC to confirm outstanding totals recover.
Compilation alone does not verify these browser or runtime behaviors.
