#!/usr/bin/env bash
set -Eeu

readonly MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly REGEX="image_name\": \"(.*)\""
readonly JSON=`cat ${MY_DIR}/docker/image_name.json`
[[ ${JSON} =~ ${REGEX} ]]
readonly IMAGE_NAME="${BASH_REMATCH[1]}"

# Written down here so the gate fails when a rebuild picks up a different
# AUnit. Reading it from the image instead would compare the image against
# itself and pass whatever the move brought in.
readonly EXPECTED=25.0

# AUnit has no program to ask, so the installed package is asked instead.
# Matching on the leading major.minor lets a patch release through and stops
# only a minor or major move.
readonly ACTUAL=$(docker run --rm ${IMAGE_NAME} sh -c "dpkg-query --showformat='\${Version}' --show libaunit-dev")

if echo "${ACTUAL}" | grep -q "^${EXPECTED}"; then
  echo "VERSION CONFIRMED as ${EXPECTED}"
else
  echo "VERSION EXPECTED: ${EXPECTED}"
  echo "VERSION   ACTUAL: ${ACTUAL}"
  exit 42
fi
