# LDC; Local Docker Compose

ldc is a development tool for running development environments inside docker.

## Installation

```bash
git clone git@github.com:kitware/ldc.git
cd ldc

# Have a look at your path to pick somewhere you can install ldc
echo $PATH

# Symlink this script into place, choosing a parent directory
make install parent=~/.local/bin

# test installation
ldc
```

## Usage

ldc generally wraps docker-compose, but it is aware of a particular directory structure and provides some nice shortcuts.

* `ldc` looks in `./docker` and `./devops` by defailt
* override `LDC_BASE_DIR` in `.env` if your docker-compose directory is different.

```txt
.
├── docker
│  ├── .env
│  ├── docker-compose.dev.yml
│  └── docker-compose.yml
├── {...project files}
├── .env
└── README.md
```

Then, to get up and running, you will typically do something like this:

```bash
# ldc only works from the project root
cd project_directory

# start docker-compose in detached mode
ldc up -d

# swap out whatever you're ready to work on with a development container
ldc dev up $service_name
```

## Advanced usage

LDC just forwards commands to `docker-compose` and cleverly includes/excludes `docker-compose.yml` files.

```bash
ldc [extensions...] args
```

where `extensions` is 0 or more `docker-compose.{name}.yml` names to include.

```bash
ldc dev local up -d
# ... would be the same as ...
pushd ${LDC_BASE_DIR} && docker-compose \
  -f docker-compose.yml \
  -f docker-compose.dev.yml \
  -f docker-compose.local.yml \
  up -d && popd
```

If `docker-compose.local.yml` doesn't exist (for example), ldc would understand that argument to be intended as passing to `docker-compose`, and docker-compose would throw an error.

## Non-standard commands

Most ldc commands are just `docker-compose` aliases.  These are not:

* pull - pulls all images from compose, but will also pull base images from all dockerfiles in `LDC_BASE_DIR`.
* clean - same as `down -f`.  Removes compose named volumes.
* dev - stop running service, replace it with a version with overrides from docker-compose.dev.yml

## Use case

I created this tool primarily as a front-end developer who sometimes needs to modify backend code.  For me, the cost of learning to set up someone else's development environment is significantly greater than the cost of dealing with the rigidity of this style of dev environment.

It's often much easier to document a dev setup with this tool than to write detailed docs for containerless setups, such as python virtual environments, where env variables, provision scripts, and dependency concerns are involved.
