#!/bin/bash

# fetch newest upstream source code
./jiri update

DIR_LIST="$(find repos -maxdepth 1 -type d)"
DIR_LIST="${DIR_LIST//repos/}"  # remove 'repos' string
DIR_ARRAY=(${DIR_LIST//\//})    # remove slash char.

cd repos

for dir in "${DIR_ARRAY[@]}"; do
  echo "syncing project [${dir}]..."
  cd ${dir}
  if [[ -z "$(git remote |grep otg)" ]]; then
    git remote add otg ssh://review.gerrithub.io:29418/OpenTrustGroup/${dir} || exit 1
  fi
  git fetch otg || exit 1
  git push otg HEAD:master || exit 1
  cd ..
  echo "done"
done
