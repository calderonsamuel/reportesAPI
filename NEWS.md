# reportesAPI 0.3.3

- Adds methods for getting reports data

# reportesAPI 0.3.2

- Adds methods for inserting and deleting reports

# reportesAPI 0.3.1

- Fixed a bug that prevented successful retrieval of groups data
- Fixed a bug in the database that prevented reporting more than once

# reportesAPI 0.3.0

##  Big changes in the underlying database. 

- Now all the tables have primary and foreign keys. the 'users' and the 'organisations' tables are the root of the database. (fix #9)
- Deletion of tasks cascades to progresses.
- Deletion of groups cascades to tasks, group_users, and group_units.
- Deletion of organisation cascades to groups and org_users
- Deletion of users is restricted.
- No longer use foreign keys to retrieve or update data in child tables.
- Adding or updating a task no longer creates an entry in progress.

## Other changes

- Each class now has various test for add, update and delete.
- Changes in the database now only produce messages in interactive sessions.

# reportesAPI 0.2.1

- Fixed a bug that prevented to add and edit group units

# reportesAPI 0.2.0

- Added methods to `Group` to add, edit and delete measurement units. This also allows to divide between tasks and reports.

# reportesAPI 0.1.8

- The user that creates a group now has 'admin' role instead of 'owner'. This was making necessary to edit manually the user role after.
- Users now have a favorite group. This is the default group for getting the tasks.

# reportesAPI 0.1.7

- Now you can specify the user color when adding to a group

# reportesAPI 0.1.6

- Fixed a bug that prevented to get org users names

# reportesAPI 0.1.5

- Fixed a bug that prevented messaging when adding user to organisation or group

# reportesAPI 0.1.4

- Fixed a bug that prevented group user edition

# reportesAPI 0.1.3

- Fixed a bug that prevented the `group` field to be treated as a regular list.

# reportesAPI 0.1.2

- Former public fields `orgs`, `org_users`, `groups` and `group_users` are now active fields

# reportesAPI 0.1.1

- Email is now hanled from an environment variable.
- Now is possible to get a data.frame of a task progress history.

# reportesAPI 0.1.0

- First minimal version
