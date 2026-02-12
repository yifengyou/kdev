#!/bin/bash
#

SET_VENDOR=$1
SET_ROOTFS=$2

if [ -z "${SET_VENDOR}" ]; then
  echo "must specific vendor" >&2
  exit 1
fi

if [ -z "${SET_ROOTFS}" ]; then
  echo "must specific rootfs for ${SET_VENDOR}" >&2
  exit 1
fi

if [ "$SET_VENDOR" == "armbian" ]; then
# curl -s "https://api.github.com/repos/yifengyou/kdev/releases/tags/armbian-rootfs"   | jq -r '.assets[].name'
#armbian_bookworm_gnome.rar
#armbian_bookworm_mini.rar
#armbian_bookworm_xfce.rar
#armbian_bullseye_mini.rar
#armbian_forky_gnome.rar
#armbian_forky_mini.rar
#armbian_forky_xfce.rar
#armbian_jammy_gnome.rar
#armbian_jammy_mini.rar
#armbian_jammy_xfce.rar
#armbian_noble_gnome.rar
#armbian_noble_mini.rar
#armbian_noble_xfce.rar
#armbian_plucky_gnome.rar
#armbian_plucky_mini.rar
#armbian_plucky_xfce.rar
#armbian_trixie_gnome.rar
#armbian_trixie_mini.rar
#armbian_trixie_xfce.rar

  export ROOTFS="${SET_ROOTFS}"
  export ROOTFS_URL="https://github.com/yifengyou/kdev/releases/download/${SET_VENDOR}-rootfs/${ROOTFS}"
  export BUILD_TAG="${SET_ROOTFS}"

  echo "${ROOTFS_URL}" "${ROOTFS}" "${BUILD_TAG}"
elif [ "$SET_VENDOR" == "fnos" ]; then
# curl -s "https://api.github.com/repos/yifengyou/kdev/releases/tags/fnos-rootfs"   | jq -r '.assets[].name'
# fnos_1.1.19.rar

  export ROOTFS="${SET_ROOTFS}"
  export ROOTFS_URL="https://github.com/yifengyou/kdev/releases/download/${SET_VENDOR}-rootfs/${ROOTFS}"
  export BUILD_TAG="${SET_ROOTFS}"

  echo "${ROOTFS_URL}" "${ROOTFS}" "${BUILD_TAG}"

elif [ "$SET_VENDOR" == "centos" ]; then
# curl -s "https://api.github.com/repos/yifengyou/kdev/releases/tags/centos-rootfs"   | jq -r '.assets[].name'
# centos_10_aarch64.rar
# centos_10_x86_64.rar
# centos_8_aarch64.rar
# centos_8_x86_64.rar
# centos_9_aarch64.rar
  export ROOTFS="${SET_ROOTFS}"
  export ROOTFS_URL="https://github.com/yifengyou/kdev/releases/download/${SET_VENDOR}-rootfs/${ROOTFS}"
  export BUILD_TAG="${SET_ROOTFS}"

  echo "${ROOTFS_URL}" "${ROOTFS}" "${BUILD_TAG}"
elif [ "$SET_VENDOR" == "rockylinux" ]; then
# curl -s "https://api.github.com/repos/yifengyou/kdev/releases/tags/rockylinux-rootfs"   | jq -r '.assets[].name'
#rockylinux_10_aarch64.rar
#rockylinux_10_x86_64.rar
#rockylinux_8_aarch64.rar
#rockylinux_8_x86_64.rar
#rockylinux_9_aarch64.rar
#rockylinux_9_x86_64.rar

  export ROOTFS="${SET_ROOTFS}"
  export ROOTFS_URL="https://github.com/yifengyou/kdev/releases/download/${SET_VENDOR}-rootfs/${ROOTFS}"
  export BUILD_TAG="${SET_ROOTFS}"

  echo "${ROOTFS_URL}" "${ROOTFS}" "${BUILD_TAG}"
elif [ "$SET_VENDOR" == "ubuntu" ]; then
#curl -s "https://api.github.com/repos/yifengyou/kdev/releases/tags/ubuntu-rootfs"   | jq -r '.assets[].name'
#ubuntu_bionic_18.04_amd64.rar
#ubuntu_bionic_18.04_arm64.rar
#ubuntu_focal_20.04_amd64.rar
#ubuntu_focal_20.04_arm64.rar
#ubuntu_jammy_22.04_amd64.rar
#ubuntu_jammy_22.04_arm64.rar
#ubuntu_noble_24.04_amd64.rar
#ubuntu_noble_24.04_arm64.rar

  export ROOTFS="${SET_ROOTFS}"
  export ROOTFS_URL="https://github.com/yifengyou/kdev/releases/download/${SET_VENDOR}-rootfs/${ROOTFS}"
  export BUILD_TAG="${SET_ROOTFS}"

  echo "${ROOTFS_URL}" "${ROOTFS}" "${BUILD_TAG}"
elif [ "$SET_VENDOR" == "debian" ]; then
# curl -s "https://api.github.com/repos/yifengyou/kdev/releases/tags/debian-rootfs"   | jq -r '.assets[].name'
#debian_bookworm_12_amd64.rar
#debian_bookworm_12_arm64.rar
#debian_bullseye_11_amd64.rar
#debian_bullseye_11_arm64.rar
#debian_trixie_13_amd64.rar
#debian_trixie_13_arm64.rar

  export ROOTFS="${SET_ROOTFS}"
  export ROOTFS_URL="https://github.com/yifengyou/kdev/releases/download/${SET_VENDOR}-rootfs/${ROOTFS}"
  export BUILD_TAG="${SET_ROOTFS}"

  echo "${ROOTFS_URL}" "${ROOTFS}" "${BUILD_TAG}"
elif [ "$SET_VENDOR" == "fedora" ]; then
# curl -s "https://api.github.com/repos/yifengyou/kdev/releases/tags/fedora-rootfs"   | jq -r '.assets[].name'
#Fedora-Cloud-Base-33-1.2.aarch64.rar
#Fedora-Cloud-Base-33-1.2.x86_64.rar
#Fedora-Cloud-Base-34-1.2.aarch64.rar
#Fedora-Cloud-Base-34-1.2.x86_64.rar
#Fedora-Cloud-Base-35-1.2.aarch64.rar
#Fedora-Cloud-Base-35-1.2.x86_64.rar
#Fedora-Cloud-Base-36-1.5.aarch64.rar
#Fedora-Cloud-Base-36-1.5.x86_64.rar
#Fedora-Cloud-Base-37-1.7.aarch64.rar
#Fedora-Cloud-Base-37-1.7.x86_64.rar
#Fedora-Cloud-Base-38-1.6.aarch64.rar
#Fedora-Cloud-Base-38-1.6.x86_64.rar
#Fedora-Cloud-Base-39-1.5.aarch64.rar
#Fedora-Cloud-Base-39-1.5.x86_64.rar
#Fedora-Cloud-Base-Generic-41-1.4.aarch64.rar
#Fedora-Cloud-Base-Generic-41-1.4.x86_64.rar
#Fedora-Cloud-Base-Generic.aarch64-40-1.14.rar
#Fedora-Cloud-Base-Generic.x86_64-40-1.14.rar
#Fedora-Cloud-Base-UEFI-UKI-41-1.4.aarch64.rar
#Fedora-Cloud-Base-UEFI-UKI-41-1.4.x86_64.rar
#Fedora-Cloud-Base-UEFI-UKI.aarch64-40-1.14.rar
#Fedora-Cloud-Base-UEFI-UKI.x86_64-40-1.14.rar
#Fedora-Server-Guest-Generic-42-1.1.aarch64.rar
#Fedora-Server-Guest-Generic-42-1.1.x86_64.rar
#Fedora-Server-Guest-Generic-43-1.6.aarch64.rar
#Fedora-Server-Guest-Generic-43-1.6.x86_64.rar
#fedora_42_aarch64.rar
#fedora_42_x86_64.rar
#fedora_43_aarch64.rar
#fedora_43_x86_64.rar

  export ROOTFS="${SET_ROOTFS}"
  export ROOTFS_URL="https://github.com/yifengyou/kdev/releases/download/${SET_VENDOR}-rootfs/${ROOTFS}"
  export BUILD_TAG="${SET_ROOTFS}"

  echo "${ROOTFS_URL}" "${ROOTFS}" "${BUILD_TAG}"

elif [ "$SET_VENDOR" == "kali" ]; then
#curl -s "https://api.github.com/repos/yifengyou/kdev/releases/tags/kali-rootfs"   | jq -r '.assets[].name'
#kali-linux-2025.3-cloud-genericcloud-amd64.rar
#kali-linux-2025.3-cloud-genericcloud-arm64.rar
#kali-linux-2025.4-cloud-genericcloud-amd64.rar
#kali-linux-2025.4-cloud-genericcloud-arm64.rar

  export ROOTFS="${SET_ROOTFS}"
  export ROOTFS_URL="https://github.com/yifengyou/kdev/releases/download/${SET_VENDOR}-rootfs/${ROOTFS}"
  export BUILD_TAG="${SET_ROOTFS}"

  echo "${ROOTFS_URL}" "${ROOTFS}" "${BUILD_TAG}"
elif [ "$SET_VENDOR" == "opencloudos" ]; then
#curl -s "https://api.github.com/repos/yifengyou/kdev/releases/tags/opencloudos-rootfs"   | jq -r '.assets[].name'
#OpenCloudOS-8.8-5.4.119-20.0009.29-20230817.1028-aarch64.rar
#OpenCloudOS-8.8-5.4.119-20.0009.29-20230817.1028-x86_64.rar
#OpenCloudOS-EC2-9.2-20250226.0.aarch64.rar
#OpenCloudOS-EC2-9.2-20250226.0.x86_64.rar
#OpenCloudOS-GenericCloud-8.10-20240729.0-20240730.1137-x86_64.rar
#OpenCloudOS-GenericCloud-8.10-20240729.0-20240730.1138-aarch64.rar
#OpenCloudOS-GenericCloud-9.2-20240529.0.aarch64.rar
#OpenCloudOS-GenericCloud-9.2-20240529.0.x86_64.rar
#OpenCloudOS-GenericCloud-9.2-20240711.0.aarch64.rar
#OpenCloudOS-GenericCloud-9.2-20240711.0.x86_64.rar
#OpenCloudOS-GenericCloud-9.2-20240807.0.aarch64.rar
#OpenCloudOS-GenericCloud-9.2-20240807.0.x86_64.rar
#OpenCloudOS-GenericCloud-9.2-20240919.0.aarch64.rar
#OpenCloudOS-GenericCloud-9.2-20240919.0.x86_64.rar
#OpenCloudOS-GenericCloud-9.2-20241030.0.aarch64.rar
#OpenCloudOS-GenericCloud-9.2-20241030.0.x86_64.rar
#OpenCloudOS-GenericCloud-9.2-20241211.0.aarch64.rar
#OpenCloudOS-GenericCloud-9.2-20241211.0.x86_64.rar
#OpenCloudOS-GenericCloud-9.2-20250226.0.aarch64.rar
#OpenCloudOS-GenericCloud-9.2-20250226.0.x86_64.rar
#OpenCloudOS-GenericCloud-9.2-20250327.0.aarch64.rar
#OpenCloudOS-GenericCloud-9.2-20250327.0.x86_64.rar
#OpenCloudOS-GenericCloud-9.2-20250421.0.aarch64.rar
#OpenCloudOS-GenericCloud-9.2-20250421.0.x86_64.rar
#OpenCloudOS-GenericCloud-9.4-20250820.0.aarch64.rar
#OpenCloudOS-GenericCloud-9.4-20250820.0.x86_64.rar
#OpenCloudOS-GenericCloud-9.4-20251120.0.aarch64.rar
#OpenCloudOS-GenericCloud-9.4-20251120.0.x86_64.rar
#OpenCloudOS-GenericCloud-9.4-20251223.0.aarch64.rar
#OpenCloudOS-GenericCloud-9.4-20251223.0.x86_64.rar
#opencloudos-v8.6-minimal-aarch64-20230206.rar
#opencloudos-v8.6-minimal-x86_64-20230206.rar
#opencloudos-v9.0-20230317-aarch64.rar
#opencloudos-v9.0-20230329-x86_64.rar

  export ROOTFS="${SET_ROOTFS}"
  export ROOTFS_URL="https://github.com/yifengyou/kdev/releases/download/${SET_VENDOR}-rootfs/${ROOTFS}"
  export BUILD_TAG="${SET_ROOTFS}"

  echo "${ROOTFS_URL}" "${ROOTFS}" "${BUILD_TAG}"
elif [ "$SET_VENDOR" == "openeuler" ]; then
# curl -s "https://api.github.com/repos/yifengyou/kdev/releases/tags/openeuler-rootfs"   | jq -r '.assets[].name'
#openEuler-20.03-LTS-SP1.aarch64.rar
#openEuler-20.03-LTS-SP1.x86_64.rar
#openEuler-20.03-LTS-SP2-aarch64.rar
#openEuler-20.03-LTS-SP2-x86_64.rar
#openEuler-20.03-LTS-SP3-aarch64.rar
#openEuler-20.03-LTS-SP3-x86_64.rar
#openEuler-20.03-LTS-SP4-aarch64.rar
#openEuler-20.03-LTS-SP4-x86_64.rar
#openEuler-20.03-LTS.aarch64.rar
#openEuler-20.03-LTS.x86_64.rar
#openEuler-20.09.aarch64.rar
#openEuler-20.09.x86_64.rar
#openEuler-21.03-aarch64.rar
#openEuler-21.03-x86_64.rar
#openEuler-21.09-aarch64.rar
#openEuler-21.09-x86_64.rar
#openEuler-22.03-LTS-64kb-aarch64.rar
#openEuler-22.03-LTS-aarch64.rar
#openEuler-22.03-LTS-SP1-aarch64.rar
#openEuler-22.03-LTS-SP1-x86_64.rar
#openEuler-22.03-LTS-SP2-aarch64.rar
#openEuler-22.03-LTS-SP2-x86_64.rar
#openEuler-22.03-LTS-SP3-aarch64.rar
#openEuler-22.03-LTS-SP3-x86_64.rar
#openEuler-22.03-LTS-SP4-aarch64.rar
#openEuler-22.03-LTS-SP4-x86_64.rar
#openEuler-22.03-LTS-x86_64.rar
#openEuler-22.09-aarch64.rar
#openEuler-22.09-x86_64.rar
#openEuler-23.03-aarch64.rar
#openEuler-23.03-x86_64.rar
#openEuler-23.09-aarch64.rar
#openEuler-23.09-x86_64.rar
#openEuler-24.03-LTS-aarch64.rar
#openEuler-24.03-LTS-SP1-aarch64.rar
#openEuler-24.03-LTS-SP1-x86_64.rar
#openEuler-24.03-LTS-SP2-aarch64.rar
#openEuler-24.03-LTS-SP2-x86_64.rar
#openEuler-24.03-LTS-SP3-aarch64.rar
#openEuler-24.03-LTS-SP3-x86_64.rar
#openEuler-24.03-LTS-x86_64.rar
#openEuler-24.09-aarch64.rar
#openEuler-24.09-x86_64.rar
#openEuler-25.03-aarch64.rar
#openEuler-25.03-x86_64.rar
#openEuler-25.09-aarch64.rar
#openEuler-25.09-x86_64.rar

  export ROOTFS="${SET_ROOTFS}"
  export ROOTFS_URL="https://github.com/yifengyou/kdev/releases/download/${SET_VENDOR}-rootfs/${ROOTFS}"
  export BUILD_TAG="${SET_ROOTFS}"

  echo "${ROOTFS_URL}" "${ROOTFS}" "${BUILD_TAG}"
elif [ "$SET_VENDOR" == "openanolis" ]; then
#curl -s "https://api.github.com/repos/yifengyou/kdev/releases/tags/openanolis-rootfs"   | jq -r '.assets[].name'
#AnolisOS-23.0-aarch64.rar
#AnolisOS-23.0-x86_64.rar
#AnolisOS-23.1-aarch64.rar
#AnolisOS-23.1-x86_64.rar
#AnolisOS-23.2-aarch64.rar
#AnolisOS-23.2-x86_64.rar
#AnolisOS-23.3-aarch64.rar
#AnolisOS-23.3-x86_64.rar
#AnolisOS-23.4-aarch64.rar
#AnolisOS-23.4-x86_64.rar
#AnolisOS-7.9-GA-aarch64-ANCK.rar
#AnolisOS-7.9-GA-aarch64-RHCK.rar
#AnolisOS-7.9-GA-x86_64-ANCK.rar
#AnolisOS-7.9-GA-x86_64-RHCK.rar
#AnolisOS-8.10-aarch64-ANCK.rar
#AnolisOS-8.10-aarch64-RHCK.rar
#AnolisOS-8.10-x86_64-ANCK.rar
#AnolisOS-8.10-x86_64-RHCK.rar
#AnolisOS-8.2-GA-aarch64-ANCK.rar
#AnolisOS-8.2-GA-aarch64-RHCK.rar
#AnolisOS-8.2-GA-x86_64-ANCK.rar
#AnolisOS-8.2-GA-x86_64-RHCK.rar
#AnolisOS-8.4-aarch64-ANCK.rar
#AnolisOS-8.4-aarch64-RHCK.rar
#AnolisOS-8.4-x86_64-ANCK.rar
#AnolisOS-8.4-x86_64-RHCK.rar
#AnolisOS-8.6-aarch64-ANCK.rar
#AnolisOS-8.6-aarch64-RHCK.rar
#AnolisOS-8.6-x86_64-ANCK.rar
#AnolisOS-8.6-x86_64-RHCK.rar
#AnolisOS-8.8-aarch64-ANCK.rar
#AnolisOS-8.8-aarch64-RHCK.rar
#AnolisOS-8.8-x86_64-ANCK.rar
#AnolisOS-8.8-x86_64-RHCK.rar
#AnolisOS-8.9-aarch64-ANCK.rar
#AnolisOS-8.9-aarch64-RHCK.rar
#AnolisOS-8.9-x86_64-ANCK.rar
#AnolisOS-8.9-x86_64-RHCK.rar

  export ROOTFS="${SET_ROOTFS}"
  export ROOTFS_URL="https://github.com/yifengyou/kdev/releases/download/${SET_VENDOR}-rootfs/${ROOTFS}"
  export BUILD_TAG="${SET_ROOTFS}"

  echo "${ROOTFS_URL}" "${ROOTFS}" "${BUILD_TAG}"
else
  exit 1
fi
