#!/usr/bin/env bash

RUBY_VERSION_FAMILY="${RUBY_VERSION:0:3}"
RUBY_ARCHIVE="ruby-$RUBY_VERSION.tar.bz2"
RUBY_SRC_DIR="ruby-$RUBY_VERSION"
RUBY_URL="${RUBY_URL:-http://ftp.ruby-lang.org/pub/ruby/${RUBY_VERSION_FAMILY}/$RUBY_ARCHIVE}"

RUBYGEMS_VERSION="2.0.3"
RUBYGEMS_ARCHIVE="rubygems-$RUBYGEMS_VERSION.tgz"
RUBYGEMS_SRC_DIR="rubygems-$RUBYGEMS_VERSION"
RUBYGEMS_URL="http://production.cf.rubygems.org/rubygems/$RUBYGEMS_ARCHIVE"

if [[ "$RUBY_VERSION_FAMILY" == "1.8" ]]; then
	PATCHES+=("$RUBY_DIR/patches/1.8-stdout-rouge-fix.patch")
fi

#
# Configures Ruby.
#
function configure_ruby()
{
	log "Configuring ruby $RUBY_VERSION ..."

	if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
		./configure --prefix="$INSTALL_DIR" \
			    --with-opt-dir="$(brew --prefix openssl):$(brew --prefix readline):$(brew --prefix libyaml):$(brew --prefix gdbm):$(brew --prefix libffi)" \
			    $CONFIGURE_OPTS
	else
		./configure --prefix="$INSTALL_DIR" $CONFIGURE_OPTS
	fi
}

#
# Compiles Ruby.
#
function compile_ruby()
{
	log "Compiling ruby $RUBY_VERSION ..."
	make
}

#
# Installs Ruby into $INSTALL_DIR
#
function install_ruby()
{
	log "Installing ruby $RUBY_VERSION ..."
	make install
}

function post_install()
{
	if [[ "$RUBY_VERSION_FAMILY" == "1.8" ]]; then
		cd "$SRC_DIR"
		log "Installing rubygems"
		download "$RUBYGEMS_URL" "$SRC_DIR"
		extract "$SRC_DIR/$RUBYGEMS_ARCHIVE"
		"$INSTALL_DIR"/bin/ruby "$SRC_DIR/$RUBYGEMS_SRC_DIR/setup.rb"
	fi
}
