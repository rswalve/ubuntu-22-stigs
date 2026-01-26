#!/bin/bash

## echo "--  --"

## CAT I

## CAT II

## Fix 1. V-270667, 670, 671
echo "-- ---------------------------------------------------------- --"
echo "-- V-270667, 670, 671 looking for Ciphers & MACs in ssh configs--"
grep -r 'Ciphers' /etc/ssh/sshd_config*
grep -ir macs /etc/ssh/sshd_config*
grep -r 'Ciphers' /etc/ssh/ssh_config*
grep -ir macs /etc/ssh/ssh_config*
echo "-- ---------------------------------------------------------- --"
echo ""

## Fix 2. V-270680 - Ubuntu 24.04 LTS must automatically terminate a user session after inactivity timeouts have expired.
echo "-- -------------------------------------------------------------------- --"
echo "-- V-270680 looking for TMOUT=600 in /etc/profile.d/99-terminal_tmout.sh--"
grep -E "\bTMOUT=[0-9]+" /etc/bash.bashrc /etc/profile.d/*
echo "-- --------------------------------------------------------------------- --"
echo ""


## Fix 3. V-270694 - SSH Notice and Consent Banner (Interactive)
echo "-- ---------------------------------------------------------- --"
echo "-- V-270694: Validating SSH Notice and Consent Banner Script --"

FILE_PATH="/etc/profile.d/ssh_confirm.sh"

# Store the exact required content in a variable
read -r -d '' EXPECTED_CONTENT << 'EOF'
#!/bin/bash

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

if [ ! -f "$FILE_PATH" ]; then
    echo "RESULT: [ NOT FIXED ] - File $FILE_PATH does not exist."
else
    # Compare the file content with the expected content
    # diff returns 0 if they are identical
    if echo "$EXPECTED_CONTENT" | diff -q "$FILE_PATH" - > /dev/null; then
        echo "RESULT: [ FIXED ] - The Banner script matches the DOD requirement exactly."
    else
        echo "RESULT: [ NOT FIXED ] - Content mismatch in $FILE_PATH."
        echo "The script must match the STIG text exactly, including spacing."
    fi
fi
echo "-- ---------------------------------------------------------- --"

## Fix 4.
## Fix 5.

## Fix 6. V-270725 - Ubuntu 24.04 LTS must store only encrypted representations of passwords.
echo "-- -------------------------------------------------------------------- --"
echo "-- V-270275 looking obscure shadow=100000 in /etc/pam.d/common-password --"
cat /etc/pam.d/common-password | grep obscure
echo "-- --------------------------------------------------------------------- --"
echo ""

## Fix 7. V-270754 - Firewall

## Fix 8. V-270756 - /var/log permissions

## Fix 9. V-270806 Generate audit records

cat /etc/audit/rules.d/stig.rules

## Fix 10.

## Fix 11.

## Fix 12.