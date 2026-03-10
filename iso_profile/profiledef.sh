#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="spiderslab"
iso_label="SPIDERSLAB_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Spider's LAB <https://github.com/f3ar13ss>"
iso_application="Spider's LAB — Cyberpunk Hacker Workstation"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/etc/sudoers.d/spider"]="0:0:440"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/home/spider"]="1000:1000:750"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/bin/spider-power-menu"]="0:0:755"
  ["/usr/local/bin/spider-launch"]="0:0:755"
  ["/usr/local/bin/spider-matrix"]="0:0:755"
  ["/usr/local/bin/spider-bootsound"]="0:0:755"
  ["/usr/local/bin/spider-ttycolors"]="0:0:755"
  ["/usr/local/bin/spider-nettraffic"]="0:0:755"
  ["/usr/local/bin/spider-summon"]="0:0:755"
  ["/usr/local/bin/spider-neuralload"]="0:0:755"
  ["/usr/local/bin/ghost-out"]="0:0:755"
)
