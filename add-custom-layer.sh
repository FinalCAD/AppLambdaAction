#!/usr/bin/env bash
set -o pipefail

basedir="$(dirname "$(readlink -f "${BASH_SOURCE}")")" || {
  echo '[ERROR] Unable to resolve script directory'
  return 1
} >&2

. "${basedir}/common.shrc" || {
  echo '[ERROR] Unable to load common'
  return 1
} >&2

function main() {
  local rc=0

  common.check.bin pip3 || rc=$?
  [[ $rc == 0 ]] || return $rc

  pip3 install virtualenv || {
    echo '[ERROR] Unable to install virtualenv'
    return 1
  } >&2

  echo "[INFO ] Preparing archive..."
  local archive_dir="./lambda"
  [[ -z "${APPLAMBDAACTION_SUB_PATH}" ]] || archive_dir="${archive_dir}/${APPLAMBDAACTION_SUB_PATH}"
  local archive_script="${archive_dir}/prepare_archive.sh"
  common.check.exe "${archive_script}" &&
  "${archive_script}" &&
  true || {
    echo "[ERROR] Unable to prepare Lambda archive"
    return 1
  } >&2

  local zip_fullpath="$(readlink -f "${archive_dir}/function.zip")"
  [[ -f "${zip_fullpath}" ]] || {
    echo "[ERROR] Missing archive file '${zip_fullpath}'"
    return 1
  } >&2

  [[ "${APPLAMBDAACTION_INJECT_ROUTE_FILES}" != 'true' ]] || {
    echo "[INFO ] Injecting route files..."
    local zip_fullpath="$(readlink -f "${archive_dir}/function.zip")"
    [[ -f "${zip_fullpath}" ]] || {
      echo "[ERROR] Missing archive file '${zip_fullpath}'"
      exit 1
    } >&2
    local route_dir="$(mktemp --directory)" &&
    "${basedir}/fetch-routes.sh" "${route_dir}" &&
    pushd "${route_dir}" &&
    zip -ru "${zip_fullpath}" . &&
    popd &&
    true || {
      echo "[ERROR] Unable to inject route files"
      return 1
    } >&2

    [[ "${APPLAMBDAACTION_DRY_RUN}" == 'false' ]] || {
      unzip -l "${zip_fullpath}"
    }
  }

  echo "[INFO ] Copying archive file '${zip_fullpath}' to Terraform project..."
  mkdir -p ./terragrunt/modules/custom/lambda_prerequisite/ &&
  cp "${zip_fullpath}" './terragrunt/modules/custom/lambda_prerequisite/.' &&
  true
}

main "$@"
