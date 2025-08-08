#!/usr/bin/env bash
bats_require_minimum_version 1.5.0

setup() {
    load '../../test/common-setup'
    export GITHUB_OUTPUT="$(mktemp)"

    echo "foo=bar" > "${GITHUB_OUTPUT}"

    _common_setup
}

teardown() {
    unstub gh
    rm -f "${GITHUB_OUTPUT}"
}

@test "Outputs the release PR - matching release-please output - and the pre-release tag" {
    json='[{"baseBranchName":"main","files":[],"headBranchName":"release-please--branches--main","labels":["autorelease: pending"],"number":118,"title":"chore(main): release 1.0.0","body":"PR body"}]'
    stub gh "echo '${json}'"

    run get-release-pr.sh

    expected_pr_output='{"headBranchName":"release-please--branches--main","baseBranchName":"main","number":118,"title":"chore(main): release 1.0.0","body":"PR body","files":[],"labels":["autorelease: pending"]}'
    expected_pr_output=$(echo "${expected_pr_output}" | jq --sort-keys --compact-output '.')

    extra_output=$(head -n 1 "${GITHUB_OUTPUT}")
    actual_pr_output=$(head -n 2 "${GITHUB_OUTPUT}" | tail -n1 | cut -d= -f2 | jq --sort-keys --compact-output '.')
    pre_release_tag=$(tail -n 1 "${GITHUB_OUTPUT}" | cut -d= -f2)

    assert [ "${extra_output}" = "foo=bar" ] # Ensure other outputs are not lost
    assert [ "${expected_pr_output}" = "${actual_pr_output}" ]
    assert [ "${pre_release_tag}" = "1.0.0" ]
    assert_output --partial "pre_release_tag=1.0.0"
}

@test "Empty output when no open release PR is found" {
    stub gh "echo '[]'"

    run --separate-stderr get-release-pr.sh

    initial_output=$(head -n 1 "${GITHUB_OUTPUT}")
    assert [ "${initial_output}" = "foo=bar" ] # Ensure other outputs are not lost
    assert [ "$stderr" = "No PR found with the label 'autorelease: pending'." ]
}

@test 'Errors out if more than one PR is found with the label' {
    pr_1='{ "number": 1, "title": "chore(main): release 1.0.0", "labels": [{"name": "autorelease: pending"}] }'
    pr_2='{ "number": 2, "title": "chore(main): release 1.0.1", "labels": [{"name": "autorelease: pending"}] }'
    json="[${pr_1}, ${pr_2}]"
    stub gh "echo '${json}'"

    run -1 get-release-pr.sh

    initial_output=$(head -n 1 "${GITHUB_OUTPUT}")
    assert [ "${initial_output}" = "foo=bar" ] # Ensure other outputs are not lost
    assert_output "More than one PR found with the label 'autorelease: pending'. MUST be unique."
}
