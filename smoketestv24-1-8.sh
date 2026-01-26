#!/bin/bash

## echo "--  --"

## CAT I

## CAT II

## Fix 1. V-270667 & V-270668 - SSH Encryption & Integrity
echo "-- ---------------------------------------------------------- --"
echo "-- Validating SSH FIPS-approved Ciphers and MACs --"

# Define the required STIG standards
REQUIRED_CIPHERS="aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr"
REQUIRED_MACS="hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256"

# --- V-270667: Ciphers Check ---
echo "[V-270667] Checking Ciphers..."
CURRENT_CIPHERS=$(grep -rih "^Ciphers" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/ 2>/dev/null)

if [ -z "$CURRENT_CIPHERS" ]; then
    echo "RESULT: [ NOT FIXED ] - 'Ciphers' keyword is missing or commented out."
elif [[ "$CURRENT_CIPHERS" == *"$REQUIRED_CIPHERS"* ]]; then
    echo "RESULT: [ FIXED ] - Found: $CURRENT_CIPHERS"
else
    echo "RESULT: [ NOT FIXED ] - Incorrect or conflicting Ciphers found."
    echo "Expected: Ciphers $REQUIRED_CIPHERS"
fi

echo ""

# --- V-270668: MACs Check ---
echo "[V-270668] Checking MACs..."
CURRENT_MACS=$(grep -rih "^MACs" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/ 2>/dev/null)

if [ -z "$CURRENT_MACS" ]; then
    echo "RESULT: [ NOT FIXED ] - 'MACs' keyword is missing or commented out."
elif [[ "$CURRENT_MACS" == *"$REQUIRED_MACS"* ]]; then
    echo "RESULT: [ FIXED ] - Found: $CURRENT_MACS"
else
    echo "RESULT: [ NOT FIXED ] - Incorrect or conflicting MACs found."
    echo "Expected: MACs $REQUIRED_MACS"
fi

echo "-- ---------------------------------------------------------- --"

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
echo ""

# Fix 4.
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

## Fix 12.                                                                                                                                                                             30,1          Top