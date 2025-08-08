#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

main() {
    local tag="$(git tag --points-at HEAD | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)"

    if [ -z "${tag}" ]; then
        echo "No tag found at HEAD." >&2
        exit 1
    fi

    local version="${tag#v}"
    local major="$(echo "${version}" | cut -d. -f1)"
    local minor="$(echo "${version}" | cut -d. -f2)"
    local patch="$(echo "${version}" | cut -d. -f3)"

    echo "tag_name=${tag}" | tee -a "${GITHUB_OUTPUT}"
    echo "version=${version}" | tee -a "${GITHUB_OUTPUT}"
    echo "major=${major}" | tee -a "${GITHUB_OUTPUT}"
    echo "minor=${minor}" | tee -a "${GITHUB_OUTPUT}"
    echo "patch=${patch}" | tee -a "${GITHUB_OUTPUT}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
