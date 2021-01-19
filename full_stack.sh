#!/bin/bash

# Envs
network=$1

# Create homes
mkdir -p $HOME/$network-jira $HOME/$network-conf $HOME/$network-bb $HOME/$network-crowd $HOME/$network-psql  $HOME/$network-crowd

docker network create $network

docker kill $network-jira $network-connie $network-bitbucket $network-crowd $network-psql $network-bamboo
docker rm $network-jira $network-connie $network-bitbucket $network-crowd $network-psql $network-bamboo

# Run Postgres
printf "Starting postgres container\n"

docker run -d \
-p 5432:5432 \
--network=$network \
--name=$network-psql \
-v $HOME/psql:/var/lib/postgresql/data/ \
-e POSTGRES_PASSWORD=test123 \
mbern/postgres-atlas-all:latest

sleep 20s
printf "Postgres is available on localhost:5432 for SQL tooling or psql:5432 internal to docker networks\n"

# Run Jira
printf "Starting Jira container\n"

docker run -d \
-p 8080:8080 \
--network=$network \
--name=$network-jira \
-v $HOME/jira:/var/atlassian/application-data/jira \
-e JVM_MINIMUM_MEMORY=1536m \
-e JVM_MAXIMUM_MEMORY=1536m \
-e ATL_JDBC_URL="jdbc:postgresql://$network-psql:5432/jira" \
-e ATL_JDBC_USER=jira \
-e ATL_JDBC_PASSWORD=jira \
-e ATL_DB_DRIVER="org.postgresql.Driver" \
-e ATL_DB_TYPE="postgres72" \
atlassian/jira-software:latest

printf "sleeping for 30s for slow startups on MacOS\n"

# Run bitbucket
printf "Starting Bitbucket container\n"

docker run -d \
-p 7990:7990 \
-p 7999:7999 \
--network=$network \
--name=$network-bitbucket \
-v $HOME/bitbucket:/var/atlassian/application-data/bitbucket \
-e JDBC_DRIVER="org.postgresql.Driver" \
-e JDBC_USER=bitbucket \
-e JDBC_PASSWORD=bitbucket \
-e JDBC_URL="jdbc:postgresql://$network-psql:5432/bitbucket" \
-e ELASTICSEARCH_ENABLED=false \
atlassian/bitbucket-server:latest

printf "sleeping for 30s for slow startups on MacOS\n"

# Run Bamboo
printf "Starting Bamboo container\n"

docker run -d \
-p 8085:8085 \
--network=$network \
--name=$network-bamboo \
-v $HOME/bamboo:/var/atlassian/application-data/bamboo \
-e JVM_MINIMUM_MEMORY=1536m \
-e JVM_MAXIMUM_MEMORY=1536m \
--init \
atlassian/bamboo-server:latest

printf "sleeping for 30s for slow startups on MacOS\n"

# Run Confluence
printf "Starting Bamboo container\n"

docker run -d \
-p 8090:8090 \
--network=$network \
--name=$network-connie \
-v $HOME/connie:/var/atlassian/application-data/confluence \
-e JVM_MINIMUM_MEMORY=1536m \
-e JVM_MAXIMUM_MEMORY=1536m \
-e ATL_JDBC_URL="jdbc:postgresql://$network-psql:5432/confluence" \
-e ATL_JDBC_USER=confluence \
-e ATL_JDBC_PASSWORD=confluence \
-e ATL_DB_TYPE=postgresql \
atlassian/confluence-server:latest 

printf "#############################################\n"
printf "Jira is available on http://localhost:8080\n"
printf "Bitbucket is available on http://localhost:7990\n"
printf "Bamboo is available on http://localhost:8085\n"
printf "Confluence is available on http://localhost:8090\n"





