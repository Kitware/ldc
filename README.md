# LDC; Local Docker Compose

ldc is a development tool for running development environments inside docker.

## Installation

```bash
git clone git@github.com:subdavis/ldc.git
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

To make a project compatible with LDC, you should set up your directories like this, or override `LDC_BASE_DIR` in `.env`.

```txt
.
├── docker
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
ldc up

# swap out whatever you're ready to work on with a development container
ldc dev $service_name
```

## Non-standard commands

Most ldc commands are just `docker-compose` aliases.  These are not:

* pull - pulls all images from compose, but will also pull base images from all dockerfiles in `LDC_BASE_DIR`.
* clean - same as `down -f`.  Removes compose named volumes.
* dev - stop running service, replace it with a version with overrides from docker-compose.dev.yml
