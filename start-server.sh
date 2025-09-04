#!/usr/bin/env sh

start_server() {
  docker compose up -d
}

new_world() {
  echo "Creating new world"

  git checkout main || {
    echo "Failed to checkout main branch"
    exit 1
  }

  new_branch="world-$(date +%Y%m%d-%H%M%S)"

  git checkout -b "$new_branch" || {
    echo "Failed to create new branch $new_branch"
    exit 1
  }
}

save_world() {
  echo "Saving world"

  git add -A || {
    echo "Failed to stage changes"
    exit 1
  }

  git commit -m "World auto save at $(date +%Y%m%d-%H%M%S)" || {
    echo "Failed to commit changes"
  }

}

clean_world() {
  echo "Cleaning world"

  git reset --hard HEAD && git clean -fd

  clean_downloads
}

stop_world() {
  echo "Stopping world"

  docker compose down
}

help_menu() {
  echo "Usage: $0 [options]"
  echo
  echo "Options:"
  echo "  -s          Stop server and save world (commit)"
  echo "  -n          Create new world (branch)"
  echo "  -S          Save current world (commit)"
  echo "  -C          Clean world to last save (commit)"
  echo "  -h          Show help"
  echo
  echo "If no options are provided, the server will start."
}

# POSIX argument parsing
while [ $# -gt 0 ]; do
  case "$1" in
  -C)
    clean_world
    ;;
  -h)
    help_menu
    exit 0
    ;;
  -n)
    new_world
    ;;
  -S)
    save_world
    exit 0
    ;;
  -s)
    stop_world
    save_world
    exit 0
    ;;
  *)
    echo "Invalid option: $1" >&2
    help_menu
    exit 1
    ;;
  esac
  shift
done

if [ "$(git branch --show-current)" = "main" ]; then
  new_world
else
  save_world
fi

start_server
