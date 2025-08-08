# How to call the github action

If you want to deploy on the new repo

```

      - name: Deploy to staging
        uses: modustack/actions/deploy@v8
        with:
          environment: dev
          platform: test-argo
          deploy_ssh_key: ${{ secrets.GITOPS_SSH_KEY }}
          gitlab_known_hosts: ${{ vars.GITLAB_KNOWN_HOSTS }}
          deploy_commit_message: |-
            ${{ github.actor }} deployed test-argo/test-stg@ref=${{ github.ref_name }} from GitHub

            See more on ${{ github.server_url }}/${{ github.repository }}/commit/${{ github.sha }}
          changes: |
            test-argo,true,sha-${{ steps.resolved-sha.outputs.value }}
          gitops_server_url: https://github.com
          gitops_repository: modustack/gitops
          branch: main
          gitops_username: ra-devops-automation
          gitops_email: devops+gh-bot@modustack.com
```

If you want to deploy on the old repo

```

      - name: Deploy to staging
        uses: modustack/actions/deploy@v8
        with:
          environment: dev
          platform: test-argo
          deploy_ssh_key: ${{ secrets.DEPLOY_SSH_KEY }}
          gitlab_known_hosts: ${{ vars.GITLAB_KNOWN_HOSTS }}
          deploy_commit_message: |-
            ${{ github.actor }} deployed test-argo/test-stg@ref=${{ github.ref_name }} from GitHub

            See more on ${{ github.server_url }}/${{ github.repository }}/commit/${{ github.sha }}
          changes: |
            test-argo,true,sha-${{ steps.resolved-sha.outputs.value }}
```
