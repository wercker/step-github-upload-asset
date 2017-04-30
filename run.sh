
upload_asset() {
  set -e;

  local token="$1";
  local owner="$2";
  local repo="$3";
  local name="$4";
  local content_type="$5";
  local file="$6";
  local id="$7";

  curl --fail -s -S -X POST https://uploads.github.com/repos/$owner/$repo/releases/$id/assets?name=$name \
    -A "wercker-upload-asset" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token $token" \
    -H "Content-Type: $content_type" \
    --data-binary @"$file";
}

export_id_to_env_var() {
  set -e;

  local json="$1";
  local export_name="$2";

  if [ -f "/etc/alpine-release" ]; then
    JQ="$WERCKER_STEP_ROOT/bin/jq-alpine"
  else
    JQ="$WERCKER_STEP_ROOT/bin/jq"
  fi

  local id=$(echo "$json" | $JQ ".id");

  info "exporting asset id ($id) to environment variable: \$$export_name";

  export $export_name=$id;
}

main() {
  set -e;

  # Assign global variables to local variables
  local token="$WERCKER_GITHUB_UPLOAD_ASSET_TOKEN";
  local file="$WERCKER_GITHUB_UPLOAD_ASSET_FILE";
  local name="$WERCKER_GITHUB_UPLOAD_ASSET_FILENAME";
  local owner="$WERCKER_GITHUB_UPLOAD_ASSET_OWNER";
  local repo="$WERCKER_GITHUB_UPLOAD_ASSET_REPO";
  local content_type="$WERCKER_GITHUB_UPLOAD_ASSET_CONTENT_TYPE";
  local release_id="$WERCKER_GITHUB_UPLOAD_ASSET_RELEASE_ID";
  local export_id="$WERCKER_GITHUB_UPLOAD_ASSET_EXPORT_ID";

  # Validate variables
  if [ -z "$token" ]; then
    fail "Token not specified; please add a token parameter to the step";
  fi

  if [ -z "$file" ]; then
    fail "File parameter not specified; please add a file parameter to the step";
  fi

  if [ ! -f "$file" ]; then
    fail "The file does not exists; $file";
  fi

  # Set variables to defaults if not set by the user
  if [ -z "$name" ]; then
    name=$(basename "$file")
    info "no name was supplied; using basename of \$file: $name";
  fi

  if [ -z "$owner" ]; then
    owner="$WERCKER_GIT_OWNER";
    info "no GitHub owner was supplied; using GitHub owner of build repository: $owner";
  fi

  if [ -z "$repo" ]; then
    repo="$WERCKER_GIT_REPOSITORY";
    info "no GitHub repository was supplied; using GitHub repository of build: $repo";
  fi

  if [ -z "$content_type" ]; then
    content_type=$(file --mime-type -b "$file");
    info "no content-type was supplied, using 'file' to get the content-type: $content_type";
  fi

  if [ -z "$release_id" ]; then
    release_id="$WERCKER_GITHUB_CREATE_RELEASE_ID";
    info "no release id was supplied, using release id from \$WERCKER_GITHUB_CREATE_RELEASE_ID: $release_id";
  fi

  if [ -z "$export_id" ]; then
    export_id="WERCKER_GITHUB_UPLOAD_ASSET_ID";
    info "no export id was supplied, using default value: $export_id";
  fi

  info "starting upload of asset $file to GitHub repo $owner/$repo with release $release_id";

  # Upload asset and save the output from curl
  UPLOAD_RESPONSE=$(upload_asset \
    "$token" \
    "$owner" \
    "$repo" \
    "$name" \
    "$content_type" \
    "$file" \
    "$release_id");

  info "finished upload of asset $file to GitHub repo $owner/$repo with release $release_id";

  export_id_to_env_var "$UPLOAD_RESPONSE" "$export_id";

  info "successfully uploaded asset to GitHub";
}

# Run the main function
main;
