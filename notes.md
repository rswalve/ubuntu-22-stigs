              - name: ProEnableFIPS
                action: ExecuteBash
                inputs:
                  commands:
                    - |
                      echo "=== Enable FIPS mode via Pro license ==="
                      export DEBIAN_FRONTEND=noninteractive

                      pro enable fips-updates --assume-yes
                      apt install ubuntu-pro-client -y

              - name: RebootAfterFIPS
                action: Reboot
                inputs:
                  delaySeconds: 0

differences in v18 to v26
amazon stig
v18
Attempting to install auditd kdump-tools vlock libpam-pkcs11 opensc-pkcs11 gdm3 aide package(s)


Missing programs
systemd-timesyncd package is not installed, per V-260480
ntp package is not installed, per V-260481
kdump-tools
vlock
libpam-pkcs11
opensc-pkcs11 
gdm3
