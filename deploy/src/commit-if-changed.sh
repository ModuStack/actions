#!/usr/bin/env bash

readonly argo_folder="${ARGO_FOLDER}"
readonly platform="${PLATFORM}"
readonly environment="${ENVIRONMENT}"
readonly gitops_username="${GITOPS_USERNAME}"
readonly gitops_email="${GITOPS_EMAIL}"
readonly deploy_commit_message="${COMMIT_MESSAGE}"

main() {
    cd "${argo_folder}/manifests/${platform}/overlays/${environment}"

    if ! git diff --quiet HEAD || ! git diff --quiet HEAD origin ; then
        echo 'Changes detected, committing and pushing...'
        git config --local user.name "${gitops_username}"
        git config --local user.email "${gitops_email}"
        git add .
        git status
        git commit -m "${deploy_commit_message}"
        git push
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
