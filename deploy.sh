#!/bin/bash

CURRENT_DIR=`dirname $0`

# Ex: /var/www/subdomain.domain.tld
MAIN_DIR=$(cd `dirname $0` && cd .. && cd .. && pwd)

MAIN_REPO=$1
if [ "$MAIN_REPO" == "" ]; then
	echo "MAIN_REPO is mandatory"
	exit 1;	
fi

GIT_DEPLOY=$MAIN_DIR/private/git-deploy

GIT=$GIT_DEPLOY/gitrepo
WEB=$MAIN_DIR/web

function show_info() {
	echo
	echo "MAIN_DIR: $MAIN_DIR"
	echo "MAIN_REPO: $MAIN_REPO"
	echo "GIT_DEPLOY: $GIT_DEPLOY"
	echo "GIT: $GIT"
	echo "TMP: $TMP"
	echo "WEB: $WEB"
	echo
}

function remove_dir_contents() {
	cd "$1" || exit
	
	# Borramos todos los ficheros evitando el . y el .. para prevenir directory traversal
	find . -name . -o -prune -exec rm -rf -- {} +
}

function rebuild_dir() {
	if [ -d "$1" ]; then
		rm -rf $1
	fi
	mkdir -p $1	
}

function clone_git() {
	if [ -d "$GIT" ]; then		
		
		cd "$GIT" || exit
		
		echo "Checking out Main GIT Repo..."
		git fetch --all
	else
		echo "Cloning Main GIT Repo..."
		git clone --mirror $MAIN_REPO $GIT --bare
	fi	
}

function checkout_git() {
	echo "Checking out..."
	git --work-tree=$WEB --git-dir=$GIT checkout -f
}

show_info

clone_git

remove_dir_contents "$WEB"

checkout_git

echo "Done!"
