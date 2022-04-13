![Doubtfire Logo](http://puu.sh/lyClF/fde5bfbbe7.png)

# Contributing to Doubtfire

We welcome additions and extensions to Doubtfire that help progress our goal of supporting student learning through frequent formative feedback and delayed summative assessment.

This guide provides high-level details on how to contribute to Thoth-Tech's Doubtfire repositories.

## Table of Contents

- [Contributing to Doubtfire](#contributing-to-doubtfire)
  - [Table of Contents](#table-of-contents)
  - [Doubtfire-deploy](#doubtfire-deploy)
    - [Development Containers](#development-containers)
  - [Getting Started](#getting-started)
    - [Logging In](#logging-in)
    - [Troubleshooting](#troubleshooting)
    - [Interacting with the API](#interacting-with-the-api)
  - [Git Strategy](#git-strategy)

## Doubtfire-deploy

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

## Getting Started

1. Open a terminal and clone Thoth Tech's doubtfire-deploy repo

    ```sh
    git clone --recurse-submodules https://github.com/thoth-tech/doubtfire-deploy
    ```

2. Change into the **development** directory and use [Docker Compose](https://docs.docker.com/compose/) to setup the database. This will populate it with dummy data.

    ```bash
    cd development
    docker compose run --rm doubtfire-api bash
    # now in the container run...
    bundle exec rails db:environment:set RAILS_ENV=development
    bundle exec rake db:populate
    exit
    ```

3. Use `docker compose` to start a running environment.

   ```bash
   # Run in the development folder
   docker compose up
   ```

4. Open a web browser and navigate to:
    * [http://localhost:4200](http://localhost:4200) to use the web application.
    * [http://localhost:3000/api/docs/](http://localhost:3000/api/docs/) to interact with the API using [Swagger](https://swagger.io).

### Logging in
 After populating the database with dummy data, your database will include a number of default users **with each password being "password"**.

| Account Type | Username  |
| ------------ | --------- |
| Admin        | aadmin    |
| Convenor     | aconvenor |
| Tutor        | atutor    |
| Student      | student_1 |


### Troubleshooting

You may encounter errors in the setup process. Here are a few common errors with a potential solution. Feel free to contribute to this list.

| Error         | Solution       |
| ------------- | -------------- |
| `exited with 137` (after running docker compose) | This means docker has run out of memory. To fix, open Docker Desktop and go to Settings -> Resources and increase your memory. If memory is an issue for you, it is possible to remotely develop on an AWS EC2 instance using Visual Studio Code's SSH remote development extension. |
| Unable to close a Docker container | If you have issues shutting down a Docker container, you may need to remove the `pid` file from the tmp folder. In a terminal, you can run `rm ../data/tmp/pids/server.pid` to remove this.


### Interacting with the API

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
  - If you do not gracefully terminate the api you may need to remove the `pid` file from the tmp folder. You can use `rm ../data/tmp/pids/server.pid` to do this.
  - When you bring up the *doubtfire-web* project, it will run `npm install` to setup the node_modules. If you change the package.json in *doubtfire-web* you can just restart the container to update the node modules.

## Git Strategy

  When contributing to the doubtfire projects in the thoth-tech repo, please make sure to follow the git strategy detailed in the [Git Contribution Guide](https://github.com/thoth-tech/handbook/blob/main/docs/processes/quality-assurance/git-contribution-guide.md#git-contribution-guide).

## Testing and Development

  It is important that we are mindful of quality assurance when making contributions. Please refer to [Testing and Development](https://github.com/thoth-tech/handbook/blob/main/docs/processes/quality-assurance/testing-and-dev.md#qa-process---testing-and-development) for further detail.
