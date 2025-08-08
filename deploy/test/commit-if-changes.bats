#!/usr/bin/env bash
bats_require_minimum_version 1.5.0

setup() {
    load '../../test/common-setup'
    _common_setup

    export PLATFORM="test-platform"
    export ENVIRONMENT="test-environment"
    export GITOPS_USERNAME="gitops-user"
    export GITOPS_EMAIL="gitops@example.com"
    export COMMIT_MESSAGE="Deploy changes"

    readonly _manifest_folder="manifests/${PLATFORM}/overlays/${ENVIRONMENT}"
    readonly _manifest_file="manifests/${PLATFORM}/overlays/${ENVIRONMENT}/kustomization.yaml"

    # Setup remote (but local) repository
    readonly upstream="$(mktemp -d)"
    cd "${upstream}"
    git init --initial-branch=main
    git config --local user.name "gitops-user"
    git config --local user.email "gitops@example.com"
    mkdir -p "${_manifest_folder}"
    echo 'foo: bar' > "${_manifest_file}"
    git add .
    git commit -m "Initial commit"
    git config --bool core.bare true
    rm -rf *

    # Clone the upstream repository into a temporary folder
    export ARGO_FOLDER="$(mktemp -d)"
    git clone "${upstream}" "${ARGO_FOLDER}"
    cd "${ARGO_FOLDER}"
}

teardown() {
    rm -rf "${upstream}"
    rm -rf "${ARGO_FOLDER}"
}

@test "Commits and pushes changes if there are modified files" {
    mkdir -p "${_manifest_folder}"
    echo "foo: bor" > "${_manifest_file}"

    run commit-if-changed.sh
    assert_success
}

@test "Should fail if there are errors, and the script is called >= 2 times" {
    # Renames the upstream repository to force a push failure
    mv "${upstream}" "${upstream}.bak"

    mkdir -p "${_manifest_folder}"
    echo "foo: bor" > "${_manifest_file}"

    run ! commit-if-changed.sh
    run ! commit-if-changed.sh
    run ! commit-if-changed.sh

    # Restore the upstream repository (it should succeed now)
    mv "${upstream}.bak" "${upstream}"
    run commit-if-changed.sh
    assert_success
}
