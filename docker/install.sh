#!/bin/sh -eu

# AUnit is a library: debian packages it as libaunit-dev, which installs its
# sources and its aunit.gpr project file where gprbuild finds them, so a
# kata's project file can say  with "aunit";  and nothing more.
readonly GNAT_VERSION=$(sed --quiet 's/.*"gnat":"\([0-9.]*\)".*/\1/p' /versions.json)

if [ -z "${GNAT_VERSION}" ]; then
  echo '/versions.json has no gnat property' >&2
  exit 1
fi

apt-get update
apt-get install --yes --no-install-recommends libaunit-dev

# Read by check_version.sh. AUnit has no program to ask for its version, so it
# comes from the package database, which records what is actually installed
# rather than what the index offers. The debian revision after the - is
# dropped.
readonly AUNIT_VERSION=$(dpkg-query --showformat='${Version}' --show libaunit-dev | sed 's/-.*//')

if [ -z "${AUNIT_VERSION}" ]; then
  echo 'Could not read the installed version of libaunit-dev' >&2
  exit 1
fi

echo "{\"gnat\":\"${GNAT_VERSION}\",\"aunit\":\"${AUNIT_VERSION}\"}" > /versions.json

rm -rf /var/lib/apt/lists/*
