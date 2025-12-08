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

## V-260500 - Files owned by root

## V-260525 - DOD Notice and Consent Banner
echo "-- ----------------------------------------- --"
echo "|-  V-260525 - DOD Notice and Consent Banner -|"
cat /etc/issue.net
echo "-- ----------------------------------------- --"
echo ""


## V-260531 & V-260532 - look for Ciphers & MACs
echo "-- ----------------------------------------------- --"
echo "|-  V-260531 & V-260532 Looking for Ciphers and MACs|"
cat /etc/ssh/sshd_config | grep Ciphers
cat /etc/ssh/sshd_config | grep MACs
echo "-- ----------------------------------------------- --"
echo ""

## V-260569-store-only-encrypted-passwords
echo "-- ------------------------------------------------ --"
echo "|- V-260569 testing for encrypted passwords 'obscure'-|"
cat /etc/pam.d/common-password | grep obscure
echo "-- ------------------------------------------------ --"
echo ""

## V-260570 - nullok in pam.d - should be NO nullok
echo "-- ------------------------------------------- --"
echo "|-  V-260570 Looking for nullok hopefully blank-|"
cat /etc/pam.d/common-password | grep nullok
cat /etc/pam.d/common-auth | grep nullok
echo "-- ------------------------------------------- --"
echo ""

## V-260570 - PKI - look for /etc/pam_pkcs11/pam_pkcs11.conf
echo "-- -------------------------------- --"
echo "|-  V-260570 looking for use_mappers-|"
cat /etc/pam_pkcs11/pam_pkcs11.conf | grep use_mappers
echo "-- -------------------------------- --"
echo ""

## V-260576 - PKI - Look for cert policy
echo "-- ---------------------------------------------- --"
echo "|-  V-260576 looking for cert policy in pam_pkcs11 -|"
cat /etc/pam_pkcs11/pam_pkcs11.conf | grep cert_policy
echo "-- ---------------------------------------------- --"
echo ""

## V-260584 - Aide - look for Aide installed
echo "-- --------------------------- --"
echo "|-  V-260584 is aide installed -|"
dpkg -l | grep aide
cat /etc/default/aide | grep SILENTREPORTS=no
echo "-- --------------------------- --"
echo ""

## V-260586 - Aide - need /etc/aide.conf
echo "-- ------------------------------ --"
echo "|-  V-260586 Looking for aide.conf-|"
cat /etc/aide/aide.conf | grep auditctl
echo "-- ------------------------------ --"
echo ""

## V-260594 - Ubuntu 22.04 LTS must shut down by default upon audit failure.
echo "-- --------------------------------------- --"
echo "|-  V-260594 Looking for HALT in audit.conf-|"
grep -i disk_full_action /etc/audit/auditd.conf
echo "-- --------------------------------------- --"
echo ""

## V-260597 - Ubuntu 22.04 LTS must be configured so that audit log files are not read- or write-accessible by unauthorized users.
echo "-- --------------------------------------- --"
echo "|-  V-260597 audit log file permission 600 -|"
grep -iw log_file /etc/audit/auditd.conf
stat -c "%n %a" /var/log/audit/*
echo "-- --------------------------------------- --"
echo ""

## V-260599 - Ubuntu 22.04 LTS must permit only authorized groups ownership of the audit log files.
echo "-- ------------------------------------------- --"
echo "|-  V-260599 only root can own audit log files -|"
grep -iw log_group /etc/audit/auditd.conf
echo "-- ------------------------------------------- --"
echo ""

##  V-260604 - Ubuntu 22.04 LTS must generate audit records for successful/unsuccessful uses of the apparmor_parser command.
echo "-- ------------------------------------ --"
echo "|-  V-260604 audit records for apparmor -|"
auditctl -l | grep apparmor_parser
echo "-- ------------------------------------ --"
echo ""

##  V-260605 - Ubuntu 22.04 LTS must generate audit records for successful/unsuccessful uses of the chacl command.
echo "-- ------------------------------------ --"
echo "|-  V-260605 audit records for chacl -|"
auditctl -l | grep chacl
echo "-- ------------------------------------ --"
echo ""


## CAT III
## V-260549 - account lockout - look for [default=die]
echo "-- ----------------------------------------- --"
echo "|- V-260549 checlking pam.d for [default=die] -|"
cat /etc/pam.d/common-auth | grep die
echo "-- ----------------------------------------- --"




