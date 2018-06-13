#!/bin/bash

PACKAGES_TO_REMOVE=(
    "sys-devel/llvm"
    "dev-libs/ppl"
    "app-admin/sudo"
    "x11-libs/gtk+:3"
    "x11-libs/gtk+:2"
    "dev-db/mariadb"
    "sys-fs/ntfs3g"
    "app-accessibility/at-spi2-core"
    "app-accessibility/at-spi2-atk"
    "sys-devel/base-gcc:4.7"
    "sys-devel/gcc:4.7"
    "net-print/cups"
    "dev-util/gtk-update-icon-cache"
    "dev-qt/qtscript"
    "dev-qt/qtchooser"
    "dev-qt/qtcore"
    "app-shells/zsh"
    "app-shells/zsh-pol-config"
    "dev-db/mysql-init-scripts"
    "dev-lang/ruby"
    "app-editors/vim"
    "dev-util/gtk-doc-am"
    "x11-apps/xset"
    "x11-themes/hicolor-icon-theme"
    "media-libs/tiff"
    "media-libs/jbig2dec"
    "dev-libs/libcroco"
    "app-text/qpdf"
    "media-fonts/urw-fonts"
    "app-text/libpaper"
    "dev-python/snakeoil"
    "dev-libs/atk"
    "dev-perl/DBI"
    "dev-perl/TermReadKey"
    "dev-perl/Test-Deep"
    "virtual/perl-IO-Zlib"
    "virtual/perl-Package-Constants"
    "virtual/perl-Term-ANSIColor"
    "virtual/perl-Time-HiRes"
    "app-text/asciidoc"
    "app-text/sgml-common"
    "virtual/python-argparse"
    "sys-power/upower"
    "dev-python/py"
    "dev-vcs/git"
    "dev-tcltk/expect"
    "app-admin/python-updater"
    "app-portage/eix"
    "app-portage/gentoolkit"
    "app-portage/gentoopm"
)

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
    "/usr/portage/metadata/md5-cache/*"
    "/var/log/emerge/*"
    "/var/log/entropy/*"
    "/root/* /root/.*"
    "/etc/zsh"

    "/post-update.sh"

    # cleaning licenses accepted
    "/usr/portage/licenses"
)

# Upgrading packages

rsync -av "rsync://rsync.at.gentoo.org/gentoo-portage/licenses/" "/usr/portage/licenses/" && ls /usr/portage/licenses -1 | xargs -0 > /etc/entropy/packages/license.accept && \
equo up && equo i --nodeps sys-apps/portage sys-apps/entropy app-admin/equo && equo u && \
echo -5 | equo conf update

# Cleanup
equo rm --deep --configfiles --force-system "${PACKAGES_TO_REMOVE[@]}"

# Remove compilation tools
equo rm --nodeps --force-system automake bison yacc gcc localepurge

# ensuring all is right
equo deptest
equo libtest

equo i app-misc/ca-certificates app-crypt/gnupg

equo security oscheck --assimilate

# Writing package list file
equo q list installed -qv > /etc/sabayon-pkglist

equo cleanup

# Cleanup
rm -rf "${FILES_TO_REMOVE[@]}"
