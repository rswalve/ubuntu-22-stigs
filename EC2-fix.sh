!/bin/bash

## Backup files
# V-260470 - Grub
/etc/grub.d/40_custom
/etc/grub.d/10_linux

# V-260549 - Account lock and passwords
/etc/pam.d/common-auth
/etc/pam.d/common-password

## Programs to install
## installing necesssary programs
## V-260553 - [vlock] must allow users to directly initiate a session lock for all connection types.
## V-260573 - [libpam-pkcs11] must implement multifactor authentication for remote access to privileged accounts in such a way that one of the factors is provided by a device separate from the system gaining access.
## V-260574 - [opensc-pkcs11] must accept personal identity verification (PIV) credentials.
## V-260582 - [aide] must use a file integrity tool to verify correct operation of all security functions.
## V-260590 - [auditd] must have the "auditd" package installed.
apt install -y vlock libpam-pkcs11 opensc-pkcs11 aide auditd
installed today - opensc-pkcs11 libpam-pkcs11 pcscd


## CAT I
---------------------------------------------------------------------------------------------------------------------------------------------------------
## V-260470 - when booted, must require authentication upon booting into single-user and maintenance modes
PASSWORD="super-secret-ninja-password"
GRUB_HASH=$(echo -e "$PASSWORD\n$PASSWORD" | grub-mkpasswd-pbkdf2 | grep -oP '(?<=PBKDF2 hash of your password is ).*' )

cp /etc/grub.d/40_custom /etc/grub.d/40_custom.bak
sed -i "\$a set superusers=\"root\"\npassword_pbkdf2 root $GRUB_HASH" /etc/grub.d/40_custom

cp /etc/grub.d/10_linux /etc/grub.d/10_linux.bak
sed -i 's/^CLASS="--class gnu-linux/CLASS="--unrestricted --class gnu-linux/' /etc/grub.d/10_linux
update-grub
chmod 600 /boot/grub/grub.cfg


### CAT II
---------------------------------------------------------------------------------------------------------------------------------------------------------
## V-260489 - generate error messages that provide information necessary for corrective actions without revealing information that could be exploited by adversaries.
find /var/log -perm /137 ! -name '*[bw]tmp' ! -name '*lastlog' -type f -exec chmod 640 '{}' \;

## V-260500 - library files must be group-owned by "root"
find /lib /lib64 /usr/lib /usr/lib64 -type f -name '*.so*' ! -group root -exec chown :root {} +

## V-260525 - DOD Notice and Consent Banner before granting any local or remote connection to the system.
tee /etc/issue.net > /dev/null << EOF
You are accessing a U.S. Government (USG) Information System (IS) that is
provided for USG-authorized use only. By using this IS (which includes any
device attached to this IS), you consent to the following conditions:
-The USG routinely intercepts and monitors communications on this IS for
purposes including, but not limited to, penetration testing, COMSEC monitoring,
network operations and defense, personnel misconduct (PM), law enforcement
(LE), and counterintelligence (CI) investigations.
-At any time, the USG may inspect and seize data stored on this IS.
-Communications using, or data stored on, this IS are not private, are subject
to routine monitoring, interception, and search, and may be disclosed or used
for any USG-authorized purpose.
-This IS includes security measures (e.g., authentication and access controls)
to protect USG interests--not for your personal benefit or privacy.
-Notwithstanding the above, using this IS does not constitute consent to PM, LE
or CI investigative searching or monitoring of the content of privileged
communications, or work product, related to personal representation or services
by attorneys, psychotherapists, or clergy, and their assistants. Such
communications and work product are private and confidential. See User
Agreement for details.
EOF
sed -i '/^Banner/d' /etc/ssh/sshd_config
sed -i '$aBanner /etc/issue.net' /etc/ssh/sshd_config
systemctl -s SIGHUP kill sshd

## V-260531 - Ubuntu 22.04 LTS must configure the SSH daemon to use FIPS 140-3-approved ciphers to prevent the unauthorized disclosure of information and/or detect changes to information during transmission.
## V-260532 - Ubuntu 22.04 LTS must configure the SSH daemon to use Message Authentication Codes (MACs) employing FIPS 140-3-approved cryptographic hashes to prevent the unauthorized disclosure of information and/or detect changes to information during transmission.
sed -i '$a\Ciphers aes256-ctr,aes192-ctr,aes128-ctr' /etc/ssh/sshd_config
sed -i '$a\MACs hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com' /etc/ssh/sshd_config
systemctl restart sshd.service

## V-260553 - [vlock] must allow users to directly initiate a session lock for all connection types.
## V-260573 - [libpam-pkcs11] must implement multifactor authentication for remote access to privileged accounts in such a way that one of the factors is provided by a device separate from the system gaining access.
## V-260574 - [opensc-pkcs11] must accept personal identity verification (PIV) credentials.



## V-260570 - when booted, must require authentication upon booting into single-user and maintenance modes.
sed -i 's/\s\+nullok//g' /etc/pam.d/common-password
sed -i 's/\s\+nullok//g' /etc/pam.d/common-auth

## V-260570 - must map the authenticated identity to the user or group account for PKI-based authentication
cp /usr/share/doc/libpam-pkcs11/examples/pam_pkcs11.conf.example /etc/pam_pkcs11/pam_pkcs11.conf
sed -i 's/^/#/' /etc/pam_pkcs11/pam_pkcs11.conf
sed -i 's|^#\s*use_mappers = |use_mappers = |' /etc/pam_pkcs11/pam_pkcs11.conf

## V-260575 - PKI 

## V-260576 - Ubuntu 22.04 LTS must electronically verify personal identity verification (PIV) credentials.
sed -i 's/^[#[:space:]]*cert_policy\s*=.*/cert_policy = ca, ocsp_on, signature, crl_auto;/' /etc/pam_pkcs11/pam_pkcs11.conf

## V-260584 - Ubuntu 22.04 LTS must notify designated personnel if baseline configurations are changed in an unauthorized manner. The file integrity tool must notify the system administrator when changes to thebaseline configuration or anomalies in the operation of any security functions are discovered.
sed -i '/SILENTREPORTS/s/^[[:space:]]*#//' /etc/default/aide
#sed -i 's/^#SILENTREPORTS=no/SILENTREPORTS=no' /etc/default/aide

## V-260586 - must use cryptographic mechanisms to protect the integrity of audit tools.
cat << EOF >> /etc/aide/aide.conf
# Audit Tools
/sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/augenrules p+i+n+u+g+s+b+acl+xattrs+sha512
EOF

## V-260594 - Ubuntu 22.04 LTS must shut down by default upon audit failure.
sed -i 's/^disk_full_action\s*=\s*SUSPEND/disk_full_action = HALT/' /etc/audit/auditd.conf

## V-260597 - Ubuntu 22.04 LTS must be configured so that audit log files are not read- or write-accessible by unauthorized users.
chmod 600 /var/log/audit/*

## V-260599 - Ubuntu 22.04 LTS must permit only authorized groups ownership of the audit log files.
sed -i 's/^log_group\s*=\s*adm/log_group = root/' /etc/audit/auditd.conf

##  V-260604 - Ubuntu 22.04 LTS must generate audit records for successful/unsuccessful uses of the apparmor_parser command.
sh -c 'echo "-a always,exit -F path=/usr/sbin/apparmor_parser -F perm=x -F auid>=1000 -F auid!=-1 -k perm_chng" >> /etc/audit/rules.d/stig.rules'
auditctl -R /etc/audit/rules.d/stig.rules
systemctl restart auditd.service

### CAT III
---------------------------------------------------------------------------------------------------------------------------------------------------------
## V-260521 - Ubuntu 22.04 LTS must record time stamps for audit records that can be mapped to Coordinated Universal Time (UTC).
#timedatectl set-timezone Etc/UTC

## V-260549 - Ubuntu 22.04 LTS must automatically lock an account until the locked account is released by an administrator when three unsuccessful logon attempts have been made.
sed -i '/auth\s*\[success=2 default=ignore\]\s*pam_unix.so/ {
  i\auth      required                     pam_faillock.so preauth audit silent deny=3 fail_interval=900
  i\auth      [default=die]                pam_faillock.so authfail audit
  s/.*/auth      required                     pam_unix.so try_first_pass/
}' /etc/pam.d/common-auth

sed -i '/^account\s*required\s*pam_unix.so/a account   required

## V-260569 - Ubuntu 22.04 LTS must store only encrypted representations of passwords.
sed -i 's/\(^password\s\+\[success=2 default=ignore\]\s\+pam_unix\.so\)\(.*\)/\1 obscure sha512 shadow rounds=100000\2/' /etc/pam.d/common-password

#cert_policy = ca, ocsp_on, signature, crl_auto;

#password [success=1 default=ignore] pam_unix.so obscure sha512 shadow rounds=100000
