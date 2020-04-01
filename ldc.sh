#!/bin/bash

LDC_ENV_FILE='.env'
[ -f "${LDC_ENV_FILE}" ] && source "${LDC_ENV_FILE}"

LDC_BASE_DIR="${LDC_BASE_DIR:docker}"
LDC_COMPOSE_PROD_FILE="${LDC_BASE_DIR}/docker-compose.yml"
LDC_COMPOSE_DEV_FILE="${LDC_BASE_DIR}/docker-compose.dev.yml"
LDC_DOCKER_COMPOSE="docker-compose"
LDC_COMPOSE_CMD="config"


init() {
  [ ! -f "${LDC_COMPOSE_PROD_FILE}" ] && echo "${LDC_COMPOSE_PROD_FILE} no such file" && exit 1
  LDC_COMPOSE_FILES_ARGS="-f ${LDC_COMPOSE_PROD_FILE}"
  echo "Loaded docker compose file ${LDC_COMPOSE_PROD_FILE}"
  echo "Loaded environment file ${LDC_ENV_FILE}"
  echo "------env--------"
  cat "${LDC_ENV_FILE}"
  echo "-----------------"
}

initdev() {
  init
  [ ! -f "${LDC_COMPOSE_DEV_FILE}" ] && echo "${LDC_COMPOSE_DEV_FILE} no such file" && exit 1
  echo "Loaded docker compose extension ${LDC_COMPOSE_DEV_FILE}"
  LDC_COMPOSE_FILES_ARGS="${LDC_COMPOSE_FILES_ARGS} -f ${LDC_COMPOSE_DEV_FILE}"
}

evalf() {
  echo ""
  echo "~$ $1"
  echo ""
  eval $1
}

ps () {
  initdev
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} ps $@"
}

check-service() {
  lines=$(ps $@ | grep 'Up' | wc -l)
  [ "$lines" == "0" ] && return 1
  return 0
}

start() {
  initdev
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} start $@"
}

stop() {
  initdev
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} stop $@"
}

up() {
  init
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} up -d"
}

dev() {
  check-service $@ && stop $@
  initdev
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} run --rm --service-ports $1"
}

logs() {
  initdev
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} logs -f $@"
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

clean() {
  down -v
}

build () {
  initdev
  evalf "${LDC_DOCKER_COMPOSE} ${LDC_COMPOSE_FILES_ARGS} build $@"
}

KEY=$1
case "$KEY" in
  "start"|"up"|"dev"|"logs"|"ps"|"rm"|"down"|"pull"|"build"|"clean")
    shift
    eval "${KEY} $@"
    ;;
  *)
    echo "ldc: Local Docker-Compose."
    echo "Usage: ldc start|up|dev|logs|ps|rm|down|pull|build|clean"
    ;;
esac
