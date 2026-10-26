# Members and scheme enrollments

Members are independent of employers. Each enrollment connects one member and
one pension scheme, with an employer required only for employer-sponsored
schemes. A separate Scheme Employers list records participating employers.
Members retain their identity across employers and voluntary memberships.

Scheme Category (Occupational, Umbrella, Individual) controls participation.
Benefit Design (Defined Contribution, Defined Benefit) remains independent.
Occupational and Umbrella schemes require a participating employer. Individual
schemes require a blank employer and zero employer contribution rate.

Use **Members** and **Scheme Enrollments** in Tell Me or the PensionFlow Role
Center. Member, employer, and scheme cards and lists include filtered
**Enrollments** actions. Enrollment cards link back to all three records.

Configure **Member Nos.** and **Enrollment Nos.** in PensionFlow Setup first.
Blank numbers are assigned when a completed card is saved. Manual numbers require
Manual Nos. on the relevant series. Member name is required; registration date
defaults to WorkDate. Date of birth is optional and cannot be after WorkDate or
after registration date.

## Enrollment rules

- Member, scheme, and Effective From are required. Employer is required for
  Occupational/Umbrella schemes and must be blank for Individual schemes.
- Scheme Employers must contain the employer/scheme pair. Active enrollments
  require active participation. Enrollment dates must fit inside its effective
  period; blank participation dates are unrestricted.
- Effective To is inclusive; blank means open-ended. It cannot precede Effective From.
- Member and employer rates each range from 0 to 100 percent. Selecting a
  different scheme copies its current rates, which can then be overridden.
  Changing scheme defaults later does not rewrite enrollment rates. Individual
  schemes and enrollments must have zero employer rate.
- Status starts as Draft. Active requires active member, scheme, and any employer
  records and cannot start before the scheme effective date. Closed requires an
  end date. Cancelled records do not reserve an effective period.
- Draft, Active, and Closed periods cannot overlap for the same member, employer,
  and scheme. A second period can start the day after the first ends. Different
  members, employers, or schemes can have concurrent periods.
- Existing linked records are checked again on every insert/modify with triggers
  enabled. Changing a parent status does not automatically change its enrollments.
- Members with enrollments cannot be deleted. Employers and schemes with
  enrollments or participation records cannot be deleted or renamed. Participation
  keys cannot be renamed, and participations with enrollments cannot be deleted.
  Member and enrollment numbers cannot
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

## Upgrade and new registration flows

The new Category field defaults to Unspecified for existing schemes. Classify
each scheme explicitly; category is never inferred from benefit design or
existing employers. An unclassified scheme cannot receive new enrollments.
Before using existing employer enrollments, create the corresponding Scheme
Employer participation records with periods that cover their enrollment dates.
Category changes cannot invalidate existing enrollment relationships.

Under Members, use Register Member for independent registration, Import Employer
Members to select a participating employer/scheme, or Import Individual Members
to select an Individual scheme without an employer. See member-import.md.

The contribution module remains future work. These rules establish eligibility
and enrollment rates; they do not create payroll batches, voluntary payments,
or contribution postings.
