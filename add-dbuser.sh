#!/bin/bash

SCRIPTNAME=$0

function usage {
    cat << EOF

Usage: $SCRIPTNAME [-p] [DBNAME]

A script to quickly add a new user and database.

Options:
  -p,  --password string    Specify a password for the new database
                            user (default no password)

EOF
}

if [[ "$#" == "0" ]]; then
    usage
    exit 1
fi

function checkRequirements {
    if [[ "$EUID" -ne 0 ]]; then
    echo "Error: Please run as root." >&2
    exit 1
    fi

    if ! [ -x "$(command -v docker-compose)" ]; then
    echo 'Error: docker-compose is not installed.' >&2
    exit 1
    fi
}

checkRequirements

upassword=

for arg do
    shift
    if [[ "$arg" == "--port" ]]; then
        upassword=$1
        echo "### Using password"
        echo
        shift
        continue
    fi
    set -- "$@" "$arg"
done

while getopts ":p:" opt; do
    case ${opt} in
        p )
            upassword=$OPTARG
            echo "### Using password"
            echo
            ;;
        \? )
            echo "Error: Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        : )
            echo "Error: Option -$OPTARG requires an argument" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

dbname=$1
user_creation_string="create user $1;"
if [[ upassword ]]; then
user_creation_string="create user $1 identified by '$upassword';"
fi

echo "Enter database root password: "
stty -echo
read -r MYSQL_PASS
stty echo

EXISTS=$(docker-compose exec -T mariadb mysql -p$MYSQL_PASS -e "use $dbname;" 2>&1)

if [[ "$EXISTS" == *"Unknown database"* ]]; then
    EXISTS=
else
    EXISTS=true
    while true; do
        echo "A database named $dbname already exists"
        read -p "Do you want to try creating a user for it? " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

if [[ $EXISTS ]]; then

    docker-compose exec -T mariadb mysql -p$MYSQL_PASS -e "
        $user_creation_string
        grant all privileges on $1.* TO '$1'@'%';
        flush privileges;
    "

else

    docker-compose exec -T mariadb mysql -p$MYSQL_PASS -e "
        create database $1;
        $user_creation_string
        grant all privileges on $1.* TO '$1'@'%';
        flush privileges;
    "

fi
