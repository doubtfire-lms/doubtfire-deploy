![Doubtfire Logo](http://puu.sh/lyClF/fde5bfbbe7.png)

# Deploying Doubtfire

Doubtfire is deployed using Docker containers described in a docker compose. This document outlines the main steps in the process for deploying this as an application, which require additional considerations to ensure that the setup is appropriate for your situation. Settings provided, and changes recommended, need to be reviewed by an appropriate security and deployment professional.

When setup, launching the application should only require the docker compose to be started: e.g. `docker compose up`. When setup, the application involves the following components:

- a proxy, based on nginx, that handles HTTPS and routes traffic to the webserver or apiserver containers.
- a webserver, based on nginx, that serves the static html/css/javascript/etc files.
- an apiserver, based on rails, that serves the restful API used by the application.
- an application server (pdfgen), based on rails, that uses cron jobs to periodically generate PDFs from student submissions, and send status emails.
- a database server, based on Maria DB or MySql used by the api and application servers to persist data
- file storage connected to the apiserver and application server for storing student work
- an external mail server to send emails
- an external authentication server to authenticate users.

The setups to configure these components include:

1. You will need:
   - a host on to which to deploy the application
   - certificates for https access to the application, and network setup to route that traffic to the host
   - a mail server to enable notification emails, and a support email address that the application can use
   - an external authentication sources (AAF, SAML, or LDAP)
   - file storage (and backups) for student work
   - optional: separate database server
2. Copy the following files from the **production** folder of this project to the host machine.
   - docker-compose.yml - this file contains the configuration of all containers needed.
   - .env.production - this contains all of the environment variables needed to configure the containers.
   - shared-files folder - this contains configuration files that need to be mapped into containers for email configurations and proxy nginx settings.
3. Adjust settings in **docker-compose.yml**
    - Proxy
      - Replace certificate and key files and volume mappings with certificate created for the institution URL.
    - Apiserver
      - The **student_work** volume should be mapped to the host, and this location should be backed up.
      - Consider where to store doubtfire-logs and update volume if needed
    - Doubtfire-db
      - Remove container if using external database, otherwise configure the MariaDB for your production needs.
    - Pdfgen
      - Adjust **student-work** to match app server.
    - Add monitoring as needed to ensure ongoing operation
4. Adjust **.env.production**:
   - **DF_PRODUCTION_DB_*** settings - adjust database settings for adapter type, host name, database name, and password. The provided setting work with the database setup in the compose file. The password should be updates as a minimum.
   - **DF_SECRET_KEY_DEVISE** - contains the key used to encrypt the [Devise](https://github.com/heartcombo/devise) user data in the database. Keys can be generated with `bundle exec rake secret` run in the *apiserver* container.
   - **DF_SECRET_KEY_BASE** and **DF_SECRET_KEY_ATTR** - these are historic keys used to encrypt data in the database. Generate as with the Devise key.
   - **DF_SECRET_KEY_MOSS** - the key used to connect with the [MOSS](http://moss.stanford.edu) system for checking code similarity.
   - **DF_INSTITUTION_HOST** - change to the URL used for the application
   - **DF_INSTITUTION_PRODUCT_NAME** - change to the name of the deployed product
   - **DF_INSTITUTION_SETTINGS_RB** - can be used when institution specific integrations for synchronising student enrolments.
   - **DF_INSTITUTION_EMAIL_DOMAIN** - the domain name associated with student emails.
   - **DF_INSTITUTION_NAME** - change to the the name of the institution
   - **DF_AUTH_METHOD** - change to the intended authentication method. Do not use database. The authentication source needs to exist externally, or be setup within the system.
     - AAF authentication uses [rapid connect](https://rapid.aaf.edu.au). This is configured with the following settings:
       - DF_AAF_ISSUER_URL
       - DF_AAF_AUDIENCE_URL
       - DF_AAF_CALLBACK_URL
       - DF_AAF_IDENTITY_PROVIDER_URL
       - DF_AAF_UNIQUE_URL
       - DF_AAF_AUTH_SIGNOUT_URL
       - DF_SECRET_KEY_AAF
     - SAML authentication uses:
       - DF_SAML_METADATA_URL
       - DF_SAML_CONSUMER_SERVICE_URL
       - DF_SAML_SP_ENTITY_ID
       - DF_SAML_IDP_TARGET_URL
       - DF_SAML_IDP_SAML_NAME_IDENTIFIER_FORMAT
     - LDAP uses:
       - DF_LDAP_HOST
       - DF_LDAP_PORT
       - DF_LDAP_ATTRIBUTE
       - DF_LDAP_BASE
       - DF_LDAP_SSL
   - **DF_ENCRYPTION_*** - is used in encrypting data in the database. Generate these from within the *apiserver* container using `rails db:encryption:init`. See [Active Record Encryption](https://guides.rubyonrails.org/active_record_encryption.html).
   - Setup email settings, see [Action Mailer](https://guides.rubyonrails.org/action_mailer_basics.html).
     - Set **DF_MAIL_PERFORM_DELIVERIES** to `yes` (lowercase) to enable mail sending
     - Set **DF_MAIL_DELIVERY_METHOD** to *smtp* or disable by setting to *none*. Set the following variables to configure mail sending.
       - DF_SMTP_ADDRESS
       - DF_SMTP_PORT
       - DF_SMTP_DOMAIN
       - DF_SMTP_USERNAME
       - DF_SMTP_PASSWORD
       - DF_SMTP_AUTHENTICATION
5. Adjust **shared-files/proxy-nginx.conf**. This file configures the proxy nginx container that routes traffic to the webserver and apiserver containers. It needs to be update with the host URLs. The provided file uses localhost as the server URL.
6. Configure email settings:
   - Edit **shared-files/aliases** to map the root user email to the support email address that the application will use.
   - Edit **shared-files/msmtprc** to include the necessary details used to connect to your mail server.
7. Initialise the database by running:
   - `DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:setup db:init`. When prompted about running in production, respond with `Yes` (case sensitive) to allow the database initialisation to proceed.
   - Verify the database setup in the rails console `bundle exec rails c`, and update username and email to match expected admin user:

      ```ruby
      u = User.first
      u.email = '...'
      u.username = '...'
      u.save!
      ```

    When successful you should be able to login as the admin user.

