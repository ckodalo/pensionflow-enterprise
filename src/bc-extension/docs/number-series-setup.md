# PensionFlow numbering

Publish and synchronize the extension using the normal AL deployment workflow.
For production, use schema synchronization that preserves existing data rather than
the local launch configuration's ForceSync setting.

In each company, open **PensionFlow Setup** from Tell Me or the Role Center.
Opening the page creates the company's single setup record. Assign existing
Business Central number series, or choose **Create Default Number Series**:

| Setup field | Series | First number | Last number |
| --- | --- | --- | --- |
| Employer Nos. | PFE-EMP | EMP000001 | EMP999999 |
| Member Nos. | PFE-MEM | MEM000001 | MEM999999 |
| Enrollment Nos. | PFE-ENR | ENR000001 | ENR999999 |
| Contribution Batch Nos. | PFE-CB | CB000001 | CB999999 |

Default series use automatic numbering and disallow manual numbers. The action
only fills empty setup fields, never resets existing sequences, and rolls back
if a reserved series code already exists. Resolve a code conflict by reviewing
and assigning the existing series or selecting a different series in setup.

Employers with a blank code receive their next number on insertion through AL
with table triggers enabled. Explicit codes require **Manual Nos.** on the
configured employer series. Existing employer codes remain unchanged. Code that
creates employers must call `Insert(true)` and should validate explicit codes.
Members and scheme enrollments use their configured series in the same way.
The contribution batch setting is reserved for the future contribution module.

Assign **PFE ADMIN** to setup administrators and **PFE USER** to operators, alongside
their normal Business Central permissions for standard number series facilities.
No elevated table permissions are embedded in the setup management codeunit.

## Runtime acceptance checks

Run in a sandbox company after publishing:

1. Open setup twice: confirm a single blank-key record is retained.
2. Create defaults: verify the four series, ranges, and setup assignments above.
3. Repeat the action: verify assignments and last-used numbers remain unchanged.
4. Create two employers with blank codes: expect EMP000001 and EMP000002 in a
   fresh company. Reopen them and verify their codes and stored No. Series.
5. Try an explicit employer code: expect rejection while Manual Nos. is disabled.
   Enable Manual Nos. and verify an explicit unique code is accepted.
6. Clear Employer Nos. and try creating an employer: expect a missing-setting error
   with no employer inserted. Restore the assignment afterward.
7. In a separate fresh company, pre-create PFE-MEM and run the defaults action:
   expect a conflict and no partial setup or newly inserted series.
8. Verify PFE USER can create employers after setup but cannot edit setup; verify
   PFE ADMIN can configure it using the standard BC permissions required above.

The SQL demo seed script targets the updated schema and intentionally bypasses
AL validation. It is only for the local demo database, not production provisioning.
