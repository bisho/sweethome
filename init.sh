#!/bin/bash
# Author: Guillermo Pérez <bisho@tuenti.com>
#
# Initialization script for sweethome
#
# It backups the present files and replaces them with
# links to the sweethome repository.

if [ -z "$BASH_VERSION" ]; then
	echo "Execute this script with bash, please"
	exit 1;
fi

# Files in the repo that should not be linked directly into the home
EXCLUDES="^\(dotfiles\|.*\.sh\|.*\.md\)$"

function listRepoFiles {
	listDirFiles "dotfiles/"
	listDirFiles "private/dotfiles/"
	listDirFiles "" "$EXCLUDES"
}

function listHomeFiles {
	listRepoFiles | calculateFileDestination
}

function listDirFiles {
	local DIR=$1
	local EXCLUDES=$2
	local name
	ls "$REPO_PATH/$DIR" |
		( test -n "$EXCLUDES" && grep -ve "$EXCLUDES" || cat - ) |
		while read name; do
			echo "$DIR$name"
		done
}

function calculateFileDestination {
	local PRINTBOTH=$1
	local name
	while read name; do
		[ -n "$PRINTBOTH" ] && echo "$name"

		if [ -d $REPO_PATH/$name ]; then
			# For directories:
			# Replace all ocurrences of '.' with '/'
			name="${name//\./\/}"
		fi

		# Replace starting substring 'dotfiles/' with '.'
		name="${name/#dotfiles\//.}"
		# Replace starting substring 'private/dotfiles/' with '.'
		name="${name/#private\/dotfiles\//.}"
		# Replace starting substring 'private' with '.private'
		name="${name/#private/.private}"

		echo "$name"
	done
}

function linkFiles {
	local BACKUP=$(tempfile -d ~/ -p 'sweet' -s '.tgz')
	local src
	local dest 

	echo
	echo "* Creating backup..."
	tar cfz $BACKUP $(listHomeFiles) 2>/dev/null
	echo "  You can find old files in $BACKUP"

	echo
	echo "* Linking files..."
	listRepoFiles | calculateFileDestination 1 | while read src; do
		read dest
		echo "  - Linking ~/$dest -> $SHORT_REPO_PATH/$src"

		src="$REPO_PATH/$src"
		dest="$HOME/$dest"
		
		rm -rf $dest
		mkdir -p "$(dirname $dest)"
		ln -s "$src" "$dest"
	done
}

function preInstall {
	git submodule init
	git submodule update
}

function postInstall {
    echo "Done!"
    echo
    echo "Now we will launch vim bundle installation."
    echo -n "Press ENTER to continue..."
    read
	vim +BundleInstall! +BundleClean +q +q
    echo
}

function define_repo_path() {
	# Extract script path (it's the repo path)
	REPO_PATH=$(dirname "${BASH_SOURCE[0]}");
	REPO_PATH=$(readlink -f "$REPO_PATH");
	SHORT_REPO_PATH="${REPO_PATH/#$HOME/~}"
}

define_repo_path

echo
echo "** Initializing home directory with 'sweethome' repo in $REPO_PATH"
echo
echo "The following files will be REPLACED by symbolic links to this"
echo "sweethome repo:"
echo
listRepoFiles | calculateFileDestination 1 | while read src; do
	read dest
	echo "  - ~/$dest -> $SHORT_REPO_PATH/$src"
done
echo
echo "Note: A Backup of the original files will be created."
echo "Do you want to continue?"

while true; do
	echo -n "(y/n): ";
	read response;
	case "$response" in
		[yY])
		preInstall
		linkFiles
		postInstall
		break;
		;;
		[nN])
		echo "Aborted!";
		break;
		;;
	esac
done
