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
echo "-- ------------------------- --"
echo "--testing for fips look for 1--"
grep -i 1 /proc/sys/crypto/fips_enabled
echo "-- ------------------------- --"
echo ""

## V-260579
echo "-- ------------------------------------ --"
echo "--looking for mappers in pam_pkcs11.conf--"
grep -i use_mappers /etc/pam_pkcs11/pam_pkcs11.conf
echo "-- ------------------------------------ --"
echo ""

## CAT II
## V-260471 - initiate session audits at system startup
echo "-- -------------------------------------- --"
echo "--looking for audit=1 in /etc/default/grub--"
grep "^\s*linux" /boot/grub/grub.cfg
echo "-- -------------------------------------- --"
echo ""

## V-260473 - disable kernel core dumps
echo "-- ----------------------------------- --"
echo "--looking for masked and inactive in kdump-tools.service--"
systemctl status kdump-tools.service
echo "-- ----------------------------------- --"
echo ""

## V-260489 - generate error messages that provide information necessary for corrective actions without revealing information that could be exploited by adversaries.

## V-260500 - Files owned by root

## V260517 - 

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

## V-260535 display banner
echo "-- --------------------------------------- --"
echo "|-  V-260535 display banner #comment removed|"
banner-message-enable /etc/gdm3/greeter.dconf-defaults
echo "-- --------------------------------------- --"
echo ""

## V-260542 -Ubuntu 22.04 LTS must prevent direct login into the root account
echo "-- ----------------------------- --"
echo "--looking for L in passwd -S root--"
passwd -S root
echo "-- ----------------------------- --"
echo ""

## V-260553 - Ubuntu 22.04 LTS must allow users to directly initiate a session lock for all connection types.
echo "-- ------------------------- --"
echo "--Check if vlock is installed--"
dpkg -l | grep vlock
echo "-- ------------------------- --"
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

## V-260573 - Ubuntu 22.04 LTS must implement multifactor authentication for remote access
echo "-- --------------------------------- --"
echo "--Check if libpam-pkcs11 is installed--"
dpkg -l | grep libpam-pkcs11
echo "-- --------------------------------- --"
echo ""

## V-260574 - Ubuntu 22.04 LTS must accept personal identity verification (PIV) credentials.
echo "-- --------------------------------- --"
echo "--Check if opensc-pkcs11 is installed--"
dpkg -l | grep opensc-pkcs11
echo "-- --------------------------------- --"
echo ""

## V-260575 - Ubuntu 22.04 LTS must implement smart card logins for multifactor authentication for local and network access to privileged and nonprivileged accounts.
# Breaks password login

## V-260576-78 - must electronically verify personal identity verification (PIV) credentials
echo "-- ---------------------------------------------------- --"
echo "--Check for cert_policy = ca,signature,ocsp_on,crl_auto;--"
grep cert_policy /etc/pam_pkcs11/pam_pkcs11.conf | grep -E -- 'crl_auto|crl_offline'
echo "-- ---------------------------------------------------- --"
echo ""

## V-260576 - PKI - Look for cert policy
echo "-- ---------------------------------------------- --"
echo "|-  V-260576 looking for cert policy in pam_pkcs11 -|"
cat /etc/pam_pkcs11/pam_pkcs11.conf | grep cert_policy
echo "-- ---------------------------------------------- --"
echo ""


## V-260583 - Check if AIDE is configured
echo "-- ---------------------------- --"
echo "|-  Check if AIDE is configured -|"
aide -c /etc/aide/aide.conf --check
echo "-- ---------------------------- --"
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
## V-260519 - USNO time
echo "-- ------------------------------------ --"
echo "|-  V-260519 - USNO time maxpoll times -|"
grep -ir server /etc/chrony*
echo "-- ------------------------------------ --"
echo ""


## V-260549 - account lockout - look for [default=die]
echo "-- ----------------------------------------- --"
echo "|- V-260549 checlking pam.d for [default=die] -|"
cat /etc/pam.d/common-auth | grep die
echo "-- ----------------------------------------- --"




