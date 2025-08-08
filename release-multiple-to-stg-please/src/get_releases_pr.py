#!/usr/bin/env python3

import argparse
import json
import os
import re
import sys
from github import Github, BadCredentialsException, GithubException




GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")

if GITHUB_TOKEN is None:
    print("Error: GITHUB_TOKEN is not set")
    exit(1)
try:
    g = Github(GITHUB_TOKEN)
except BadCredentialsException:
    print("Error: Access token is invalid. Please check your GITHUB_TOKEN.")
    exit(1)
except Exception as e:
    print(f"An unexpected error occurred: {e}")
    exit(1)


def main(repo_name, release_pr_label, release, branches_input):

    try:
        repo = g.get_repo(repo_name)
    except GithubException as e:
        if e.status == 404:
            print(f"Error: Repository '{repo_name}' not found.")
        elif e.status == 403:
            print(f"Error: API forbidden. Check your GITHUB_TOKEN.")
        else:
            print(f"Error accessing the GitHub API: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


    except GithubException as e:
        print(f"Error retrieving repository {repo_name}: {e}", file=sys.stderr)
        return
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        return





    open_prs = repo.get_pulls(state='open')
    map_pr = {}
    map_pre_release_tag = {}
    for key, branch in branches_input.items():
        pr = get_pr(branch, open_prs, release_pr_label)
        if pr:
            dict_value = {}
            dict_value["number"] = str(pr.number)
            map_pr[key] = dict_value

            pre_release_tag = get_pre_release_tag(pr)
            if pre_release_tag:
              map_pre_release_tag[key] = pre_release_tag

    map_return = {
        "pr": map_pr,
        "pre_release_tag": map_pre_release_tag
    }

    return map_return








# test created
def list_prs_branch(head_ref_name, open_prs, release_pr_label):
    filtered_pulls = [pr for pr in open_prs if release_pr_label in [label.name for label in pr.labels] and pr.head.ref == head_ref_name]
    return filtered_pulls

# test created
def get_pr(head_ref_name, open_prs, release_pr_label):
    prs = list_prs_branch(head_ref_name, open_prs, release_pr_label)
    if prs:
        return prs[0]
    else:
        return None

# test created
def is_valid_release_title(pr_title):
    pattern = r'^chore\(main\): release .*(\d+\.\d+\.\d+)$'
    return re.match(pattern, pr_title) is not None

# test created
def extract_version_number(pr_title):
    match = re.search(r'(\d+\.\d+\.\d+|\d+\.\d+)$', pr_title)
    return match.group(1) if match else None

# test created
def get_pre_release_tag(pr):
    pr_title=pr.title
    if is_valid_release_title(pr_title):
        return extract_version_number(pr_title)
    else:
        return None


# test created
def compare_branches_releases(release_branches, branches_input):

    for branch in branches_input:
        if branch not in release_branches:
            print(f"ERROR: The branch '{branch}' is not present in 'release.prs'. The input branch is incorrect.")
            return False

    for branch in release_branches:
        if branch not in branches_input:
            print(f"ERROR: The branch '{branch}' is not present in head_branches_input. The input branch is incorrect and the release creates another branch.")
            return False
    return True

def parse_json(json_string):
    try:
        return json.loads(json_string)
    except json.JSONDecodeError as e:
        print(f"Error: The input JSON is malformed: {e.msg}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="get the pull request ready for release")
    parser.add_argument("--repo", type=str, required=True, help="name of the repo format <org>/<repo>")
    parser.add_argument("--release-pr-label", type=str, default="autorelease: pending", help="Label for the release pull request")
    parser.add_argument("--release", type=str, help="release json for the release pull request")
    parser.add_argument("--branches", type=str, help="json list of branches")

    args = parser.parse_args()

    branches = parse_json(args.branches)
    release  = parse_json(args.release)


    pr_map = main(args.repo, args.release_pr_label, release, branches)
    pr_map_str = json.dumps(pr_map).replace('"', '\\"')
    print(f"pr_map='{pr_map_str}'")



    with open(os.getenv('GITHUB_OUTPUT'), 'a') as github_output:
        print(f"pr_map='{json.dumps(pr_map)}'", file=github_output)
