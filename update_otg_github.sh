#!/bin/bash

set -e; [[ "${TRACE}" ]] && set -x

branch_sync_list="gzos master"

function update_github_project {
  if [[ -z "$(git remote |grep otg)" ]]; then
    git remote add otg ssh://review.gerrithub.io:29418/OpenTrustGroup/$1
  fi

  if [[ -z "$(git remote |grep github)" ]]; then
    git remote add github git@github.com:OpenTrustGroup/$1
  fi

  git fetch otg
  git fetch github
  
  for b in ${branch_sync_list}; do
    branch_diff=`git diff --name-status github/${b} otg/${b}`
    if [[ ! -z "${branch_diff}" ]]; then
      echo "update branch: ${b}"
      git checkout --detach otg/${b}
      git push -f github HEAD:${b}
    fi
  done
}

DIR_LIST="$(find repos -maxdepth 1 -type d)"
DIR_LIST="${DIR_LIST//repos/}"  # remove 'repos' string
DIR_ARRAY=(${DIR_LIST//\//})    # remove slash char.

cd repos

for dir in "${DIR_ARRAY[@]}"; do
  pushd ${dir} > /dev/null
  echo "update github project [${dir}]..."
  update_github_project ${dir}
  echo "done"
  popd > /dev/null
done
