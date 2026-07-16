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

## Deployment Quick Start

The deployment commands use Docker Compose v2 (`docker compose`) and require
`docker-compose-v2`. The legacy Docker Compose v1 command (`docker-compose`) is
not supported.

```sh
sudo apt install docker-compose-v2
```

The [`production/docker-compose.yml`](production/docker-compose.yml) template
runs the published OnTrack Docker images together with MariaDB, Redis, PDF
generation, and a Caddy reverse proxy. See [DEPLOYING.md](DEPLOYING.md) for the
full deployment guide.

```sh
git clone --recurse-submodules https://github.com/doubtfire-lms/doubtfire-deploy.git
cd doubtfire-deploy/production
```

### Configure the deployment

1. Configure your domain and DNS, then obtain a TLS certificate.
2. Map the certificate and private key into the `proxy` service in
   [`docker-compose.yml`](production/docker-compose.yml).
3. Replace `example.com` in [`web/Caddyfile`](production/web/Caddyfile) with
   your domain.
4. Update the institution settings in
   [`api/.env.production`](production/api/.env.production), including the
   institution domain.

The example passwords and secrets in `api/.env.production` may be replaced
after confirming that the stack starts, but replace them before exposing the
deployment publicly or storing real data.

### Start OnTrack

Validate the configuration, download the images, and start the services:

```sh
docker compose config
docker compose pull
docker compose up -d
```

Use `docker compose logs -f` to follow startup. The application can take up to
30 seconds to start.

### Initialise a new database

Run this once for a new deployment with an empty database:

```sh
docker compose exec -e DISABLE_DATABASE_ENVIRONMENT_CHECK=1 pdfgen rails db:setup db:init
```

> [!WARNING]
> This command rebuilds the database and will erase existing data.
> When prompted to run it in production, enter `Yes` exactly as shown.

> [!NOTE]
> If the `database` authentication method is enabled, you will also be asked to enter and
> confirm the initial admin password.

After initialisation, open a Rails console in the API container:

```sh
docker compose exec pdfgen rails console
```

Then inspect the first user to confirm that the `aadmin` account was created:

```ruby
User.first
```

### Apply database migrations

Run migrations after initialising the database and after every OnTrack update:

```sh
docker compose exec pdfgen rails db:migrate
```

That's it! You can now log in and explore OnTrack. Visit the
[OnTrack Deployment Wiki](https://github.com/doubtfire-lms/doubtfire-deploy/wiki) for more
guidance, or [create an issue](https://github.com/doubtfire-lms/doubtfire-deploy/issues/new)
if you run into deployment problems.

## Contributing

Planning to contribute? Start with [CONTRIBUTING.md](CONTRIBUTING.md) for useful
development tips, repository and branching guidance, testing workflows, and the
steps for submitting a pull request.

## License

Licensed under the GNU Affero General Public License (AGPL) v3.
