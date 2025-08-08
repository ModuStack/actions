#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

readonly release_pr_label="${RELEASE_PR_LABEL:-"autorelease: pending"}"
readonly title_prefix="${RELEASE_PR_TITLE_PREFIX:-"chore(main): release "}"
readonly pr_state="${RELEASE_PR_STATE:-"open"}"

main() {
    local prs=$(list_prs)
    local length="$(echo $prs | jq length)"

    if [ "${length}" -gt 1 ]; then
        echo "More than one PR found with the label '${release_pr_label}'. MUST be unique." >&2
        return 1
    fi

    if [ "${length}" -eq 0 ]; then
        echo "No PR found with the label '${release_pr_label}'." >&2
        echo ''
        return 0
    fi

    local pr="$(echo "${prs}" | jq --compact-output ".[0]")"
    local pre_release_tag=$(echo "${prs}" | jq --raw-output ".[0] | .title | ltrimstr(\"${title_prefix}\")")

    echo "pr=${pr}" | tee -a "${GITHUB_OUTPUT}"
    echo "pre_release_tag=${pre_release_tag}" | tee -a "${GITHUB_OUTPUT}"
}

list_prs() {
    PAGER= gh pr list \
        --state="${pr_state}" \
        --json headRefName,baseRefName,number,title,body,files,labels \
        --jq "map(select(.labels[].name==\"${release_pr_label}\")) | map_values({headBranchName: .headRefName, baseBranchName: .baseRefName, number, title, body, files, labels: [.labels[].name]})"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
