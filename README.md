<p align="center">
	<img alt="OnTrack logo" src="./ontrack-logo.png" width="192">
</p>

# OnTrack Deployment

OnTrack (formerly Doubtfire) is a feedback-driven learning support system. This repository brings
together the OnTrack services and is the central place for development and
deployment instructions.

## Development

You need [Git](https://git-scm.com/), [Docker](https://www.docker.com/), and
[Visual Studio Code](https://code.visualstudio.com/) with the
[Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
The container installs the other recommended editor extensions automatically.

```sh
git clone --recurse-submodules https://github.com/doubtfire-lms/doubtfire-deploy.git
cd doubtfire-deploy
code .
```

In VS Code, open the Command Palette (`Cmd+Shift+P` on macOS or
`Ctrl+Shift+P` on Windows/Linux), then run **Dev Containers: Reopen in
Container**. The container sets up the dependencies and development services,
then starts the API and web app.
Open <http://localhost:4200> when startup is complete.

## Deployment

The [`production/docker-compose.yml`](production/docker-compose.yml) template
runs the published OnTrack Docker images together with MariaDB, Redis, PDF
generation, and a Caddy reverse proxy.

Before starting it:

1. Set matching API, web, and support-image releases in
   [`production/.env`](production/.env).
2. Replace every example password and secret in
   [`production/api/.env.production`](production/api/.env.production).
3. Configure your hostname and authentication settings there.
4. Replace the example files in `production/web/certificates`, then update
   [`production/web/Caddyfile`](production/web/Caddyfile) for your domain.
5. Arrange off-host backups for the database and `student_work` volumes.

Then validate and start the stack:

```sh
cd production
docker compose config
docker compose pull
docker compose up -d
docker compose exec pdfgen rails db:migrate
```

Use `docker compose logs -f` to follow startup. Pin specific release tags in
production and review the Compose template, storage, mail, authentication, TLS,
and backup settings for your institution before exposing the service publicly.

## Contributing

Planning to contribute? Start with [CONTRIBUTING.md](CONTRIBUTING.md) for useful
development tips, repository and branching guidance, testing workflows, and the
steps for submitting a pull request.

## License

Licensed under the GNU Affero General Public License (AGPL) v3.
