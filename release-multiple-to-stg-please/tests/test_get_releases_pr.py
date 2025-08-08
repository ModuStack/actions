import unittest
from unittest.mock import patch, MagicMock
import json
import re
from get_releases_pr import (
    is_valid_release_title,
    extract_version_number,
    compare_branches_releases,
    get_pr,
    list_prs_branch,
    get_pre_release_tag
)

class TestGetReleasesPR(unittest.TestCase):

    def test_is_valid_release_title(self):
        self.assertTrue(is_valid_release_title("chore(main): release 1.149.5"))
        self.assertTrue(is_valid_release_title("chore(main): release trading-sdk 1.14.1"))
        self.assertFalse(is_valid_release_title("feat(main): new feature"))

    def test_extract_version_number(self):
        self.assertEqual(extract_version_number("chore(main): release 1.149.5"), "1.149.5")
        self.assertEqual(extract_version_number("chore(main): release 2.3"), "2.3")
        self.assertIsNone(extract_version_number("chore(main): release"))
        self.assertIsNone(extract_version_number("feat(main): new feature"))

    def test_compare_branches_releases(self):
        release_branches = ["release-please--branches--main"]
        branch_input = ["release-please--branches--main"]
        self.assertTrue(compare_branches_releases(release_branches, branch_input))

        release_branches = ["release-please--branches--main--components--trading-sdk"]
        branch_input = ["release-please--branches--main--components--trading-sdk"]
        self.assertTrue(compare_branches_releases(release_branches, branch_input))

        release_branches = ["release-please--branches--main"]
        branch_input = ["release-please--branches--main--components--trading-sdk"]
        self.assertFalse(compare_branches_releases(release_branches, branch_input))


    @patch('get_releases_pr.g.get_repo')
    def test_list_prs_branch(self, mock_get_repo):
        repo_mock = MagicMock()
        pr_mock = MagicMock()

        # Set the value of head.ref for the PR mock
        pr_mock.head.ref = "release-please--branches--main"

        label_mock = MagicMock()
        label_mock.name = "autorelease: pending"

        # set list of labels for the PR mock
        pr_mock.labels = [label_mock]

        repo_mock.get_pulls.return_value = [pr_mock]

        mock_get_repo.return_value = repo_mock

        prs = list_prs_branch("release-please--branches--main", repo_mock.get_pulls(), "autorelease: pending")

        self.assertEqual(len(prs), 1)
        self.assertEqual(prs[0], pr_mock)


        pr_mock_2 = MagicMock()
        # Set the value of head.ref for the PR mock
        pr_mock_2.head.ref = "release-please--branches--main--trading-sdk"

        label_mock_2 = MagicMock()
        label_mock_2.name = "autorelease: pending"

        # set list of labels for the PR mock
        pr_mock_2.labels = [label_mock]
        repo_mock.get_pulls.return_value = [pr_mock, pr_mock_2]
        mock_get_repo.return_value = repo_mock
        prs_2 = list_prs_branch("release-please--branches--main--trading-sdk", repo_mock.get_pulls(), "autorelease: pending")

        self.assertEqual(len(prs_2), 1)
        self.assertEqual(prs_2[0], pr_mock_2)


    @patch('get_releases_pr.g.get_repo')
    def test_get_pr(self, mock_get_repo):
        repo_mock = MagicMock()
        pr_mock = MagicMock()
        pr_mock.head.ref = "release-please--branches--main"
        label_mock = MagicMock()
        label_mock.name = "autorelease: pending"
        pr_mock.labels = [label_mock]
        repo_mock.get_pulls.return_value = [pr_mock]
        mock_get_repo.return_value = repo_mock

        result = get_pr("release-please--branches--main", repo_mock.get_pulls(), "autorelease: pending")
        self.assertEqual(result, pr_mock)


    def test_get_pre_release_tag(self):
        pr_mock = MagicMock()
        pr_mock.title = "chore(main): release 1.149.5"
        self.assertEqual(get_pre_release_tag(pr_mock), "1.149.5")

        pr_mock.title = "chore(main): release"
        self.assertIsNone(get_pre_release_tag(pr_mock))


if __name__ == "__main__":
    unittest.main()
