#!/usr/bin/env bash

set -eu
set -o pipefail

REPO_DIR=$(git rev-parse --show-toplevel)
TEST_ROOT=$(eval echo "~/temp/tests")
FOLDER1="${TEST_ROOT}/_temp_test/folder1"
FOLDER2="${TEST_ROOT}/_temp_test/folder2"
FOLDER3="${TEST_ROOT}/_temp_test/folder3"

setup_test_repo() {
    if [[ ! -d "${TEST_ROOT}" ]]; then
        mkdir -p "${TEST_ROOT}"
    fi

    cd "${TEST_ROOT}"
    git init --bare _temp_test.git
    git clone _temp_test.git/ _temp_test
    cd _temp_test
    touch dummy
    git add dummy
    git commit -m "master commit"
    git checkout -b test_branch
    cd "${TEST_ROOT}/_temp_test"

    # set up folder1 - empty
    mkdir -p "${FOLDER1}"
    echo "*.jpg filter=lfs diff=lfs merge=lfs -text" > "${FOLDER1}/.gitattributes"

    # set up folder2 - wrong lfs pointer
    mkdir -p "${FOLDER2}"
    echo "TEST2 CONTENT" > "${FOLDER2}/testfile2"
    cp "${REPO_DIR}/tests/dummy.jpg" "${FOLDER2}"
    git add "${FOLDER2}/testfile2"
    git add "${FOLDER2}/dummy.jpg"
    git commit -m "test folder2"
    echo "*.jpg filter=lfs diff=lfs merge=lfs -text" > "${FOLDER2}/.gitattributes"
    git add "${FOLDER2}/.gitattributes"
    git commit -m "add attribute file"

    # set up folder3 - right lfs pointer
    mkdir -p "${FOLDER3}"
    echo "TEST3 CONTENT" > "${FOLDER3}/testfile3"
    cp "${REPO_DIR}/tests/dummy.jpg" "${FOLDER3}"
    git add "${FOLDER3}/testfile3"
    git commit -m "test folder3"
    echo "*.jpg filter=lfs diff=lfs merge=lfs -text" > "${FOLDER3}/.gitattributes"
    git add "${FOLDER3}/.gitattributes"
    git add "${FOLDER3}/dummy.jpg"
    git commit -m "add attribute file and jpg"

    git push origin master
}

test() {
    ${REPO_DIR}/hooks/post-checkout "${TEST_ROOT}/_temp_test"
}

main() {
    EXPECTED_RESULT="folder2/dummy.jpg"
    setup_test_repo

    if [[ "$(test)" != "${EXPECTED_RESULT}" ]]; then
        rm -rf "${TEST_ROOT}"
        exit 1
    fi

    rm -rf "${TEST_ROOT}"
}

main 