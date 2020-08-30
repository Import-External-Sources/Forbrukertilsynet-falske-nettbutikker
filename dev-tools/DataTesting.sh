#!/bin/bash
# **********************
# Run PyFunceble Testing
# **********************
# Created by: Mitchell Krog (mitchellkrog@gmail.com)
# Copyright: Mitchell Krog - https://github.com/mitchellkrogza

# ****************************************************************
# This uses the awesome PyFunceble script created by Nissar Chababy
# Find funceble at: https://github.com/funilrys/PyFunceble
# ****************************************************************

# **********************
# Setting date variables
# **********************

yeartag=$(date +%Y)
monthtag=$(date +%m)
epoc=$(date +%s)

# ******************
# Set our Input File
# ******************
input=${TRAVIS_BUILD_DIR}/PULL_REQUESTS/domains.txt
#pyfuncebleConfigurationFileLocation=${TRAVIS_BUILD_DIR}/dev-tools/.PyFunceble.yaml
#pyfuncebleProductionConfigurationFileLocation=${TRAVIS_BUILD_DIR}/dev-tools/.PyFunceble_production.yaml

# **********************
# Run PyFunceble Testing
# **********************************************************
# Find PyFunceble at: https://github.com/funilrys/PyFunceble
# **********************************************************

RunFunceble () {

    yeartag=$(date +%Y)
    monthtag=$(date +%m)
    epoc=$(date +%s)
    ulimit -u
    cd ${TRAVIS_BUILD_DIR}/dev-tools

    hash PyFunceble

    #if [[ -f "${pyfuncebleConfigurationFileLocation}" ]]
    #then
    #    rm "${pyfuncebleConfigurationFileLocation}"
    #    rm "${pyfuncebleProductionConfigurationFileLocation}"
    #fi

    PyFunceble --ci -q -ex --dns 95.216.209.53 116.203.32.67 \
      -h --idna --mining --hierarchical -m --plain \
      --autosave-minutes 20 \
      -db --database-type mariadb -dbr 0 --share-logs \
      --cmd-before-end "bash ${TRAVIS_BUILD_DIR}/dev-tools/FinalCommit.sh" \
      --commit-autosave-message "${yeartag}.${monthtag}.${TRAVIS_BUILD_NUMBER}.${epoc} [Auto Saved]" \
      --commit-results-message "${yeartag}.${monthtag}.${TRAVIS_BUILD_NUMBER}.${epoc}" -f ${input}

}

RunFunceble


exit ${?}
