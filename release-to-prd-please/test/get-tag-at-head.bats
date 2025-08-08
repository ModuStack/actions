#!/usr/bin/env bash
bats_require_minimum_version 1.5.0

setup() {
    load '../../test/common-setup'
    _common_setup

    export GITHUB_OUTPUT="$(mktemp)"
    readonly repository="$(mktemp -d)"
    cd "${repository}"
    git init --initial-branch=main
    git config --local user.name "Test User"
    git config --local user.email "test@example.com"
    echo 'Some changes' > file.txt
    git add file.txt
    git commit -m "Initial commit"
    echo 'More changes' >> file.txt
    git add file.txt
    git commit -m "Second commit"
    # Create a tag at HEAD
    git tag v1.0.0
}

teardown() {
    rm -f "${GITHUB_OUTPUT}"
    rm -rf "${repository}"
}

@test "Outputs the tag at HEAD" {
    run get-tag-at-head.sh

    expected_tag=v1.0.0
    actual_tag=$(head -n 1 "${GITHUB_OUTPUT}" | cut -d= -f2)

    assert_success
    assert [ "${actual_tag}" = "${expected_tag}" ]
    assert_output --partial "tag_name=${expected_tag}"
    assert_output --partial "version=1.0.0"
    assert_output --partial "major=1"
    assert_output --partial "minor=0"
    assert_output --partial "patch=0"
}

@test "Works fine with more than one tag at HEAD" {
    git tag "v1.0.1"
    git tag "v1.0.2"

    run get-tag-at-head.sh

    expected_tag=v1.0.0
    actual_tag=$(head -n 1 "${GITHUB_OUTPUT}" | cut -d= -f2)

    assert_success
    assert [ "${actual_tag}" = "${expected_tag}" ]
    assert_output --partial "tag_name=${expected_tag}"
    assert_output --partial "version=1.0.0"
    assert_output --partial "major=1"
    assert_output --partial "minor=0"
    assert_output --partial "patch=0"
}

@test "Gets the tag at HEAD with format vx.x.x in case more than one" {
    git tag -d v1.0.0
    git tag v1
    git tag v1.0
    git tag v1.0.0

    run get-tag-at-head.sh
    assert_success
    assert_output --partial "tag_name=v1.0.0"
    assert_output --partial "version=1.0.0"
    assert_output --partial "major=1"
    assert_output --partial "minor=0"
    assert_output --partial "patch=0"
}

@test "Errors if no tag at HEAD" {
    git reset --hard HEAD^

    run -1 get-tag-at-head.sh
}

@test "Errors if no tag at HEAD with the format vx.x.x" {
    git reset --hard HEAD^
    git tag -d v1.0.0
    git tag v1
    git tag v1.0

    run -1 get-tag-at-head.sh
}
