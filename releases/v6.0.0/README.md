# v6.0.0

This release is a large shift in the deployment approach for Doubtfire, major upgrades to back end libraries, iterative enhancements to the front end, and new branding. The resulting product should be faster for all use cases, easier to deploy, easier to develop, and easier to upgrade going forward. We see this version as providing the foundation for the product going forward, and allowing us to more rapidly integrate new ideas and update backend components.

Going forward, the next critical components for the project will be completing the migration of the front end. We aim to release this as components are updated as minor updates to v6.

- Library updates and deployment changes:
  - Updates ruby to 3.1, rails to version 7, and all back end gems
  - Upgraded to Angular 13
  - Shifts to Active Record Encryption
  - Improvements to the Docker development and production workflows
  - Improved release automation
- Enhancements
  - Adds support for SAML2.0 authentication
  - Separates authentication tokens from users, allowing multiple tokens
  - Removes auth token from most query parameters, now uses the request header to support the new backend version
  - Adds Deploy to contributors information
  - Adds new Header redesign and upgrade
  - Adds new Home redesign and upgrade
  - Disable http interceptor to reduce network traffic on failures
  - Enhance app updater
  - Add new splash screen on home load
  - Moves to a new system-wide theme
  - Responsive home and header
  - Provides the ability to work on projects in isolation, or in combinations via the deploy project

## Migration steps

Version 6 includes changes to database encryption that require custom migration processes in order to retain current authentication tokens in use. Where this is skipped, the standard migration will lose these tokens and users will need to login again.

1. While running Version 5:

  The authentication tokens are encrupted in the database in a way that will not be accessible in version 6. In order to migrate the tokens, you will need to login to the server and save the current authentication tokens using the following script in the rails console. This will get the auth tokens for all logged in users, and export them to a tokens.rb file in the log folder. Alternate locations can be used as required.

  ```ruby
  lines = User.where("auth_token_expiry > CURRENT_DATE()").map { |user| "AuthToken.create(user_id: #{user.id}, authentication_token: '#{user.auth_token}', auth_token_expiry: DateTime.parse('#{user.auth_token_expiry}'))" }.join("\n")
  File.write("#{Rails.root}/log/tokens.rb", lines)
  ```

2. Ensure you have sufficient space to recreate the database - we suggest ensuring you can double the size of the current database during the migration process. This extra size will reduce after migration, once the tables have been re-written.
3. Backup the database prior to upgrading, as data will be lost in the process and it will be easier to restore from a backup if the migration fails.
4. Update to Version 6 and migrate the database.
5. Execute the exported script to create the required authentication tokens. Failure to do this will only result in users needing to login again to continue use of the application.
