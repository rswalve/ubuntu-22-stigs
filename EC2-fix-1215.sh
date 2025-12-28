!/bin/bash

## Backup files
# V-260470 - Grub
#/etc/grub.d/40_custom
#/etc/grub.d/10_linux

# V-260549 - Account lock and passwords
#/etc/pam.d/common-auth
#/etc/pam.d/common-password

## Programs to install
## installing necesssary programs
## V-260553 - [vlock] must allow users to directly initiate a session lock for all connection types.
## V-260573 - [libpam-pkcs11] must implement multifactor authentication for remote access to privileged accounts in such a way that one of the factors is provided by a device separate from the system gaining access.
## V-260574 - [opensc-pkcs11] must accept personal identity verification (PIV) credentials.
## V-260582 - [aide] must use a file integrity tool to verify correct operation of all security functions.
## V-260590 - [auditd] mus#!/bin/basht have the "auditd" package installed.
export DEBIAN_FRONTEND=noninteractive

apt-get -y install \
vlock \
libpam-pkcs11 \
opensc-pkcs11 \
kdump-tools \
audispd-plugins \
2>> /tmp/security_tool_errors.log || true


## CAT I
---------------------------------------------------------------------------------------------------------------------------------------------------------
## V-260579 - Ubuntu 22.04 LTS must map the authenticated identity to the user or group account for PKI-based authentication.
cp /usr/share/doc/libpam-pkcs11/examples/pam_pkcs11.conf.example /etc/pam_pkcs11/pam_pkcs11.conf
sed -i 's/^/#/' /etc/pam_pkcs11/pam_pkcs11.conf
sed -i 's|^#\s*use_mappers = |use_mappers = |' /etc/pam_pkcs11/pam_pkcs11.conf

### CAT II
---------------------------------------------------------------------------------------------------------------------------------------------------------
## V-260471 - Ubuntu 22.04 LTS must initiate session audits at system startup.
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/GRUB_CMDLINE_LINUX_DEFAULT="audit=1"/' /etc/default/grub
update-grub

## V-260473 - Ubuntu 22.04 LTS must disable kernel core dumps so that it can fail to a secure state if system initialization fails, shutdown fails or aborts fail.
## kdump-tools was added to the install list
systemctl mask kdump-tools --now

## V-260489 - generate error messages that provide information necessary for corrective actions without revealing information that could be exploited by adversaries.
find /var/log -perm /137 ! -name '*[bw]tmp' ! -name '*lastlog' -type f -exec chmod 640 '{}' \;

## V-260500 - library files must be group-owned by "root"
find /lib /lib64 /usr/lib /usr/lib64 -type f -name '*.so*' ! -group root -exec chown :root {} +

## V-260535 - Ubuntu 22.04 LTS must enable the graphical user logon banner to display the Standard Mandatory DOD Notice and Consent Banner before granting local access to the system via a graphical user logon.
#sed -i 's/^# banner-message-enable=true/banner-message-enable=true/' /etc/gdm3/greeter.dconf-defaults

## V-260536 - Ubuntu 22.04 LTS must display the Standard Mandatory DOD Notice and Consent Banner before granting local access to the system via a graphical user logon.
#MESSAGE="banner-message-text='You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only.\\n\\nBy using this IS (which includes any device attached to this IS), you consent to the following conditions:\\n\\n-The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations.\\n\\n-At any time, the USG may inspect and seize data stored on this IS.\\n\\n-Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG-authorized purpose.\\n\\n-This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy.\\n\\n-Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and confidential. See User Agreement for details.'"
#sed -i "s|^# banner-message-text='Welcome'|${MESSAGE}|" /etc/gdm3/greeter.dconf-defaults
#dpkg-reconfigure gdm3
#systemctl restart gdm3

## V-260542 - Ubuntu 22.04 LTS must prevent direct login into the root account.
passwd -l root

## V-260553


## V-260569 - Ubuntu 22.04 LTS must store only encrypted representations of passwords.
sed -i 's/^\(password\s\+\)\[success=2 default=ignore\]\s\+pam_unix\.so.*$/\1[success=1 default=ignore] pam_unix.so obscure sha512 shadow rounds=100000/' /etc/pam.d/common-password

## V-260573

## V-260574

## V-260576 - Ubuntu 22.04 LTS must electronically verify personal identity verification (PIV) credentials.
sed -i 's/^[#[:space:]]*cert_policy\s*=.*/cert_policy = ca, ocsp_on, signature, crl_auto;/' /etc/pam_pkcs11/pam_pkcs11.conf

## V-260577 - Ubuntu 22.04 LTS, for PKI-based authentication, must validate certificates by constructing a certification path (which includes status information) to an accepted trust anchor.
sed -i 's/^[[:space:]]*#\?[[:space:]]*cert_policy[[:space:]]*=.*$/cert_policy = ca,signature,ocsp_on, crl_auto;/' /etc/pam_pkcs11/pam_pkcs11.conf
grep -q cert_policy /etc/pam_pkcs11/pam_pkcs11.conf || \
sed -i '$a\cert_policy = ca,signature,ocsp_on, crl_auto;' /etc/pam_pkcs11/pam_pkcs11.conf

## V-260578

## V-260583 - Ubuntu 22.04 LTS must configure AIDE to perform file integrity checking on the file system.
#aideinit

### CAT III
---------------------------------------------------------------------------------------------------------------------------------------------------------
## V-260519 Sync time every 24 hours
sudo sed -i '$a\server tick.usno.navy.mil iburst maxpoll 16\nserver tock.usno.navy.mil iburst maxpoll 16\nserver ntp2.usno.navy.mil iburst maxpoll 16' /etc/chrony/chrony.conf
systemctl restart chrony

## V-260521

## V-260549 - Ubuntu 22.04 LTS must automatically lock an account until the locked account is released by an administrator when three unsuccessful logon attempts have been made.
sed -i '/auth\s*\[success=2 default=ignore\]\s*pam_unix.so/ {
  i\auth      required                     pam_faillock.so preauth audit silent deny=3 fail_interval=900
  i\auth      [default=die]                pam_faillock.so authfail
  s/.*/auth      required                     pam_unix.so try_first_pass/
}' /etc/pam.d/common-auth

## V-260592 - Ubuntu 22.04 LTS audit event multiplexor must be configured to offload audit logs onto a different system from the system being audited.
# Activate the plugin
sed -i -E 's/active\s*=\s*no/active = yes/' /etc/audit/plugins.d/au-remote.conf

