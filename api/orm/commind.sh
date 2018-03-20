sequelize-auto -h localhost -d login_demo -u root -x root -p 3306 -t user

Options:
  -h, --host        IP/Hostname for the database.   [required]
  -d, --database    Database name.                  [required]
  -u, --user        Username for database.
  -x, --pass        Password for database.
  -p, --port        Port number for database.
  -c, --config      JSON file for Sequelize's constructor "options" flag object as defined here: https://sequelize.readthedocs.org/en/latest/api/sequelize/
  -o, --output      What directory to place the models.
  -e, --dialect     The dialect/engine that you're using: postgres, mysql, sqlite
  -a, --additional  Path to a json file containing model definitions (for all tables) which are to be defined within a model's configuration parameter. For more info: https://sequelize.readthedocs.org/en/latest/docs/models-definition/#configuration
  -t, --tables      Comma-separated names of tables to import
  -T, --skip-tables Comma-separated names of tables to skip
  -C, --camel       Use camel case to name models and fields
  -n, --no-write    Prevent writing the models to disk.
  -s, --schema      Database schema from which to retrieve tables

node_modules/.bin/sequelize model:generate --name User --attributes firstName:string,lastName:string,email:string
node_modules/.bin/sequelize db:migrate
node_modules/.bin/sequelize db:migrate:undo


sequelize model:generate --name userRegist --attribute userName:string,password:string,verification:string
sequelize model:generate --name user --attributes userName:string,password:string