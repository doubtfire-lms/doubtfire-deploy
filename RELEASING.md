![Doubtfire Logo](http://puu.sh/lyClF/fde5bfbbe7.png)

# Releasing a new version of Doubtfire

## How to use this project for releasing new versions

Once you have a working product in the development environment described above, the next step is to prepare a release.

1. Commit and push everything. Make sure that all sub modules, and the deploy project are up to date and have all of the changes you want included.
2. Make sure that each sub module has incorporated any other changes from development into its branch.
3. Run `build.sh` this will prepare local containers that mirror those that will be made available to deployments.
4. Test the local containers - run `docker compose up` from the doubtfire deploy project root. You can test the solution using http://localhost:3000/
5. Make any necessary changes to correct issues identified. Repeat 3, 4, and 5 until you are ready to release.
6. Run `release.sh`
