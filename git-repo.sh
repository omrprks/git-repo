#!/usr/bin/env sh

function log {
  local message="${@}"
  echo "git-repo: ${message}"
}

function error {
  local message="${@}"
  echo "\033[1;31m$(log ${message})\033[0m"
}

function fatal {
  local message="${@}"
  error ${message}
  exit 1
}

function start {
  local url="${@}"

  [[ "${OSTYPE}" == "darwin"* ]] && {
    open "${url}"
    return
  }

  xdg-open "${url}"
}

BASE=${1:-origin}

command -v git >/dev/null 2>&1
[[ ! "$?" == "0" ]] && {
  fatal git not found
}

[[ ! -d "$(pwd)/.git" ]] && {
  fatal not a git repository
}

remote=$(git ls-remote --get-url ${BASE})

http_match="^https?://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]"
[[ "${remote}" =~ ${http_match} ]] && {
  start "${remote}"
  exit 0
}

ssh_match="^git@[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]"
[[ "${remote}" =~ ${ssh_match} ]] && {
  host=$(echo "${remote}" | sed -Ene's!git@(github.com|gitlab.com|bitbucket.org):([^/]*)/(.*)(.git?)!\1!p')
  username=$(echo "${remote}" | sed -Ene's!git@(github.com|gitlab.com|bitbucket.org):([^/]*)/(.*)(.git?)!\2!p')
  repository=$(echo "${remote}" | sed -Ene's!git@(github.com|gitlab.com|bitbucket.org):([^/]*)/(.*)(.git?)!\3!p')

  start https://"${host}"/"${username}"/"${repository}".git
  exit 0
}

fatal unsupported remote url