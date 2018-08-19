#!/bin/bash

FILES_TO_REMOVE=(
   "/.viminfo"
   "/.history"
   "/.zcompdump"
   "/var/log/emerge.log"
   "/var/log/emerge-fetch.log"
   "/usr/portage/licenses"
   "/etc/entropy/packages/license.accept"
   "/equo-rescue-generate.exp"
    "/equo.sql"
    "/generate-equo-db.sh"
    "/post-upgrade.sh"
    "/sabayon-configuration-build.sh"
    "/sabayon-configuration.sh"
    "/post-upgrade.sh"

    # Cleaning portage metadata cache
    "/usr/portage/metadata"
    "/var/log/emerge"
    "/var/log/entropy"
    "/etc/zsh"
    "/var/lib/layman/sabayon"
    "/var/lib/layman/sabayon-distro"
    
    "/post-update.sh"

    # cleaning licenses accepted
    "/usr/portage/licenses"
)

# Upgrading packages

rsync -av "rsync://rsync.at.gentoo.org/gentoo-portage/licenses/" "/usr/portage/licenses/" && ls /usr/portage/licenses -1 | xargs -0 > /etc/entropy/packages/license.accept && \
equo up && equo i --nodeps sys-apps/portage sys-apps/entropy app-admin/equo && equo u && \
echo -5 | equo conf update

PACKAGES_TO_REMOVE=($(equo q list installed -qv))

# Cleanup
# Handling install/removal of packages specified in env
for i in "${PACKAGES_TO_REMOVE[@]}"
do
    echo "===== Attempt to remove $i ====="
    equo rm --deep --configfiles "$i"
done

# Remove compilation tools
equo rm --nodeps --force-system automake bison yacc gcc localepurge

# ensuring all is right
equo deptest
equo libtest

equo i app-misc/ca-certificates app-crypt/gnupg

equo security oscheck --assimilate

# Writing package list file
equo q list installed -qv > /etc/sabayon-pkglist

cat /etc/sabayon-pkglist

equo cleanup

# Cleanup
rm -rf "${FILES_TO_REMOVE[@]}"
