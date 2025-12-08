#!/bin/bash

## echo "--  --"

## CAT I
## V-260470 - Grub - look for superusers
echo "-- ----------------------- --"
echo "|-  Looking for superusers -|"
cat /etc/grub.d/40_custom | grep superusers
echo "-- ----------------------- --"
echo ""


## V-260650 - fips
echo "--testing for fips look for 1--"
grep -i 1 /proc/sys/crypto/fips_enabled


## CAT II
## V-260531 & V-260532 - look for Ciphers & MACs
echo "-- ----------------------------------------------- --"
echo "|-  V-260531 & V-260532 Looking for Ciphers and MACs|"
cat /etc/ssh/sshd_config | grep Ciphers
cat /etc/ssh/sshd_config | grep MACs
echo "-- ----------------------------------------------- --"

## V-260569-store-only-encrypted-passwords
echo "-- ------------------------------------------------ --"
echo "|- V-260569 testing for encrypted passwords 'obscure'-|"
cat /etc/pam.d/common-password | grep obscure
echo "-- ------------------------------------------------ --"


## V-260570 - nullok in pam.d - should be NO nullok
echo "-- ------------------------------------------- --"
echo "|-  V-260570 Looking for nullok hopefully blank-|"
cat /etc/pam.d/common-password | grep nullok
cat /etc/pam.d/common-auth | grep nullok
echo "-- ------------------------------------------- --"

## V-260570 - PKI - look for /etc/pam_pkcs11/pam_pkcs11.conf
echo "-- -------------------------------- --"
echo "|-  V-260570 looking for use_mappers-|"
cat /etc/pam_pkcs11/pam_pkcs11.conf | grep use_mappers
echo "-- -------------------------------- --"


## V-260576 - PKI - Look for cert policy
echo "-- ---------------------------------------------- --"
echo "|-  V-260576 looking for cert policy in pam_pkcs11 -|"
cat /etc/pam_pkcs11/pam_pkcs11.conf | grep cert_policy
echo "-- ---------------------------------------------- --"


## V-260584 - Aide - look for Aide installed
echo "-- --------------------------- --"
echo "|-  V-260584 is aide installed -|"
dpkg -l | grep aide
cat /etc/default/aide | grep SILENTREPORTS=no
echo "-- --------------------------- --"

## V-260586 - Aide - need /etc/aide.conf
echo "-- ------------------------------ --"
echo "|-  V-260586 Looking for aide.conf-|"
cat /etc/aide/aide.conf | grep auditctl
echo "-- ------------------------------ --"



## CAT III
## V-260549 - account lockout - look for [default=die]
echo "-- ----------------------------------------- --"
echo "|- V-260549 checlking pam.d for [default=die] -|"
cat /etc/pam.d/common-auth | grep die
echo "-- ----------------------------------------- --"




