#!/bin/bash

# Name for the container, also used in the server url
CONTAINER_NAME=api-template

# Docker server url (url to push the container towards
DOCKER_SERVER_URL=docker.sprinternet.nu:5000/$CONTAINER_NAME

# Port to use on the host machine
HOST_PORT=3000

# Port to use inside the container (forwards the traffic from HOST_PORT to this port)
CONTAINER_PORT=3000

# Environment to run the server in
RAILS_ENV=staging

# Location of the configuration directory on the host machine
CONFIG_DIR=/sprint/config/$CONTAINER_NAME

# Location of the log directory on the host machine
LOG_DIR=/sprint/log/$CONTAINER_NAME

# Location of the rails app (root folder)
CONTAINER_APP_LOCATION=/usr/src/app

# If sudo should be used for the docker command
USE_SUDO=false # true/false

# Git branch
GIT_BRANCH=master

# Environment variables
# e.g. ENV_VARS[RAILS_ENV]=$RAILS_ENV
declare -A ENV_VARS
ENV_VARS[RAILS_ENV]=$RAILS_ENV

# Config files
# e.g. CONF_FILES[database.yml]=$CONTAINER_APP_LOCATION/config/database.yml
declare -A CONF_FILES
CONF_FILES[database.yml]=$CONTAINER_APP_LOCATION/config/database.yml
CONF_FILES[swagger.yml]=$CONTAINER_APP_LOCATION/config/swagger.yml
CONF_FILES[smtp.yml]=$CONTAINER_APP_LOCATION/config/smtp.yml

# Volume links
# e.g. VOLUMES[$LOG_DIR]=$CONTAINER_APP_LOCATION/log
declare -A VOLUMES

# Container links
# e.g. LINKS[postgres]=postgres
declare -A LINKS


















############################################################
####################### Functions ##########################
############################################################

DOCKER_COMMAND=docker

if [ $USE_SUDO ]; then
  DOCKER_COMMAND="sudo $DOCKER_COMMAND"
fi

buildRunCommand() {
  DOCKER_RUN="$DOCKER_COMMAND run --name $CONTAINER_NAME --restart=always -d -p $HOST_PORT:$CONTAINER_PORT"

  # Add Env variables
  for key in "${!ENV_VARS[@]}"; do
    if [ -n "${ENV_VARS[$key]}" ]
      then
        DOCKER_RUN="$DOCKER_RUN -e \"$key=${ENV_VARS[$key]}\""
    fi
  done

  # Add config files
  for key in "${!CONF_FILES[@]}"; do
    if [ -n "${CONF_FILES[$key]}" ]
      then
        if [ -f $CONFIG_DIR/$key ]; then
          DOCKER_RUN="$DOCKER_RUN -v $CONFIG_DIR/$key:${CONF_FILES[$key]}"
        else
          echo '#######################################'
          echo "Config file $CONFIG_DIR/$key not found!"
          echo '#######################################'
          exit 1
        fi
    fi
  done

  # Add volumes
  for key in "${!VOLUMES[@]}"; do
    if [ -n "${VOLUMES[$key]}" ]
      then
        if [ -d $key ]; then
          DOCKER_RUN="$DOCKER_RUN -v $key:${VOLUMES[$key]}"
        else
          echo '#######################################'
          echo "Directory $key not found!"
          echo '#######################################'
          exit 1
        fi
    fi
  done

  # Add links
  for key in "${!LINKS[@]}"; do
    if [ -n "${LINKS[$key]}" ]
      then
        DOCKER_RUN="$DOCKER_RUN --link $key:${LINKS[$key]}"
    fi
  done

  DOCKER_RUN="$DOCKER_RUN $DOCKER_SERVER_URL"
}

restartContainer() {
  echo '########################'
  echo '  ##   Restarting   ##'
  echo '########################'

  if $DOCKER_COMMAND rm -f $CONTAINER_NAME; then
    echo '########################'
    echo '##  Container stopped  ##'
    echo '########################'
  fi

  buildRunCommand

  if $DOCKER_RUN; then
    echo '########################'
    echo '  ##      Done      ##'
    echo '########################'

    echo '########################'
    echo '## Running containers ##'
    echo '########################'
    $DOCKER_COMMAND ps
  else
    echo '########################'
    echo '# Something went wrong #'
    echo '########################'
    exit 1
  fi
}

buildImage() {
  echo '########################'
  echo '  ## Building image ##'
  echo '########################'

  git stash
  if git pull origin $GIT_BRANCH; then
    git checkout $GIT_BRANCH
    git stash pop
  else
    echo '########################'
    echo '# Something went wrong #'
    echo '########################'
    exit 1
  fi

  if $DOCKER_COMMAND build -t $DOCKER_SERVER_URL .; then
    $DOCKER_COMMAND tag $DOCKER_SERVER_URL $DOCKER_SERVER_URL:$(git rev-parse HEAD)
    $DOCKER_COMMAND push $DOCKER_SERVER_URL

    echo '########################'
    echo '    ## Build done ##'
    echo '########################'
  else
    echo '########################'
    echo '# Something went wrong #'
    echo '########################'
    exit 1
  fi
}

fetchImage() {
  echo '########################'
  echo '  ## Fetching image ##'
  echo '########################'

  $DOCKER_COMMAND pull $DOCKER_SERVER_URL

  echo '########################'
  echo '  ## Image Fetched ##'
  echo '########################'
}

removeOldImages() {
  echo '########################'
  echo '## Removing old images ##'
  echo '########################'

  $DOCKER_COMMAND rmi -f $($DOCKER_COMMAND images | grep "months\|weeks\|days" | awk "{print \$3}")

  echo '########################'
  echo '## Old images removed ##'
  echo '########################'

}

if [ -f ./Dockerfile ]; then
  echo '########################'
  echo '    # Build image? #'
  echo '########################'
  while true; do
    read -p "Ready to build image? (yn) " Yn
    case $Yn in
      [Yy]* ) buildImage; break;;
      [Nn]* ) echo 'aborted'; break;;
      * ) echo 'Please answer Yes(Yy) or No(Nn)';;
    esac
  done
else
  echo '########################'
  echo '    # Fetch image? #'
  echo '########################'
  while true; do
    read -p "Ready to fetch image? (yn) " Yn
    case $Yn in
      [Yy]* ) fetchImage; break;;
      [Nn]* ) echo 'aborted'; break;;
      * ) echo 'Please answer Yes(Yy) or No(Nn)';;
    esac
  done
fi

echo '########################'
echo ' # Ready to (re)start? #'
echo '########################'
while true; do
  read -p "Ready to (re)start the container? (yn) " Yn
  case $Yn in
    [Yy]* ) restartContainer; break;;
    [Nn]* ) echo 'aborted'; break;;
    * ) echo 'Please answer Yes(Yy) or No(Nn)';;
  esac
done

echo '########################'
echo ' # Remove old images? #'
echo '########################'
while true; do
  read -p "Remove old images to save disk space? (y/n) " Yn
  case $Yn in
    [Yy]* ) removeOldImages; break;;
    [Nn]* ) echo 'no cleanup'; break;;
    * ) echo 'Please answer Yes(Yy) or No(Nn)';;
  esac
done
