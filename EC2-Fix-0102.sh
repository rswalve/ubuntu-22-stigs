#!/bin/bash

# 1. V-270667, 670, 671 FIPS Ciphers & MACs
# sshd/ssh_config
sed -i 's/^#\?Ciphers .*/Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr/' /etc/ssh/sshd_config
sed -i 's/^#\?MACs .*/MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256/' /etc/ssh/sshd_config
# ssh/sshd_config
sed -i 's/^#\s*Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc/Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr/' /etc/ssh/ssh_config
sed -i 's/^#\s*MACs hmac-md5,hmac-sha1,umac-64@openssh.com/MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256/' /etc/ssh/ssh_config
systemctl restart ssh
systemctl daemon-reload

# 2. 
# V-270680 add timeout 
tee /etc/profile.d/99-terminal_tmout.sh > /dev/null << EOF
# Set TMOUT to 600 seconds and make it read-only
readonly TMOUT=600
export TMOUT
EOF

rm -rf /etc/profile.d/tmout.sh

# 3. V-270694 adding /etc/profile.d/ssh_confirm.sh
tee /etc/profile.d/ssh_confirm.sh > /dev/null << EOF
#!/bin/bash

# Check if the shell is NOT interactive or NOT a TTY, then exit early.
# This lets SCAP scanners (which are non-interactive) skip the loop.
[[ $- != *i* ]] && return
[ ! -t 0 ] && return

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
while true; do
read -p "


You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only.

By using this IS (which includes any device attached to this IS), you consent to the following conditions:

-The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations.

-At any time, the USG may inspect and seize data stored on this IS.

-Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG-authorized purpose.

-This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy.

-Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and confidential. See User Agreement for details.

Do you agree? [y/N] " yn
case $yn in
[Yy]* ) break ;;
[Nn]* ) exit 1 ;;
esac
done
fi
EOF

# 4. V-270699 - lib files owned by root
find /lib /lib64 /usr/lib /usr/lib64 -type f -name '*.so*' ! -group root -exec chown :root {} +

# 5. 

# 6. V-270725 - Ubuntu 24.04 LTS must store only encrypted representations of passwords.
cp /etc/pam.d/common-password /etc/pam.d/common-password.bak
sed -i 's/^\(password\s\+\[success=2 default=ignore\]\s\+pam_unix\.so\).*/\1 obscure sha512 shadow rounds=100000/' /etc/pam.d/common-password

# 8. V-270756 - /var/log permissions
find /var/log -perm /137 ! -name '*[bw]tmp' ! -name '*lastlog' -type f -exec chmod 640 '{}' \;

# 9. V-270806 Generate audit records
tee /etc/audit/rules.d/stig.rules > /dev/null << EOF
# adding this file as remediation for V-270806 - Ubuntu 24.04 LTS must generate audit records for successful/unsuccessful uses of the delete_module syscall.
-a always,exit -F arch=b32 -S delete_module -F auid>=1000 -F auid!=-1 -k module_chng
-a always,exit -F arch=b64 -S delete_module -F auid>=1000 -F auid!=-1 -k module_chng
EOF

augenrules --load

# 10. V-270831 - protect audit tools
cat << EOF >> /etc/aide/aide.conf
# Audit Tools
/sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/augenrules p+i+n+u+g+s+b+acl+xattrs+sha512
EOF

# 12. V-274870 audit scripts and cronjobs called by root
cat << EOF >> /etc/audit/rules.d/audit.rules
# adding this file as remediation for V-274870 - Ubuntu 24.04 LTS must audit any script or executable called by cron as root or by any privileged user.
auditctl -w /etc/cron.d/ -p wa -k cronjobs
auditctl -w /var/spool/cron/ -p wa -k cronjobs
EOF

augenrules --load


