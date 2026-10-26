# Upgrading OnTrack from 10.x to 11.x

This guide covers upgrading an existing 10.x installation. 11.x replaces
the 10.x Compose stack: Caddy replaces the nginx proxy, the env files move, and
new services are added. Start from the
[production template](https://github.com/doubtfire-lms/doubtfire-deploy/tree/11.0.x/production)
instead of editing your 10.x files. See the [deployment guide](DEPLOYING.md) for
the full setup.

**You need Docker Compose v2.24 or later.** The template uses optional
`env_file` entries, which older versions reject. Check with
`docker compose version`.

## Before the upgrade

1. **Fix names 11.x rejects.** 11.x validates user first, last, and
   preferred names (`nickname`), unit names and codes, and task titles with the
   [AllowedCharactersValidator](doubtfire-api/app/validators/allowed_characters_validator.rb).
   Run this read-only script in the running 10.x Rails console, fix what it
   reports, and rerun it until it reports nothing. Task titles must start with
   a letter or number; `*` and `+` are allowed after that.

   ```ruby
   alphanumeric = /\A[\p{L}\p{M}\p{N}]\z/u
   fields = {
     User => { first_name: " -()_/,，.'’", last_name: " -()_/,，.'’", nickname: " -()_/,，.'’" },
     Unit => { name: " -#()", code: "-#/_" },
     TaskDefinition => { name: " -#()&/:_.'\"*+" }
   }

   invalid_count = 0
   previous_logger = ActiveRecord::Base.logger
   begin
     ActiveRecord::Base.logger = nil
     fields.each do |model, rules|
       model.find_each do |record|
         rules.each do |attribute, punctuation|
           value = record.public_send(attribute)
           next if value.blank?

           invalid = value.each_char.reject do |character|
             character.match?(alphanumeric) || punctuation.include?(character)
           end.uniq
           if model == TaskDefinition && !value[0].match?(alphanumeric)
             invalid |= [value[0]]
           end
           next if invalid.empty?

           invalid_count += 1
           details = if record.is_a?(TaskDefinition)
                       " unit=#{record.unit&.code.inspect} abbreviation=#{record.abbreviation.inspect}"
                     else
                       ''
                     end
           puts "#{model.name} id=#{record.id}#{details} #{attribute}: #{invalid.inspect}"
         end
       end
     end
   ensure
     ActiveRecord::Base.logger = previous_logger
   end
   puts "Fields with unsupported characters: #{invalid_count}"
   ```

2. **Plan the maintenance window.** The migration does three slow things:
   - **Overseer history.** Each unit's `submission_history` timestamp folders
     are packed into `history.zip` files, including archived units. A few units
     with one Overseer job per task took us about an hour. To size it, run
     this in the 10.x Rails console:

     ```ruby
     OverseerAssessment.joins(task: { project: :unit }).group('units.archived').count
     ```

     To shorten it, delete history you no longer need (especially for
     inactive units) after checking your retention requirements. Deleted
     history is gone from OnTrack.

   - **Comment read receipts.** These are backfilled into the new
     `comment_read_cursors` table. Our 25.7 million receipt rows took about
     11 minutes; allow an hour, more for larger tables. The old
     `comments_read_receipts` table stays until the next major version.
   - **Temporary ZIP files.** Leave free disk space next to student work.

3. **Stop and back up.** Let active submissions and jobs finish, then stop
   the 10.x stack. Back up the database and all student work, including
   archived units: the migration restructures it.

   To drain work, run these against your 10.x stack. The first quiets
   Sidekiq: new jobs are still queued, but only the active ones finish.
   Queued jobs wait until Sidekiq restarts. The second removes the pdfgen
   crontab which pauses portfolio generation.

   ```sh
   docker compose exec apiserver bash -c "cd /doubtfire && rails runner 'Sidekiq::ProcessSet.new.each(&:quiet!)'"
   docker compose exec pdfgen crontab -r
   ```

4. **Clear `student-work/new` and `student-work/in_process`** while
   everything is stopped. Otherwise 11.x's scheduled jobs pick up the
   leftovers and may notify students about tasks from past semesters.

5. **Move JPlag reports if needed.** `DF_JPLAG_REPORT_DIR` is gone; reports
   now live in `student-work/jplag/results`. Copy old reports there to keep
   them. Otherwise, reports are regenerated for active units only.

## Deploy 11.x

1. **Copy the template into your existing 10.x directory.** That way
   Compose reuses your `mysql_db` and `student_work` volumes. If you mapped
   student work to a host path, use it for every `student_work` mount in the
   new `docker-compose.yml`, including `proxy`, `texlive`, and `jplag`.

2. **Update your settings.** If you use the template's
   `docker-compose.yml` as is, it expects this layout; otherwise adapt it to
   your setup.

   | 10.x template                          | 11.x template                                                        |
   | -------------------------------------- | -------------------------------------------------------------------- |
   | `.env.production`                      | `api/.env.production`, overridden by `api/.env.production.local`     |
   | `shared-files/` (`msmtprc`, `aliases`) | `api/shared-files/`                                                  |
   | Image tags in `docker-compose.yml`     | `.env`, which `docker-compose.yml` reads automatically               |
   | nginx config and certificate mounts    | `web/caddy.env.local`, and certificate mounts on the `proxy` service |

   New API env vars to check:
   - `CORS_ALLOWED_ORIGINS`: browser origins allowed to call the API. Set it
     to your public site; the template's `https://localhost` breaks the web
     app's API calls.
   - `CADDY_DOWNLOAD_AUTH_SECRET`: generate one with `openssl rand -hex 32`
     and set the same value for the API and Caddy.
   - `DF_ENFORCE_LOGIN_ID_MATCH`: when `true` (the template default), blocks
     sign-in when a matched account's stored login ID differs from the
     identity provider's. Set it to `false` if your login IDs have changed
     over time.
   - `GOTENBERG_WORKDIR_VOLUME_MOUNT`: the absolute host path of
     `api/tmp/gotenberg`. The API starts Gotenberg through the host's Docker
     socket, so it needs a host path, not a container path.
   - `LTI_ENABLED`: leave `false` unless you are setting up LTI.

3. **Set up Caddy.** 11.x replaces the 10.x nginx proxy with the
   template's [Caddyfile](production/web/Caddyfile). The old nginx config is
   untested with 11.x and unsupported. Don't edit the Caddyfile. In
   `web/caddy.env.local`, set `ONTRACK_SITE_ADDRESS` to your hostname
   (without `https://`). Point the `proxy` service's certificate mounts in
   `docker-compose.yml` at your certificate and key, keeping the container
   paths. If Moodle embeds OnTrack as an LTI tool, also set `ONTRACK_MOODLE_ORIGIN`.

   Optional settings in `web/caddy.env.local`:
   - **Sidekiq dashboard at `/sidekiq`:** set `ENABLE_SIDEKIQ_WEB=true`,
     `SIDEKIQ_WEB_USERNAME`, and `SIDEKIQ_WEB_PASSWORD_HASH`. Generate the hash
     with `caddy hash-password` and wrap it in single quotes so the `$`
     characters survive.
   - **Faster downloads:** set `SERVE_VIA_CADDY=true`. Rails still checks
     access for each download; Caddy then sends the file. This needs
     `CADDY_DOWNLOAD_AUTH_SECRET`, set in step 2.

4. **Set the images.** `.env` sets the API and web images to `prod-11.0`, so
   `docker compose pull` picks up 11.0.x patch releases. Update them together.
   Later minor releases (11.1 onwards) may include migrations, so upgrade to them
   deliberately.

5. **Migrate.** Pull the images and run the migration before starting the
   stack. `docker compose run` starts only the database
   and Redis alongside it.

   ```sh
   docker compose pull
   docker compose run --rm apiserver bundle exec rails db:migrate
   ```

   Do not use `api/deploy.sh` for this upgrade. It does blue-green deployments
   for later releases that have no migrations.

6. **Start and check.** Run `docker compose up -d`, then check the API,
   Sidekiq, and pdfgen logs. Before reopening submissions, check that you can
   sign in, that existing submission histories open, and that a new submission
   (including a Word document) is processed. Also check that downloads work
   and that email is sent.
