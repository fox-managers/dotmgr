# shellcheck shell=bash

util_get_file() {
	if [[ ${1::1} == / ]]; then
		REPLY="$1"
	else
		REPLY="$HOME/$1"
	fi
}

must_rm() {
	util_get_file "$1"
	local file="$REPLY"

	if [ -f "$file" ] && rm -f "$file"; then
		util.log_info "$file REMOVED"
	fi
}

must_rmdir() {
	util_get_file "$1"
	local dir="$REPLY"

	if [ -d "$dir" ] && rmdir "$dir"; then
		util.log_info "$dir REMOVED"
	fi
}

must_dir() {
	util_get_file "$1"
	local dir="$REPLY"

	if [ ! -d "$dir" ] && mkdir -p "$dir"; then
		util.log_info "$dir CREATED"
	fi
}

must_file() {
	util_get_file "$1"
	local file="$REPLY"

	if [ ! -f "$file" ] && mkdir -p "${file%/*}" && touch "$file"; then
		util.log_info "$file CREATED"
	fi
}

must_link() {
	util_get_file "$1"
	local src="$REPLY"

	util_get_file "$2"
	local link="$REPLY"

	# TODO
	# if [ -L "$link" ] && [ "$(readlink "$link")" = "$src" ]; then
	# if []
		# util.log_warn "Skipping symink from '$src' to '$link'"
	# else
		if ln -sfT "$src" "$link"; then
			util.log_info "$src SYMLINKED to $link"
		fi
	# fi
}

check_dot() {
	if [ -e "$HOME/$1" ]; then
		util.log_warn "File or directory '$1' EXISTS"
	fi
}

subcmd() {
	if ! [[ -v 'XDG_CONFIG_HOME' && -v 'XDG_DATA_HOME' && -v 'XDG_STATE_HOME' ]]; then
		printf '%s\n' "Error: XDG Variables must be set"
		exit 1
	fi


	if ! [[ -v 'XDG_CONFIG_HOME' && -v 'XDG_DATA_HOME' && -v 'XDG_STATE_HOME' ]]; then
		printf '%s\n' "Error: XDG Variables must be set"
		exit 1
	fi

	# Remove appended items to dotfiles
	for file in ~/.profile ~/.bashrc ~/.bash_profile "${ZDOTDIR:-$HOME}/.zshrc" "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"; do
		if [ ! -f "$file" ]; then
			continue
		fi

		printf '%s\n' "Cleaning '$file'"
	
		local file_string=
		while IFS= read -r line; do
			file_string+="$line"$'\n'

			if [[ "$line" == '# ---' ]]; then
				break
			fi
		done < "$file"; unset line

		printf '%s' "$file_string" > "$file"
	done; unset file

	# Create symlinks
	declare storage_home='/storage/ur/storage_home'
	declare storage_other='/storage/ur/storage_other'
	must_link "$storage_home/Dls" "$HOME/Dls"
	must_link "$storage_home/Docs" "$HOME/Docs"
	must_link "$storage_home/Music" "$HOME/Music"
	must_link "$storage_home/Pics" "$HOME/Pics"
	must_link "$storage_home/Vids" "$HOME/Vids"
	must_link "$storage_other/mozilla" "$HOME/.mozilla"
	must_link "$storage_other/ssh" "$HOME/.ssh"
	must_link "$storage_other/BraveSoftware" "$XDG_CONFIG_HOME/BraveSoftware"
	must_link "$storage_other/calcurse" "$XDG_CONFIG_HOME/calcurse"
	must_link "$storage_other/fonts" "$XDG_CONFIG_HOME/fonts"
	must_link "$storage_other/password-store" "$XDG_DATA_HOME/password-store"

	must_link "$HOME/Docs/Programming/challenges" "$HOME/challenges"
	must_link "$HOME/Docs/Programming/experiments" "$HOME/experiments"
	must_link "$HOME/Docs/Programming/git" "$HOME/git"
	must_link "$HOME/Docs/Programming/projects" "$HOME/projects"
	must_link "$HOME/Docs/Programming/repos" "$HOME/repos"
	must_link "$HOME/Docs/Programming/workspaces" "$HOME/workspaces"


	# Create directories for programs that require a directory to exist to use it
	must_dir "$XDG_STATE_HOME/history"
	must_dir "$XDG_DATA_HOME/maven"
	must_dir "$XDG_DATA_HOME"/vim/{undo,swap,backup}
	must_dir "$XDG_DATA_HOME"/nano/backups
	must_dir "$XDG_DATA_HOME/zsh"
	must_dir "$XDG_DATA_HOME/X11"
	must_dir "$XDG_DATA_HOME/xsel"
	must_dir "$XDG_DATA_HOME/tig"
	must_dir "$XDG_CONFIG_HOME/sage" # $DOT_SAGE
	must_dir "$XDG_DATA_HOME/gq/gq-state" # $GQ_STATE
	must_dir "$XDG_DATA_HOME/sonarlint" # $SONARLINT_USER_HOME
	must_file "$XDG_CONFIG_HOME/yarn/config"
	must_file "$XDG_DATA_HOME/tig/history"


	# Remove autogenerated dotfiles
	must_rm .bash_history
	must_rm .flutter
	must_rm .flutter_tool_state
	must_rm .gitconfig
	must_rm .gmrun_history
	must_rm .inputrc
	must_rm .lesshst
	must_rm .mkshrc
	must_rm .pulse-cookie
	must_rm .pam_environment
	must_rm .pythonhist
	must_rm .sqlite_history
	must_rm .viminfo
	must_rm .wget-hsts
	must_rm .zlogin
	must_rm .zshrc
	must_rm .zprofile
	must_rm .zcompdump
	must_rm "$XDG_CONFIG_HOME/zsh/.zcompdump"
	must_rmdir Desktop
	must_rmdir Documents
	must_rmdir Pictures
	must_rmdir Videos


	# check to see if these directories exist (they shouldn't)
	check_dot .elementary
	check_dot .ghc # Fixed in later releases
	check_dot .npm
	check_dot .scala_history_jline3
	check_dot .bootstrap
}