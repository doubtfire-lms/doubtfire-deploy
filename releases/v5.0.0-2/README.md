# v5.0.0-2

This is a prerelease of Doubtfire based upon the new Docker deployment model. The following changes are included in this version:

1. New docker deployment targets setup using release scripts in deploy project.
2. Integrate Overseer for automated checking of student work
3. Update web application to allow administration of Overseer and viewing of Overseer results

## Migration steps

To deploy this version:

1. Setup deployment using docker compose from the associated release.
2. Run database migration to incorporate new overseer tables
3. Switch application to use new website container
