!/bin/bash

## Backup files
# V-260470 - Grub
/etc/grub.d/40_custom
/etc/grub.d/10_linux

# V-260549 - Account lock and passwords
/etc/pam.d/common-auth
/etc/pam.d/common-password

## V-260470 - when booted, must require authentication upon booting into single-user and maintenance modes
PASSWORD="super-secret-ninja-password"
GRUB_HASH=$(echo -e "$PASSWORD\n$PASSWORD" | grub-mkpasswd-pbkdf2 | grep -oP '(?<=PBKDF2 hash of your password is ).*' )

cp /etc/grub.d/40_custom /etc/grub.d/40_custom.bak
sed -i "\$a set superusers=\"root\"\npassword_pbkdf2 root $GRUB_HASH" /etc/grub.d/40_custom

cp /etc/grub.d/10_linux /etc/grub.d/10_linux.bak
sed -i 's/^CLASS="--class gnu-linux/CLASS="--unrestricted --class gnu-linux/' /etc/grub.d/10_linux
update-grub
chmod 600 /boot/grub/grub.cfg

## V-260489 - generate error messages that provide information necessary for corrective actions without revealing information that could be exploited by adversaries.
find /var/log -perm /137 ! -name '*[bw]tmp' ! -name '*lastlog' -type f -exec chmod 640 '{}' \;

## V-260531 - Ubuntu 22.04 LTS must configure the SSH daemon to use FIPS 140-3-approved ciphers to prevent the unauthorized disclosure of information and/or detect changes to information during transmission.
## V-260532 - Ubuntu 22.04 LTS must configure the SSH daemon to use Message Authentication Codes (MACs) employing FIPS 140-3-approved cryptographic hashes to prevent the unauthorized disclosure of information and/or detect changes to information during transmission.
sed -i '$a\Ciphers aes256-ctr,aes192-ctr,aes128-ctr' /etc/ssh/sshd_config
sed -i '$a\MACs hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com' /etc/ssh/sshd_config
systemctl restart sshd.service

## V-260570 - when booted, must require authentication upon booting into single-user and maintenance modes.
sed -i 's/\s\+nullok//g' /etc/pam.d/common-password
sed -i 's/\s\+nullok//g' /etc/pam.d/common-auth

## V-260570 - must map the authenticated identity to the user or group account for PKI-based authentication
cp /usr/share/doc/libpam-pkcs11/examples/pam_pkcs11.conf.example /etc/pam_pkcs11/pam_pkcs11.conf
sed -i 's/^/#/' /etc/pam_pkcs11/pam_pkcs11.conf
sed -i 's|^#\s*use_mappers = |use_mappers = |' /etc/pam_pkcs11/pam_pkcs11.conf

## V-260576 - Ubuntu 22.04 LTS must electronically verify personal identity verification (PIV) credentials.
#sudo sed -i 's/^[#[:space:]]*cert_policy[[:space:]]*=.*/cert_policy = ca, ocsp_on, signature, crl_auto;/' /etc/pam_pkcs11/pam_pkcs11.conf

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

## V-260521 - Ubuntu 22.04 LTS must record time stamps for audit records that can be mapped to Coordinated Universal Time (UTC).
#timedatectl set-timezone Etc/UTC

## V-260549 - Ubuntu 22.04 LTS must automatically lock an account until the locked account is released by an administrator when three unsuccessful logon attempts have been made.
sed -i 's/^auth    [success=1 default=ignore]      pam_sss.so use_first_pass/aauth     [default=die]  pam_faillock.so authfail\nauth     sufficient          pam_faillock.so authsucc' /etc/pam.d/common-auth

## V-260569 - Ubuntu 22.04 LTS must store only encrypted representations of passwords.
#sed -i 's/^password\s\+\[success=2 default=ignore\]\s\+pam_unix.so/password [success=1 default=ignore]pam_unix.so obscure sha512 shadow rounds=100000/' /etc/pam.d/common-password
sed -i '/^password\s\+.*pam_unix\.so/c\password       [success=1 default=ignore]     pam_unix.so obscure sha512 shadow rounds=100000' /etc/pam.d/common-password
#sed -i 's/^password [success=2 default=ignore]*/password [success=1 default=ignore] pam_unix.so obscure sha512 shadow rounds=100000' /etc/pam.d/common-password


#cert_policy = ca, ocsp_on, signature, crl_auto;

#password [success=1 default=ignore] pam_unix.so obscure sha512 shadow rounds=100000
