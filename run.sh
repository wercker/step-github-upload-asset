set -e;

upload_asset() {
  local token="$1";
  local owner="$2";
  local repo="$3";
  local name="$4";
  local content_type="$5";
  local file="$6";

  curl --fail -X POST https://uploads.github.com/repos/$owner/$repo/releases/$id/assets?name=$name \
    -A "wercker-create-release" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token $token" \
    -H "Content-Type: $content_type" \
    --data-binary "@$file";
}

export_id_to_env_var() {
  local json="$1";
  local export_name="$2";

  local id=$(echo "$json" | $WERCKER_STEP_ROOT/bin/jq ".id");

  export $export_name=$id;
}

main() {

  # Assign global variables to local variables
  local token="$WERCKER_GITHUB_UPLOAD_ASSET_TOKEN";
  local file="$WERCKER_GITHUB_UPLOAD_ASSET_FILE";
  local name="$WERCKER_GITHUB_UPLOAD_ASSET_NAME";
  local owner="$WERCKER_GITHUB_UPLOAD_ASSET_OWNER";
  local repo="$WERCKER_GITHUB_UPLOAD_ASSET_REPO";
  local content_type="$WERCKER_GITHUB_UPLOAD_ASSET_CONTENT_TYPE";
  local release_id="$WERCKER_GITHUB_UPLOAD_ASSET_RELEASE_ID";
  local export_id="$WERCKER_GITHUB_UPLOAD_ASSET_EXPORT_ID";

  # Validate variables
  if [ -z "$token" ]; then
    error "Token not specified; please add a token parameter to the step";
  fi

  if [ -z "$file" ]; then
    error "File parameter not specified; please add a file parameter to the step";
  fi

  if [ -f "$file" ]; then
    error "The file does not exists; $file";
  fi

  # Set variables to defaults if not set by the user
  if [ -z "$name" ]; then
    name=$(basename "$file")
  fi

  if [ -z "$owner" ]; then
    owner="$WERCKER_GIT_OWNER";
  fi

  if [ -z "$repo" ]; then
    repo="$WERCKER_GIT_REPOSITORY";
  fi

  if [ -z "$content_type" ]; then
    content_type=$(file --mime-type -b "$file");
    info "no content-type was given, used 'file' to get the content-type: $content_type";
  fi

  if [ -z "$release_id" ]; then
    release_id="$WERCKER_GITHUB_CREATE_RELEASE_ID";
  fi

  if [ -z "$export_id" ]; then
    export_id="WERCKER_GITHUB_UPLOAD_ASSET_ID";
  fi

  # We need jq to parse the result,
  # but we want to install it before doing anything
  install_jq;

  # Create the release and save the output from curl
  local RELEASE_RESPONSE=$(upload_asset \
    "token"
    "owner"
    "repo"
    "name"
    "content_type"
    "file");

  export_id_to_env_var "$RELEASE_RESPONSE" "$export_id";
}

# Run the main function
main;