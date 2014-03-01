# qdeb - quick debootstrap

Quickly (cross) debootstrap a debian rootfs with additional packages
 
You have to provide arch and debian version.
You may also provide a sources.list configuration and additional
whitelist packages to be installed or blacklist packages to be removed.

You need to run this script as root or with sudo.

    Usage: ARCHITECTURE VERSION [OPTIONS]

    Available options:
    -d dir		Debootstrap to dir
    -s sourcelist	source.list configuration
    -w whitelist	List of packages to install
    -b blacklist	List of packages to remove
    -n hostname	Set a hostname
