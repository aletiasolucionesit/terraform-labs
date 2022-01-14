#cloud-config
# vim: syntax=yaml
#
# ***********************
# 	---- for more examples look at: ------
# ---> https://cloudinit.readthedocs.io/en/latest/topics/examples.html
# ******************************
#
# This is the configuration syntax that the write_files module
# will know how to understand. encoding can be given b64 or gzip or (gz+b64).
# The content will be decoded accordingly and then written to the path that is
# provided.
#
# Note: Content strings here are truncated for example purposes.
ssh_pwauth: True
chpasswd:
  list: |
     root:toor
  expire: False
users:
  - name: dmartin
    groups: wheel
    sudo: "ALL=(ALL) NOPASSWD: ALL"
    ssh-authorized-keys:
      - ${file("~/.ssh/david_rsa.pub")}
  - name: root
    ssh-authorized-keys:
      - ${file("~/.ssh/david_rsa.pub")}
bootcmd:
  - sed -i 's/.*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config

# Optional: list of packages to install
# packages:
#   - package_name
#   - @package_group_name
