#!/bin/bash

if [ -f '.env' ]; then
  source '.env'
  LDC_ENV_FILE='.env'
fi

POSSIBLE_BASE_DIRS=(docker devops .)

# Figure out where the docker-compose files are
if [ -z ${LDC_BASE_DIR} ]; then
  cwd=$(pwd)
  while [ -n "$(dirname $cwd)" ]; do
    for candidate in ${POSSIBLE_BASE_DIRS[@]}; do
      if [ -f "${cwd}/${candidate}/docker-compose.yml" ]; then
        LDC_BASE_DIR="${cwd}/${candidate}"
        break 2
      fi
    done
    cwd="$(dirname $cwd)"
  done
fi

# If no docker-compose is found
[ ! -d "${LDC_BASE_DIR}" ] && echo "No appropriate compose dir found" && exit 1

LDC_DOCKER_COMPOSE=${LDC_DOCKER_COMPOSE:-docker-compose}
COMPOSE_FILES_ARGS="-f docker-compose.yml"

# Figure out if an arugment is a docker-compose.suffix.yml
# and addit it to 
push_suffix() {
  FILE="docker-compose.${1}.yml"
  if [ -f "${LDC_BASE_DIR}/${FILE}" ]; then
    COMPOSE_FILES_ARGS="${COMPOSE_FILES_ARGS} -f ${FILE}"
    return 0
  fi
  return 1
}

run() {
  pushd ${LDC_BASE_DIR}
  eval "${LDC_DOCKER_COMPOSE} ${COMPOSE_FILES_ARGS} $@"
  popd
}

while(($#)) ; do
  if push_suffix $1; then
    shift
  else
    run $@
    break
  fi
done
