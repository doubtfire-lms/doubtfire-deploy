![Doubtfire Logo](http://puu.sh/lyClF/fde5bfbbe7.png)

# Migrating between Doubtfire Versions

## Version 5 to Version 6

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

## Version 4 to Version 5

Migration from version 4 to version 5 does not require any specific custom migration. Database updates will be applied through rails migrations.
