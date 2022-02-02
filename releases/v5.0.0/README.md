# v5.0.0

Version 5 integrates the automated assessment infrastructure provided through the overseer project.

## Migration steps

To deploy this version:

1. Update container versions
2. Restart containers. This will:
   - Migrate the database to add tables for Overseer support

To enable overseer:

1. Set the `OVERSEER_ENABLED` environment variable to `1`
2. Setup rabbitmq to route messages from doubtfire-api to overseer
   - Configure `RABBITMQ_HOSTNAME`, `RABBITMQ_USERNAME`, and `RABBITMQ_PASSWORD` environment variables to provide access to rabbitmq.
3. Setup separate volume for overseer. Overseer will store student work to be processed in this volume.
4. List available docker containers to host automated scripts in the admin interface.
5. Update units and tasks to turn on the overseer integration.
