#!/bin/sh -eu

# Appends one test framework to the test_frameworks list the base image
# wrote in /versions.json, keeping any entry an earlier image added. Stops
# the build if the list is not found, rather than record nothing.
add_test_framework()
{
  name="${1}"
  version="${2}"
  entry="{\"name\": \"${name}\", \"version\": \"${version}\"}"
  if grep -q '"test_frameworks": \[\]' /versions.json; then
    sed -i "s|\"test_frameworks\": \[\]|\"test_frameworks\": [${entry}]|" /versions.json
  else
    sed -i "/\"test_frameworks\": \[/s|}\]|}, ${entry}]|" /versions.json
  fi
  if ! grep -q -F "${entry}" /versions.json; then
    echo "Could not add ${name} to /versions.json" >&2
    cat /versions.json >&2
    exit 1
  fi
}

# AUnit is a library: debian packages it as libaunit-dev, which installs its
# sources and its aunit.gpr project file where gprbuild finds them, so a
# kata's project file can say  with "aunit";  and nothing more. No version is
# named, so a rebuild installs whatever AUnit debian is shipping by then.
apt-get update
apt-get install --yes --no-install-recommends libaunit-dev

# AUnit has no program to ask for its version, so it comes from the package
# database, which records what is actually installed rather than what the
# index offers. The debian revision after the - is dropped.
readonly AUNIT_VERSION=$(dpkg-query --showformat='${Version}' --show libaunit-dev | sed 's/-.*//')

if [ -z "${AUNIT_VERSION}" ]; then
  echo 'Could not read the installed version of libaunit-dev' >&2
  exit 1
fi

add_test_framework AUnit "${AUNIT_VERSION}"
cat /versions.json

rm -rf /var/lib/apt/lists/*
