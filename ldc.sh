#!/bin/bash

LDC_BASE_DIR="docker"
LDC_COMPOSE_PROD_FILE="${LDC_BASE_DIR}/docker-compose.yml"
LDC_COMPOSE_DEV_FILE="${LDC_BASE_DIR}/docker-compose.dev.yml"
LDC_DOCKER_COMPOSE="docker-compose"
LDC_COMPOSE_CMD="config"
LDC_ENV_FILE='.env'

init() {
  [ ! -f "${LDC_ENV_FILE}" ] && echo "${LDC_ENV_FILE} no such file" && exit 1
  [ ! -f "${LDC_COMPOSE_PROD_FILE}" ] && echo "${LDC_COMPOSE_PROD_FILE} no such file" && exit 1
  source "${LDC_ENV_FILE}"
  LDC_COMPOSE_FILES_ARGS="-f ${LDC_COMPOSE_PROD_FILE}"
  echo "Loaded docker compose file ${LDC_COMPOSE_PROD_FILE}"
  echo "Loaded environment file ${LDC_ENV_FILE}"
  echo "-----------------"
  cat "${LDC_ENV_FILE}"
  echo "-----------------"
}

initdev() {
  [ ! -f "${LDC_COMPOSE_DEV_FILE}" ] && echo "${LDC_COMPOSE_DEV_FILE} no such file" && exit 1
  echo "DEV FILE LOADED"
  LDC_COMPOSE_FILES_ARGS="${LDC_COMPOSE_FILES_ARGS} -f ${LDC_COMPOSE_DEV_FILE}"
}

evalf() {
  echo "~$ $1"
  echo ""
  eval $1
}

start() {
  echo "LDC Start..."
}

stop() {
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} stop $@"
  sleep 1
}

up() {
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} up -d"
}

dev() {
  stop $@
  initdev
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} run --rm --service-ports $1"
}

logs() {
  initdev
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} logs -f $@"
}

ps () {
  initdev
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} ps $@"
}

pull () {
  initdev
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} pull $@"
  pushd ${LDC_BASE_DIR}
  sed -ne 's@^FROM \(.*/.*\)@\1@p' *Dockerfile* | xargs -L 1 docker pull
  popd
}

rm () {
  initdev
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} rm $@"
}

down () {
  initdev
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} down $@"
}

build () {
  initdev
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} build $@"
}

KEY=$1
case "$KEY" in
  "start"|"up"|"dev"|"logs"|"ps"|"rm"|"down"|"pull"|"build")
    init
    shift
    echo ""
    eval "${KEY} $@"
    ;;
  *)
    echo ""
    echo "ldc: Local Docker-Compose."
    echo "Usage: ldc start|up|dev|logs|ps|rm|down|pull|build"
    ;;
esac
