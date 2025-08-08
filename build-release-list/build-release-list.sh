#!/usr/bin/env bash

main () {
    local result=()
    local services=$(echo "${SERVICES_JSON}" | jq -r '.[]')

    for service in $services; do
        repo="${PLATFORM}/${service}"
        image_exists=$(aws ecr describe-images --repository-name "${repo}" --image-ids imageTag="${TAG}" 2>/dev/null || echo "not found")

        if [[ "$image_exists" != "not found" ]]; then
            result+=("\"${service}\"")
        fi
    done

    json_result="["$(IFS=,; echo "${result[*]}")"]"
    echo "services=${json_result}"
    echo "services=${json_result}" >> "${GITHUB_OUTPUT}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
