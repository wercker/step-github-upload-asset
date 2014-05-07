# GitHub create release step

A wercker step for adding an asset to a GitHub release. It has a few parameters, but only two are required: `token` and `file`. See [Creating a GitHub token](#creating-a-github-token).

This step will export the id of the asset in an environment variable (default: `$WERCKER_GITHUB_UPLOAD_ASSET_ID`). This allows other steps to use this release.

Currently this step does not do any json escaping. So be careful when using quotes or newlines in parameters.

More information about GitHub releases:

- https://github.com/blog/1547-release-your-software
- https://developer.github.com/v3/repos/releases/

# Example

A minimal example, this will get the token from a environment variable and use the hardcoded `v1.0.0` tag:

``` yaml
deploy:
    steps:
        - github-upload-asset:
            token: $GITHUB_TOKEN
            file: build.tgz
            release_id: 1
```

This step works best when used together with the `github-create-release` step, because you can skip setting the `release_id`:

``` yaml
deploy:
    steps:
        - github-create-release:
            token: $GITHUB_TOKEN
            tag: v1.0.0
        - github-upload-asset:
            token: $GITHUB_TOKEN
            file: build.tgz
```

# Common problems

## curl: (22) The requested URL returned error: 400

GitHub has rejected the call. Most likely invalid json was used. Check to see if any of the parameters need escaping (quotes and new lines).

## curl: (22) The requested URL returned error: 401

The `token` is not valid. If using a protected environment variable, check if the token is inside the environment variable.

## curl: (22) The requested URL returned error: 422

GitHub rejected the API call. Check if the name of the file isn't already in use in this release.

# Creating a GitHub token

To be able to use this step, you will first need to create a GitHub token with an account which has enough permissions to be able to create releases. First goto `Account settings`, then goto `Applications` for the user. Here you can create a token in the `Personal access tokens` section. For a private repository you will need the `repo` scope and for a public repository you will need the `public_repo` scope. Then it is recommended to save this token on wercker as a protected environment variable.

# What's new

- Initial release.

# Options

- `token` The token used to make the requests to GitHub. See [Creating a GitHub token](#creating-a-github-token).
- `file` The path of the file which you want to add to the release.
- `release_id` (optional) The id of a release where this asset should be uploaded to. Defaults to `$WERCKER_GITHUB_CREATE_RELEASE_ID`, which gets set by the `github-create-release` step.
- `owner` (optional) The GitHub owner of the repository. Defaults to `$WERCKER_GIT_OWNER`, which is the GitHub owner of the original build.
- `repo` (optional) The name of the GitHub repository. Defaults to `$WERCKER_GIT_REPOSITORY`, which is the repository of the original build.
- `filename` (optional) The name of the file on GitHub (make sure this is json encoded, see [TODO](#todo))
- `content-type` (optional) The content-type of the file. Defaults to using the `file` command (make sure this is json encoded, see [TODO](#todo))
- `export_id` (optional) After the asset is uploaded, a asset id will be made available in the environment variable identifier in this environment variable. Defaults to `WERCKER_GITHUB_UPLOAD_ASSET_ID`.

# TODO

- Create better error handling for invalid token.
- Escape user input to be valid json.
- Make sure `export_id` contains a valid environment variable identifier.

# License

The MIT License (MIT)

# Changelog

## 1.0.1

- Initial release.
