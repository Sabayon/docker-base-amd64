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
   "/usr/bin/sabayon-brokenlinks"

   # Cleaning portage metadata cache
   "/usr/portage/metadata"
   "/usr/portage/profiles"
   "/var/lib/layman"
   
   "/var/log/emerge"
   "/var/log/entropy"
   "/etc/zsh"

   "/post-update.sh"

   # cleaning licenses accepted
   "/usr/portage/licenses"
)

export ETP_NONINTERACTIVE=1

check_brokenlinks () {

  wget https://raw.githubusercontent.com/Sabayon/devkit/develop/sabayon-brokenlinks -O /usr/bin/sabayon-brokenlinks
  chmod a+x /usr/bin/sabayon-brokenlinks

  sabayon-brokenlinks --force

  rm /usr/bin/sabayon-brokenlinks
}

update_mirrors_list () {

  wget https://raw.githubusercontent.com/Sabayon/sbi-tasks/master/infra/mirrors.yml -O /tmp/mirrors.yml
  wget https://raw.githubusercontent.com/Sabayon/sbi-tasks/master/infra/scripts/sabayon-repo-generator -O /tmp/sabayon-repo-generator
  chmod a+x /tmp/sabayon-repo-generator

  local f=""
  local descr=""
  local name=""
  local reposdir="/etc/entropy/repositories.conf.d"
  local repofiles=(
    "entropy_sabayon-limbo"
    "entropy_sabayonlinux.org"
    "entropy_sabayon-weekly"
  )

  for repo in ${repofiles[@]} ; do
    if [ -e "${reposdir}/${repo}" ] ; then
      f=${reposdir}/${repo}
    else
      f=${reposdir}/_${repo}
    fi

    if [[ ${repo} =~ .*limbo* ]] ; then
      descr="Sabayon Limbo Testing Repository"
    else
      descr="Sabayon Linux Official Repository"
    fi

    name=${repo//entropy_/}

    /tmp/sabayon-repo-generator --mirror-file /tmp/mirrors.yml --descr "${descr}" --name "${name}" --to "${f}"

  done

  rm -v /tmp/sabayon-repo-generator
  rm -v /tmp/mirrors.yml
}

# Upgrading packages

rsync -av "rsync://rsync.at.gentoo.org/gentoo-portage/licenses/" "/usr/portage/licenses/" && \
ls /usr/portage/licenses -1 | xargs -0 > /etc/entropy/packages/license.accept && \
equo up && equo i --nodeps sys-apps/portage sys-apps/entropy app-admin/equo dev-lang/perl && equo u && \
echo -5 | equo conf update

# Update mirrors
equo i shyaml
update_mirrors_list
equo rm shyaml

check_brokenlinks

PACKAGES_TO_REMOVE=($(equo q list installed -qv))

# Cleanup
# Handling install/removal of packages specified in env
for i in "${PACKAGES_TO_REMOVE[@]}"
do
    echo "===== Attempt to remove $i ====="
    equo rm --configfiles "$i"
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

mkdir -p /var/lib/layman
touch /var/lib/layman/make.conf
