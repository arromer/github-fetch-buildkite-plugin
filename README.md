# github-fetch-buildkite-plugin

A [Buildkite](https://buildkite.com) plugin to fetch a branch from GitHub.

## Buildkite Agent Requirements

- [Git](https://git-scm.com/)
- [AWS CLI](https://aws.amazon.com/cli/) (only if `BUILDKITE_PLUGIN_GITHUB_FETCH_S3_URL` is provided)

## Configurations

The plugin accepts the following environment variables to configure its behaviour:

- `BUILDKITE_PLUGIN_GITHUB_FETCH_S3_URL`
    - Required: No
    - Description: An S3 URL (e.g. `s3://<bucket>/<key>`) pointing to a "directory" in S3 which contains
        snapshots of the GitHub repository to checkout. The snapshots must be in `tar.gz` format and use the following
        naming convention: `YYYYMMDD_HHmmss.tar.gz`.

    **Note**: If this parameter is not specified the branch will be always checked out from the repository in GitHub.

- `BUILDKITE_PLUGIN_GITHUB_FETCH_GIT_REMOTE_TIMEOUT`
    - Required: No
    - Default: 0 (no timeout)
    - Description: The maximum amount of time for Git remote operations (`push` `pull` `fetch`) to complete.

- `BUILDKITE_PLUGIN_GITHUB_FETCH_GIT_REMOTE_TIMEOUT_EXIT_CODE`:
    - Required: No
    - Default: 110
    - Description: The exit code returned by the Buildkite step if any Git remote operation times out.

    **Note**: This parameter has no effect if `BUILDKITE_PLUGIN_GITHUB_FETCH_GIT_REMOTE_TIMEOUT` is undefined or
    set to `0`.

## Exit Codes

| Exit Code        | Description
| ----------- |:-------------------------------------------------------------:
| 116         | The target Git branch does not contain the specified commit.
