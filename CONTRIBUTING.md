![Doubtfire Logo](http://puu.sh/lyClF/fde5bfbbe7.png)

# Contributing to Doubtfire

We welcome additions and extensions to Doubtfire that help progress our goal of supporting student learning through frequent formative feedback and delayed summative assessment.

This guide provides high-level details on how to contribute to the Doubtfire repositories.

## Table of Contents

- [Contributing to Doubtfire](#contributing-to-doubtfire)
  - [Table of Contents](#table-of-contents)
  - [Getting started](#getting-started)
    - [Development Containers](#development-containers)
    - [Working with Docker Compose](#working-with-docker-compose)
  - [Forking workflow](#forking-workflow)
    - [About the Doubtfire Branch Structure](#about-the-doubtfire-branch-structure)
    - [Ensure you have your author credentials set up](#ensure-you-have-your-author-credentials-set-up)
    - [Workflow Summary](#workflow-summary)
  - [Branch Prefixes](#branch-prefixes)
  - [Commit Message Format](#commit-message-format)
    - [Use the imperative mood in your commit subject line](#use-the-imperative-mood-in-your-commit-subject-line)
    - [But how can I write new lines if I'm using `git commit -m "Message"`?](#but-how-can-i-write-new-lines-if-im-using-git-commit--m-message)

## Getting started

The **doubtfire-deploy** project provides the base repository containing submodules for each of the specific subprojects.

- [doubtfire-api](https://github.com/doubtfire-lms/doubtfire-api) contain the backend RESTful API. This uses Rails' [active model](https://guides.rubyonrails.org/active_model_basics.html) with the [Grape REST api framework](https://github.com/ruby-grape/grape).
- [doubtfire-web](https://github.com/doubtfire-lms/doubtfire-web) hosts the frontend code implemented in [Angular](https://angular.io) and [AngularJS](https://angularjs.org). This implements the web application that connects to the backend api.
- [doubtfire-overseer](https://github.com/doubtfire-lms/doubtfire-overseer) provides facilities to run automated tasks on student submissions. Please get in touch with the core team if you want access to this repository. You can make contributions without access to this repository.

Development of Doubtfire uses Docker containers to remove the need to install a range of native tools used within the project. The Doubtfire Deploy project helps when working across multiple components of the Doubtfire application, and is used for testing and publishing versions for deployment.

### Development Containers

There are several docker compose setups to aid in speeding up the development.

- Each subproject has its own docker compose that should be used when working on a single repository.
- The **development** folder in the doubtfire deploy project contains separate docker compose setups for working with combinations of projects:
  - The **docker-compose.yml** file contains the most likely setup with development setups for both the api and web projets. This should be used when working on both the api and the web front end. You can run this using **run-api-web.sh**.
  - The **docker-compose.full.yml** contains a setup with all of the containers needed to run Doubtfire with overseer. This requires access to the overseer repository. You can run this using **run-full.sh**

### Working with Docker Compose

To get started:

1. Fork [doubtfire-deploy](https://github.com/doubtfire-lms/doubtfire-deploy), [doubtfire-api](https://github.com/doubtfire-lms/doubtfire-api), and [doubtfire-web](https://github.com/doubtfire-lms/doubtfire-web)

    To push your contributions, you will need a fork of each repository. Contributions can then be made by making pull requests back into the main repositories.

2. Clone your [doubtfire-deploy](https://github.com/doubtfire-lms/doubtfire-deploy). Make sure to fetch submodules to get the subprojects.

    `git clone --recurse-submodules https://github.com/YOUR_USERNAME/doubtfire-deploy`

3. Open a Terminal that supports `sh` scripts (on Windows, you will need WSL, Msys2, or Cygwin). Run the following command to set your fork as the remote.

    `./change_remotes.sh`

4. Change into the **development** directory and use [Docker Compose](https://docs.docker.com/compose/) to setup the database.

    ```bash
    cd development/api-web
    docker compose run --rm doubtfire-api bash
    # now in the container run...
    bundle exec rails db:environment:set RAILS_ENV=development
    bundle exec rake db:populate
    exit
    ```

5. Now you can use `docker compose` to start a running environment.

   ```bash
   # Run in the development folder
   docker compose up
   ```

6. Open a web browser and navigate to:

    - [http://localhost:3000/api/docs/](http://localhost:3000/api/docs/) to interact with the API using [Swagger](https://swagger.io).
    - [http://localhost:4200](http://localhost:4200) to use the web application.

    The database will include a number of default users, each with password being "password".
    - Admin user: **aadmin**
    - Convenor user: **aconvenor**
    - Tutor user: **atutor**
    - Students: **student_1**

    To interact with the rails console, or other rails command line applications:

    - Connect to a **doubtfire-api** container:
      - Attach a terminal to the doubtfire-api container: `docker compose exec doubtfire-api bash`
      - Or run a new container if api is not running: `docker compose run --rm doubtfire-api bash`
    - Access the backend API using:
      - Rails console for interactive code: `bundle exec rails c`
      - Test using
        - Setup test environment: Run the following in a single docker terminal connected to doubtfire-api.
          - `rails db:environment:set RAILS_ENV=test`
          - `RAILS_ENV=test bundle exec rake db:populate`
        - Run all unit tests using: `bundle exec rails test`
        - Run tests from a single file: `bundle exec rails test test/models/break_test.rb`
        - Run a single test: `bundle exec rails test test/api/auth_test.rb:107`
      - Setup the databse:
        - Reset the database: `bundle exec rake db:reset db:migrate`
        - Migrate the database on schema changes: `bundle exec rake db:migrate`
        - Add a new migration: `bundle exec rails g migration migration-name`
      - Work with submissions:
        - Generate PDFs with: `bundle exec rake submission:generate_pdfs`
        - Simulate student work using: `bundle exec rake db:simulate_signoff`
      - Overseer:
        - Start overseer result subscriber: `bundle exec rake register_q_assessment_results_subscriber`

    - Access the **doubtfire-web** container use:
      - Attach a terminal to the doubtfire-web container: `docker compose exec doubtfire-web /bin/bash`
      - Or run a new container if web is not running: `docker compose run --rm doubtfire-web /bin/bash`
    - In the doubtfire-web container you will have access to `ng` and `npm`

    Some things to know about the setup:

    - The containers link to `../data` as a volume to store database details, tmp files, and student work.
    - If you do not gracefully terminal the api you may need to remove the `pid` file from the tmp folder. You can use `rm ../data/tmp/pids/server.pid` to do this.
    - When you bring up the *doubtfire-web* project, it will run `npm install` to setup the node_modules. If you change the package.json in *doubtfire-web* you can just restart the container to update the node modules.

## Forking workflow

We follow a [Forking workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/forking-workflow) when developing on any Doubtfire repository.

### About the Doubtfire Branch Structure

The two primary branches to work from are:

- `development` which is the latest state of the application. Generally start work from this branch.
- `main` when work is deployed it will be incorporated into the main branch.

To start work on a new feature.

1. Branch the subproject off the `development` branch, giving your branch one of the prefixes defined below,
2. Make your changes in that branch,
3. Create a **draft** [Pull Request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) and document the change you are working on. Doing this early will make sure that you get feedback on your work quickly.
4. Complete your work, pushing to your fork's feature branch. This will update your existing PR (no need to create new PRs)
5. Update the status of your PR removing the **draft** status, and flag someone in the Core team to review and incorporate your work.
6. Address any changes required. Pushing new commits to your branch to update the PR as needed.
7. Once your PR is merged you can delete your feature branch and repeat this process for new features...

In some cases, your branches may only consist of one or two commits. This is still okay as you can submit a pull request for code review back into `development`.

### Ensure you have your author credentials set up

You should ensure your git user config details are set to the email address you use with GitHub:

```bash
git config --global user.email "my-github-email@gmail.com"
git config --global user.name "Freddy Smith"
```

### Workflow Summary

**Step 1.** Set up for new feature branch:

```bash
$ git checkout development                # make sure you are on develop
$ git pull --rebase upstream development  # sync your local develop with upstream's develop
$ git checkout -b my-new-branch           # create your new feature branch
```

**Step 2.** Make changes, and repeat until you are done:

```bash
$ git add ... ; git commit ; git push     # make changes, commit, and push to origin
```

**Step 3.** Submit a pull request and **if unable to merge**:

```bash
$ git pull --ff upstream development      # merge upstream's develop in your feature branch
$ git add ... ; git commit                # resolve merge conflicts and commit
$ git push origin                         # push your merge conflict resolution to origin
```

**Step 4.** Only when the pull request has been **approved and merged**, clean up:

```bash
$ git checkout development                # make sure you are back on develop
$ git branch -D my-new-branch             # delete the feature branch locally
$ git push --delete my-new-branch         # delete the feature branch on origin
$ git fetch origin --prune                # make sure you no longer track the deleted branch
$ git pull upstream development           # pull the merged changes from develop
$ git push origin development             # push to origin to sync origin with development
```

## Branch Prefixes

When branching, try to prefix your branch with one of the following:

Prefix     | Description                                                               | Example
-----------|---------------------------------------------------------------------------|--------------------------------------------------------------------
`feature/` | New feature was added                                                     | `feature/add-learning-outcome-alignment`
`fix/`     | A bug was fixed                                                           | `fix/crash-when-code-submission-finished`
`enhance/` | Improvement to existing feature, but not visual enhancement (See `LOOKS`) | `enhance/allow-code-files-to-be-submitted`
`looks/`   | UI Refinement, but not functional change (See `ENHANCE`)                  | `looks/rebrand-ui-for-version-2-marketing`
`quality/` | Refactoring of existing code                                              | `quality/make-code-convention-consistent`
`doc/`     | Documentation-related changes                                             | `doc/add-new-api-documentation`
`config/`  | Project configuration changes                                             | `config/add-framework-x-to-project`
`speed/`   | Performance-related improvements                                          | `speed/new-algorithm-to-process-foo`
`test/`    | Test addition or enhancement                                              | `test/unit-tests-for-new-feature-x`

## Commit Message Format

We have precise rules over how our Git commit messages must be formatted. This format makes it easier to read the commit history.

Each commit message consists of a header, a body, and a footer.

```text
<header>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

The `header` is mandatory and must conform to the Commit Message Header format.

The `body` is recommended for all commits. When the body is present, it must be at least 20 characters long and conform to the Commit Message Body format.

The `footer` is optional. The Commit Message Footer format describes the purpose and structure of the footer.

Any line of the commit message should be 100 characters or fewer.

```text
Commit Message Header
<type>(<scope>): <short summary>
  │       │             │
  │       │             └─⫸ Summary in present tense. Not capitalized. No period at the end.
  │       │
  │       └─⫸ Commit Scope (optional): animations|common|style|forms|http|router|service-worker|
  │                                     upgrade|changelog|dev-infra|docs-infra|migrations|
  │
  └─⫸ Commit Type: build|ci|docs|feat|fix|perf|refactor|test
```

The `<type>` and `<summary>` fields are mandatory, the `(<scope>)` field is optional.

The `<type>` must be one of the following:

- **build**: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- **ci**: Changes to our CI configuration files and scripts (example scopes: Circle, BrowserStack, SauceLabs)
- **docs**: Documentation only changes
- **feat**: A new feature
- **fix**: A bug fix
- **perf**: A code change that improves performance
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **test**: Adding missing tests or correcting existing tests

We recommend reading Chris Beam's post on [How to Write Good Commit Messages](http://chris.beams.io/posts/git-commit/).

### Use the imperative mood in your commit subject line

Write your commits in the imperative mood and not the indicative mood

- "Fix a bug" and **not** "Fix*ed* a bug"
- "Change the behaviour of Y" and **not** "*Changed* the behaviour of Y"
- "Add new API methods" and **not** "Sweet new API methods"

Keep the subject line (top line) concise; keep it **within 50 characters**.

Use the body (lines after the top line) to explain why and what and *not* how; keep it **within 72 characters**.

### But how can I write new lines if I'm using `git commit -m "Message"`?

Don't use the `-m` switch. Use a text editor to write your commit message instead.

If you are using the command line to write your commits, it is useful to set your git editor to make writing a commit body easier. You can use the following command to set your editor to Visual Studio Code, `nano`, `emacs`, `vim`, `atom`.

```bash
git config --global core.editor "code --wait"
git config --global core.editor nano
git config --global core.editor emacs
git config --global core.editor vim
git config --global core.editor "atom --wait"
```
