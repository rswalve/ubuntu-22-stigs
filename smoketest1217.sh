#!/bin/bash

## echo "--  --"

## CAT I

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
find /var/log -perm /137 ! -name '*[bw]tmp' ! -name '*lastlog' -type f -exec stat -c "%n %a" {} \;
## V-260500 - Files owned by root

## V260517 - 

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

## V-260583 - Check if AIDE is configured
echo "-- ---------------------------- --"
echo "|-  Check if AIDE is configured -|"
aide -c /etc/aide/aide.conf --check
echo "-- ---------------------------- --"
echo ""

## CAT III
## V-260519 - USNO time
echo "-- ------------------------------------ --"
echo "|-  V-260519 - USNO time maxpoll times -|"
grep -ir server /etc/chrony*
echo "-- ------------------------------------ --"
echo ""

## V-260521 - Ubuntu 22.04 LTS must record time stamps for audit records that can be mapped to Coordinated Universal Time (UTC). - Fail


## V-260549 - account lockout - look for [default=die]
echo "-- ----------------------------------------- --"
echo "|- V-260549 checlking pam.d for [default=die] -|"
cat /etc/pam.d/common-auth | grep die
echo "-- ----------------------------------------- --"

## V-260592 - Ubuntu 22.04 LTS audit event multiplexor must be configured to offload audit logs onto a different system from the system being audited. - Fail




