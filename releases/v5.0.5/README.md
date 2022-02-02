# v5.0.5

This release provides configuration options for mail settings.

## Migration steps

To deploy this version you need to map the msmtprc file to /etc/msmtprc in the PdfGen container to configure the mail.

Environment variables to control smtp have also been added to allow configuration of the mail option in action mailer.
