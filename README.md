# atl-fullstack

# Run me:
./full_stack.sh demo2

* Script creates networks and volumes based on $1
* Script tears down and kills existing containers, storage is persisted
* Data is on $HOME/$PRODUCT
* Postgres is availabe in the docker network using DNS like $network-psql to configure other containers/apps
