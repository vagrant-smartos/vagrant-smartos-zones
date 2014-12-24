#!/bin/bash

# This installs ruby in a location that test-kitchen
# will use with busser to run integration tests.

check_platform() {
  echo $(uname -s)
}

install_fake_chef() {
  mkdir -p /opt/chef/embedded/bin
}

install_ruby() {
  local platform=$(check_platform)
  case ${platform} in
    SunOS)
      install_ruby_smartos
      ;;
    Linux)
      install_ruby_linux
      ;;
  esac
}

install_ruby_linux() {
  apt-get install ruby
}

install_ruby_smartos() {
  pkgin -y in ruby
}

symlink_ruby() {
  local ruby=$(local_ruby)
  local gem=$(local_gem)
  ln -s ${ruby} /opt/chef/embedded/bin/ruby
  ln -s ${gem} /opt/chef/embedded/bin/gem
}

local_ruby() {
  echo $(which ruby)
}

local_gem() {
  echo $(which gem)
}

main() {
  install_fake_chef
  install_ruby
  symlink_ruby
}

main
