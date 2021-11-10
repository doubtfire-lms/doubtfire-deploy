# Development docker files

This folder contains dockerfiles used to create and work with Doubtfire in development.

Get starting by doing the following:

- When doing this for the first time. Launch a terminal in the doubtfire-api container and setup the database:
  
  - `docker compose run --rm doubtfire-api bash`
  - `bundle exec rails db:environment:set RAILS_ENV=development`
  - `bundle exec rake db:populate`
  - `exit`

  Make sure you can see output that indicates the database was created, and populated with users, units, students, etc.

- To launch and application (web and api)
  
  - `docker compose up`
  - Wait for things to run...
  - Open a web browser navigate to:

    - [http://localhost:3000/api/docs/](http://localhost:3000/api/docs/) to interact with the API
    - [http://localhost:4200](http://localhost:4200) to use the web application

  - To interact with the rails console, or other rails command line applications:

    - Attach a terminal to the doubtfire-api container: `docker compose exec doubtfire-api bash`
    - To run the rails console use: `bundle exec rails c`
    - To run rails tests use: `bundle exec rails test`

- Some things to know...

  - The containers link to `../data` as a volume to store database details, tmp files, and student work.
  - If you do not gracefully terminal the api you may need to remove the `pid` file from the tmp folder. You can use `rm ../data/tmp/pids/server.pid` to do this.
