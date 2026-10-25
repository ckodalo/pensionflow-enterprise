# Members and scheme enrollments

Members are independent of employers. Each enrollment connects one member,
one employer, and one pension scheme. Employer participation in schemes is
represented by those enrollments; there is no separate participation agreement
or restriction requiring a member to belong to just one employer.

Use **Members** and **Scheme Enrollments** in Tell Me or the PensionFlow Role
Center. Member, employer, and scheme cards and lists include filtered
**Enrollments** actions. Enrollment cards link back to all three records.

Configure **Member Nos.** and **Enrollment Nos.** in PensionFlow Setup first.
Blank numbers are assigned when a completed card is saved. Manual numbers require
Manual Nos. on the relevant series. Member name is required; registration date
defaults to WorkDate. Date of birth is optional and cannot be after WorkDate or
after registration date.

## Enrollment rules

- Member, employer, scheme, and Effective From are required.
- Effective To is inclusive; blank means open-ended. It cannot precede Effective From.
- Employee and employer rates each range from 0 to 100 percent. Selecting a
  different scheme copies its current rates, which can then be overridden.
  Changing scheme defaults later does not rewrite enrollment rates.
- Status starts as Draft. Active requires active member, employer, and scheme
  records and cannot start before the scheme effective date. Closed requires an
  end date. Cancelled records do not reserve an effective period.
- Draft, Active, and Closed periods cannot overlap for the same member, employer,
  and scheme. A second period can start the day after the first ends. Different
  members, employers, or schemes can have concurrent periods.
- Existing linked records are checked again on every insert/modify with triggers
  enabled. Changing a parent status does not automatically change its enrollments.
- Members with enrollments cannot be deleted. Employers and schemes with
  enrollments cannot be deleted or renamed. Member and enrollment numbers cannot
  be renamed. These checks also include cancelled and closed enrollments.

Application code must use Validate for scheme selection to copy rate defaults,
and Insert(true)/Modify(true)/Delete(true) to execute table business rules.
No API, contribution calculation, posting, or automatic status transition is
included in this module.

## Validation

Build the extension and separate test package:

```powershell
./tests/Build-Tests.ps1
```

The script stages the test source outside the extension project so tests are
not shipped in the production app. It prints temporary package paths. Override
CompilerPath if using a different installed AL compiler.

Publish both packages to a **dedicated sandbox test company** with the BC test
toolkit installed. Run codeunit 50200 through a test runner with
**TestIsolation = Function**. Tests modify company setup and insert fixtures;
function isolation is required to roll these changes back between tests.
The package compiles without a dependency on the test assertion library.

The eight tests cover many-to-many relationships, default and overridden rates,
inclusive overlap boundaries, invalid dates/rates, missing parents, activation
requirements, deletion protection, and automatic/manual numbering.

Also verify in the UI that New opens the cards, blank numbers are assigned on
save, lookups open the correct lists, related enrollment actions are filtered,
and a user with PFE USER plus their normal BC permissions can complete the flow.
Verify concurrent attempts to create overlapping enrollments for the same member
in two sessions: only one should succeed.

Compilation does not execute these runtime tests. Publish with data-preserving
schema synchronization; no demo records are added by this module.
