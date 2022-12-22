#!/usr/bin/env bats

load "$BATS_PATH/load.bash"

# sample output of running aws ls
AWS_LS_OUT="2020-03-09 14:00:00 123 20200309_030125.tar.gz
2020-03-09 17:00:00 123 20200309_060111.tar.gz
2020-03-09 23:00:00 123 20200309_120122.tar.gz
2020-03-10 02:00:00 123 20200309_150120.tar.gz
2020-03-10 05:00:00 123 20200309_180213.tar.gz
2020-03-10 08:00:00 123 20200309_210118.tar.gz"

# expected filename obtained from above ls
AWS_NAME="20200309_030125.tar.gz"

# replaces a given program with a function that echos the command
function nuke() {
  program=$1

  eval "function ${program}() { echo ${program} \$@; return 0; }"

  export -f ${program}
}

# unwrap a timeout, just execute the program given to timeout not the timeout
function timeout() {
  timeout=$1
  args=($@)

  eval ${args[@]:1}
}

# when the S3 URL is set
@test "finds latest cached file and copies from s3" {
  export BUILDKITE_PLUGIN_GITHUB_FETCH_S3_URL="s3url"
  export BUILDKITE_REPO="repo_url"
  export BUILDKITE_BRANCH="master"
  export BUILDKITE_COMMIT="HEAD"
  export BUILDKITE_BUILD_CHECKOUT_PATH="checkout/"

  stub aws \
      "s3 ls ${BUILDKITE_PLUGIN_GITHUB_FETCH_S3_URL}/ : echo ${AWS_LS_OUT}"

  stub tar "-zxf /plugin/${AWS_NAME} : echo tar file"

  nuke rm
  nuke mkdir
  nuke grep
  nuke git
  nuke timeout

  run $PWD/hooks/checkout

  assert_output --partial "tar file"
  assert_success
}

# when the S3 URL is not set
@test "clones from the right git repository" {
  export BUILDKITE_REPO="repo_url"
  export BUILDKITE_BRANCH="master"
  export BUILDKITE_COMMIT="HEAD"
  export BUILDKITE_BUILD_CHECKOUT_PATH="checkout/"

  nuke rm
  nuke mkdir
  nuke grep
  nuke git
  export -f timeout

  run $PWD/hooks/checkout

  assert_output --partial "git clone ${BUILDKITE_REPO}"
  assert_success
}