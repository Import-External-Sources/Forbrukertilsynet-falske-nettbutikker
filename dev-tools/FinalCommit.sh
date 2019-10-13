#!/bin/bash
# Hosts file generator for Badd Boyz Hosts
# Created by: Mitchell Krog (mitchellkrog@gmail.com)
# Copyright: Mitchell Krog - https://github.com/mitchellkrogza
# Repo Url: https://github.com/mitchellkrogza/Badd-Boyz-Hosts
# MIT License

# ***********************************************************
# Remove our inactive and invalid domains from PULL_REQUESTS
# ***********************************************************

cat ${TRAVIS_BUILD_DIR}/dev-tools/output/domains/ACTIVE/list | grep -v "^$" | grep -v "^#" > tempdomains.txt
mv tempdomains.txt ${TRAVIS_BUILD_DIR}/PULL_REQUESTS/domains.txt

# ***************************************************************************
# Generate our host file and update README with build and version information
# ***************************************************************************

bash ${TRAVIS_BUILD_DIR}/dev-tools/UpdateReadme.sh
bash ${TRAVIS_BUILD_DIR}/dev-tools/GenerateHostsFile.sh

# *************************************************************
# Travis now moves to the before_deploy: section of .travis.yml
# *************************************************************

exit ${?}
