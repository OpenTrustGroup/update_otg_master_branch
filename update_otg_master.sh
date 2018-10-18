#!/bin/bash

set -e; [[ "${TRACE}" ]] && set -x

function sync_upstream_branch {
  if [[ "$1" == "linux" ]]; then
    return;
  fi

  if [[ -z "$(git remote |grep otg)" ]]; then
    git remote add otg ssh://review.gerrithub.io:29418/OpenTrustGroup/$1
  fi
  git fetch otg
  git push otg HEAD:master
}

# fetch newest upstream source code
./jiri update
./jiri runp git checkout --detach JIRI_HEAD

DIR_LIST="$(find repos -maxdepth 1 -type d)"
DIR_LIST="${DIR_LIST//repos/}"  # remove 'repos' string
DIR_ARRAY=(${DIR_LIST//\//})    # remove slash char.

cd repos

for dir in "${DIR_ARRAY[@]}"; do
  pushd ${dir} > /dev/null
  echo "syncing project [${dir}]..."
  sync_upstream_branch ${dir}
  echo "done"
  popd > /dev/null
done
