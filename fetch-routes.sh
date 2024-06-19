#!/usr/bin/env bash
set -o pipefail

basedir="$(dirname "$(readlink -f "${BASH_SOURCE}")")" || {
  echo 'Unable to resolve script directory'
  return 1
} >&2

. "${basedir}/common.shrc" || {
  echo 'Unable to load common'
  return 1
} >&2


function main() {
  local rc=0

  local target_dir="$1"; shift
  [[ ! -z "${target_dir}" ]] || {
    echo "[ERROR] Missing parameter 'target_dir'"
    rc=1
  } >&2

  common.check.var ENVIRONMENT REGION || rc=$?
  common.check.bin aws jq base64 || rc=$?

  [[ $rc == 0 ]] || return $rc

  local secret_short=''
  for secret_short in routes routes-ext; do
    echo
    local secret_id="terraform/${ENVIRONMENT}/${REGION}/${secret_short}" &&
    local basename="${secret_short}.json" &&
    local target_file="${target_dir}/secrets/${basename}"

    mkdir --parents "$(dirname "${target_file}")" || {
      echo "[ERROR] Unable to create parent directory of '${target_file}'"
      rc=1
      continue
    } >&2

    echo "[INFO ] Generating ${target_file}" &&
    aws secretsmanager get-secret-value --secret-id "${secret_id}" --output json \
    | jq -r '.SecretString' \
    | jq -r --arg 'basename' "${basename}" '.[$basename] // ""' \
    | base64 --decode >"${target_file}" \
    || {
      echo "[ERROR] Unable to get AWS Secret"
      rc=1
    } >&2
  done

  return $rc
}

main "$@"
