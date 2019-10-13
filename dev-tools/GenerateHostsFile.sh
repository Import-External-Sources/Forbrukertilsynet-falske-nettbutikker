#!/bin/bash
# This hosts file for DD-WRT Routers with DNSMasq is brought to you by
# https://www.mypdns.org/
# Copyright: Content: https://gitlab.com/spirillen
# Source:Content:
#
# Original attributes and credit
# This hosts file for DD-WRT Routers with DNSMasq is brought to you by Mitchell Krog
# Copyright:Code: https://github.com/mitchellkrogza
# Source:Code: https://github.com/mitchellkrogza/Badd-Boyz-Hosts
# The credit for the original bash scripts goes to Mitchell Krogza

# You are free to copy and distribute this file for non-commercial uses,
# as long the original URL and attribution is included.

# Please forward any additions, corrections or comments by logging an issue at
# https://gitlab.com/my-privacy-dns/support/issues

# ******************
# Set Some Variables
# ******************

yeartag=$(date +%Y)
monthtag=$(date +%m)
my_git_tag=V1.${yeartag}.${monthtag}.${TRAVIS_BUILD_NUMBER}
bad_referrers=$(wc -l < ${TRAVIS_BUILD_DIR}/PULL_REQUESTS/domains.txt)
hosts=${TRAVIS_BUILD_DIR}/dev-tools/hosts.template
dnsmasq=${TRAVIS_BUILD_DIR}/dev-tools/ddwrt-dnsmasq.template
tmphostsA=tmphostsA
tmphostsB=tmphostsB
tmphostsC=tmphostsC

# **********************************
# Temporary database files we create
# **********************************

inputdbA=/tmp/lastupdated.db
inputdb1=/tmp/hosts.db

# **********************************
# Setup input bots and referer lists
# **********************************

input1=${TRAVIS_BUILD_DIR}/PULL_REQUESTS/domains.txt
input2=${TRAVIS_BUILD_DIR}/dev-tools/domains_tmp.txt

# **************************************************************************
# Sort lists alphabetically and remove duplicates before cleaning Dead Hosts
# **************************************************************************

sort -u ${input1} -o ${input1}

# *****************
# Activate Dos2Unix
# *****************

dos2unix ${input1}

# ******************************************
# Trim Empty Line at Beginning of Input File
# ******************************************

grep '[^[:blank:]]' < ${input1} > ${input2}
sudo mv ${input2} ${input1}

# ********************************************************
# Clean the list of any lines not containing a . character
# ********************************************************

cat ${input1} | sed '/\./!d' > ${input2} && mv ${input2} ${input1}

# **************************************************************************************
# Strip out our Dead Domains / Whitelisted Domains and False Positives from CENTRAL REPO
# **************************************************************************************


# *******************************
# Activate Dos2Unix One Last Time
# *******************************

dos2unix ${input1}

# ***************************************************************
# Start and End Strings to Search for to do inserts into template
# ***************************************************************

start1="# START HOSTS LIST ### DO NOT EDIT THIS LINE AT ALL ###"
end1="# END HOSTS LIST ### DO NOT EDIT THIS LINE AT ALL ###"
start2="# START DNSMASQ LIST ### DO NOT EDIT THIS LINE AT ALL ###"
end2="# END DNSMASQ LIST ### DO NOT EDIT THIS LINE AT ALL ###"
startmarker="##### Version Information #"
endmarker="##### Version Information ##"

# ******************************************************
# PRINT DATE AND TIME OF LAST UPDATE INTO HOSTS TEMPLATE
# ******************************************************

now="$(date)"
echo ${startmarker} >> ${tmphostsA}
printf "###################################################\n### Version: "${my_git_tag}"\n### Updated: "$now"\n### Bad Host Count: "${bad_referrers}"\n###################################################\n" >> ${tmphostsA}
echo ${endmarker}  >> ${tmphostsA}
mv ${tmphostsA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/##### Version Information #/d
/##### Version Information ##/,$d
,d
.r /home/travis/build/spirillen/Dead-Domains/dev-tools/hosts.template
/##### Version Information #/x
.t.
.,/##### Version Information ##/-d
w /home/travis/build/spirillen/Dead-Domains/dev-tools/hosts.template
q
IN
rm ${inputdbA}

# ********************************************************
# PRINT DATE AND TIME OF LAST UPDATE INTO DNSMASQ TEMPLATE
# ********************************************************

now="$(date)"
echo ${startmarker} >> ${tmphostsA}
printf "###################################################\n### Version: "${my_git_tag}"\n### Updated: "$now"\n### Bad Host Count: "${bad_referrers}"\n###################################################\n" >> ${tmphostsA}
echo ${endmarker}  >> ${tmphostsA}
mv ${tmphostsA} ${inputdbA}
ed -s ${inputdbA}<<\IN
1,/##### Version Information #/d
/##### Version Information ##/,$d
,d
.r /home/travis/build/spirillen/Dead-Domains/dev-tools/ddwrt-dnsmasq.template
/##### Version Information #/x
.t.
.,/##### Version Information ##/-d
w /home/travis/build/spirillen/Dead-Domains/dev-tools/ddwrt-dnsmasq.template
q
IN
rm ${inputdbA}

# ********************************
# Insert hosts into hosts template
# ********************************

echo ${start1} >> ${tmphostsB}
for line in $(cat ${input1}); do
printf "0.0.0.0 ${line}\n" >> ${tmphostsB}
done
echo ${end1}  >> ${tmphostsB}
mv ${tmphostsB} ${inputdb1}
ed -s ${inputdb1}<<\IN
1,/# START HOSTS LIST ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END HOSTS LIST ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/spirillen/Dead-Domains/dev-tools/hosts.template
/# START HOSTS LIST ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END HOSTS LIST ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/spirillen/Dead-Domains/dev-tools/hosts.template
q
IN
rm ${inputdb1}

# **********************************
# Insert hosts into DNSMASQ template
# **********************************

echo ${start2} >> ${tmphostsB}
for line in $(cat ${input1}); do
printf '%s%s%s\n' "address=/" "${line}" "/" >> ${tmphostsB}
done
echo ${end2}  >> ${tmphostsB}
mv ${tmphostsB} ${inputdb1}
ed -s ${inputdb1}<<\IN
1,/# START DNSMASQ LIST ### DO NOT EDIT THIS LINE AT ALL ###/d
/# END DNSMASQ LIST ### DO NOT EDIT THIS LINE AT ALL ###/,$d
,d
.r /home/travis/build/spirillen/Dead-Domains/dev-tools/ddwrt-dnsmasq.template
/# START DNSMASQ LIST ### DO NOT EDIT THIS LINE AT ALL ###/x
.t.
.,/# END DNSMASQ LIST ### DO NOT EDIT THIS LINE AT ALL ###/-d
w /home/travis/build/spirillen/Dead-Domains/dev-tools/ddwrt-dnsmasq.template
q
IN
rm ${inputdb1}

# ************************************
# Make RPZ always_nxdomain
# ************************************
RPZ="$(mktemp)"

printf "forbrukertilsynet.falske.nettbutikker.mypdns.cloud.\t3600\tIN\tSOA\tneed.to.know.only. hostmaster.mypdns.org. `date +%s` 3600 60 604800 60;\nforbrukertilsynet.falske.nettbutikker.mypdns.cloud.\t3600\tIN\tNS\tlocalhost\n" > "${RPZ}"
cat "${input1}" | awk '/^#/{ next }; {  printf("%s\tCNAME\t.\n*.%s\tCNAME\t.\n",tolower($1),tolower($1)) }' >> "${RPZ}"
mv "${RPZ}" "${TRAVIS_BUILD_DIR}"/forbrukertilsynet.falske.nettbutikker.mypdns.cloud.rpz

# ***********************************
# Generate unbound zone file
# ***********************************
UNBOUND="$(mktemp)"

cat "${input1}" | awk '/^#/{ next }; {  printf("local-zone: \"%s\" always_nxdomain\n",tolower($1)) }' >> "${UNBOUND}"
mv "${UNBOUND}" "${TRAVIS_BUILD_DIR}"/forbrukertilsynet.falske.nettbutikker.zone

# ***********************************
# Generate uBlock file
# ***********************************
uBlock="$(mktemp)"

cat "${input1}" | awk '/^#/{ next }; {  printf("\|\|\"%s\"\^\$empty,important\n",tolower($1)) }' >> "${uBlock}"
mv "${uBlock}" "${TRAVIS_BUILD_DIR}"/uBlock.txt

# ************************************
# Copy Files into place before testing
# ************************************

sudo cp ${hosts} ${TRAVIS_BUILD_DIR}/hosts
sudo cp ${dnsmasq} ${TRAVIS_BUILD_DIR}/dnsmasq

exit ${?}
