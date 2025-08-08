#!/usr/bin/env bash

set -o errexit
set -o pipefail

function main() {
    echo "$CHANGES" | while IFS= read -r change ; do
        if [[ -z "$change" ]]; then
            continue
        fi

        app="$(echo "$change" | cut -d, -f1 | tr -d ' ')"
        changed="$(echo "$change" | cut -d, -f2 | tr -d ' ')"
        version="$(echo "$change" | cut -d, -f3 | tr -d ' ')"
        sentry_version="$(echo "$change" | cut -d, -f4 | tr -d ' ')"

        echo "Application(app='$app', changed=$changed, version='$version', sentry_version='$sentry_version')"

        if [ "${changed}" != 'true' ]; then
            continue
        fi

        kustomize edit set image "${app}=*:${version}"

        if [ -z "${sentry_version}" ]; then
            continue
        fi

        configmap_name=$(echo ${sentry_version%%=*} | tr -d ' ')
        sentry_version=$(echo ${sentry_version#*=} | tr -d ' ')

        if [[ "${configmap_name}" == "${sentry_version}" ]]; then
            configmap_name="${app}"
        fi

        kustomize edit add configmap ${configmap_name} --from-literal=${SENTRY_VERSION_ENVVAR}=${sentry_version} 2> /dev/null || true
        kustomize edit set configmap ${configmap_name} --from-literal=${SENTRY_VERSION_ENVVAR}=${sentry_version}
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi