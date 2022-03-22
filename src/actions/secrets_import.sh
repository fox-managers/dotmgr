# shellcheck shell=bash

# Name:
# Import Secrets
#
# Description:
# This imports your GPG keys. It imports it from your shared drive mounted under /storage

action() {
	local -r fingerprints=('6EF89C3EB889D61708E5243DDA8EF6F306AD2CBA' '4C452EC68725DAFD09EC57BAB2D007E5878C6803')

	if [ ! -e '/proc/sys/kernel/osrelease' ]; then
		print.die "File '/proc/sys/kernel/osrelease' not found"
	fi

	if [[ "$(</proc/sys/kernel/osrelease)" =~ 'WSL2' ]]; then
		# WSL
		print.info "Copying SSH keys from windows side"
		local name='Edwin'
		for file in "/mnt/c/Users/$name/.ssh"/*; do
			if [ ! -f "$file" ]; then
				continue
			fi

			if [[ "${file##*/}" = @(config|environment|known_hosts) ]]; then
				continue
			fi

			mkdir -vp ~/.ssh
			cp -v "$file" ~/.ssh
		done; unset -v file

		local gpgDir="/mnt/c/Users/$name/AppData/Roaming/gnupg"
		if [ -d "$gpgDir" ]; then
			gpg --homedir "$gpgDir" --armor --export-secret-key "${fingerprints[@]}" | gpg --import
		else
			print.warn "Skipping importing GPG keys as directory does not exist"
		fi
	else
		# Not WSL
		local gpgDir='/storage/ur/storage_other/gnupg'
		if [ -d "$gpgDir" ]; then
			gpg --homedir "$gpgDir" --armor --export-secret-key "${fingerprints[@]}" | gpg --import
		else
			print.warn "Skipping importing GPG keys from /storage/ur subdirectory"

			find_mnt_usb '6044-5CC1' # WET
			local block_dev_target=$REPLY

		fi
	fi
}