# NYCflights

## File structure
The root of the project contains two directories: app and data.

Everything the App needs to work as a standalone is contained within 'app'. The App uses a local DB located in app/data/nyc.sqlite3 and loads
a number of csv files themselves placed in app/data.

If you wish to generate these files though, you can then refer to the directory 'data'. Therein, data/db_setup.R is used to minimally pre-process the
nyc2013 dataset and store it in a .sqlite3 file. Furthermore, data/model/vertraging_model.R contains the Random Forest model used to fit the data and
generate the feature importance files stored in csv format.

## Running the app
Pull this repository and run the App from RStudio by opening ui.R, server.R or global.R. Alternatively, you can access it via the 
web: emme.shinyapps.io/nzacasus
