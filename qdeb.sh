#!/bin/bash
#
# Quickly (cross) debootstrap a debian rootfs with additional packages
# 
# You have to provide arch and debian version.
# You may also provide a sources.list configuration and additional
# whitelist packages to be installed or blacklist packages to be removed.
#
# You need to run this script as root or with sudo.

usage() {
  echo -e "Usage: ARCHITECTURE VERSION [OPTIONS]

Available options:
-d dir\t\tDebootstrap to dir
-s sourcelist\tsource.list configuration
-w whitelist\tList of packages to install
-b blacklist\tList of packages to remove
-n hostname\tSet a hostname" 1>&2
  exit 1
}

# Check for mandatory arch and version
if [ $# -lt 2 ]; then
  usage
  exit
fi

# Set mandatory parameters
arch="$1"
version="$2"
shift 2

# Set default values for optional parameters
hostname="qdeb"
repo="http://ftp.debian.org/debian/"
dir="rootfs"
white=false
black=false
surce=false

# Process optional parameters
options='d:hw:b:s:n:'
while getopts $options option; do
	case $option in
    d)
      dir=${OPTARG}
      ;;
    w)
      whiteList=${OPTARG}
      white=true
      ;;
    b)
      blackList=${OPTARG}
      black=true
      ;;
    s)
      sourceList=${OPTARG}
      source=true
      ;;
    n) 
      hostname=${OPTARG}
      ;;
    h)
      usage
      exit 1
      ;;
    \?)
      echo "Unknown option: -$OPTARG" >&2; exit 1
      ;;
    :)
      echo "Missing option argument for -$OPTARG" >&2
      exit 1
      ;;
    *)
      echo "Unimplemented option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Debootstrap the base system
qemu-debootstrap --foreign --arch "${arch}" "${version}" "${dir}" "${repo}"

# Write hostname
echo "${hostname}" > ${dir}/etc/hostname

# Write package list
if $source; then
  while read line; do
    echo $line >> ${dir}/etc/apt/sources.list
  done < ${sourceList}
fi

# Update the package list
chroot "${dir}" apt-get update

# Install packages from whitelist
if $white; then
  chroot "${dir}" apt-get -y install `tr '\n' ' ' < "${whiteList}"`
fi

# Remove packages from blacklist
if $black; then
  chroot "${dir}" apt-get -y remove --purge `tr '\n' ' ' < "${blackList}"`
fi
