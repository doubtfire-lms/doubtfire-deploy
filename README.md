![Doubtfire Logo](http://puu.sh/lyClF/fde5bfbbe7.png)

# Doubtfire Deploy

A modern, lightweight learning management system.

The Doubtfire Deploy repository is used to manage releases of Doubtfire using containers.

More details soon...


## How to use this project for development

```sh
cd doubtfire-api
docker compose build


# Open up to 3 terminal windows in doubtfire-api folder
# In terminal 1
docker compose up

# To listen for incoming responses from Overseer
# In terminal 2 run
docker compose exec doubtfire-api bundle exec rake register_q_assessment_results_subscriber

# Use terminal 3 to interact with system... eg
# Example 1: setup database (only essentials)
docker compose exec doubtfire-api bundle exec rake db:init

# Example 2: setup database (with units, students, and work in progress)
docker compose exec doubtfire-api bundle exec rake db:reset db:migrate db:populate db:simulate_signoff

# Example 3: convert submissions to PDF
docker compose exec doubtfire-api bundle exec rake submission:generate_pdfs

# Example 4: run unit tests (all)
docker compose exec doubtfire-api bundle exec rake test

# Example 5: run unit tests (single file)
docker compose exec doubtfire-api bundle exec rake test test/models/break_test.rb

# Example 6: run unit tests (single test)
docker compose exec doubtfire-api bundle exec rake test test/models/break_test.rb test_breaks_not_colliding

# Example 7: create a new migration
docker compose exec doubtfire-api bundle exec rails g migration migration-name

# Example 8: get interactive rails terminal
docker compose exec doubtfire-api bundle exec rails c

# Example 9: restart overseer
docker compose exec doubtfire-api bundle exec rails g migration migration-name
```

## How to use this project for releasing new versions

Once you have a working product in the development environment described above, the next step is to prepare a release.

1. Commit and push everything. Make sure that all sub modules, and the deploy project are up to date and have all of the changes you want included.
2. Make sure that each sub module has incorporated any other changes from development into its branch.
3. Run `build.sh` this will prepare local containers that mirror those that will be made available to deployments.
4. Test the local containers - run `docker compose up` from the doubtfire deploy project root. You can test the solution using http://localhost:3000/
5. Make any necessary changes to correct issues identified. Repeat 3, 4, and 5 until you are ready to release.
6. Run `release.sh`

## How to use this project for deployment


