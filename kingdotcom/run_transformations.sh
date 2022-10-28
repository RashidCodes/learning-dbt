# install packages 
dbt deps

# build the entire project
dbt build --profiles-dir . --target prod
