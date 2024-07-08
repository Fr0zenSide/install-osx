#!/bin/bash

# Sources
# - https://alwold.com/posts/using-mitmproxy-with-ios-simulator
# - https://vladzz.medium.com/setting-up-mitmproxy-on-ios-simulator-4a7f9889c2fc

# the tail command will skip the first line because it's an informational message
interfaces="$(networksetup -listallnetworkservices | tail +2)" 

IFS=$'\n' # split on newlines in the for loops

for interface in $interfaces; do
  echo "Setting proxy on $interface"
  networksetup -setwebproxy "$interface" localhost 8080
  networksetup -setwebproxystate "$interface" on
  networksetup -setsecurewebproxy "$interface" localhost 8080
  networksetup -setsecurewebproxystate "$interface" on
done

mitmproxy

for interface in $interfaces; do
  echo "Disabling proxy on $interface"
  networksetup -setwebproxystate "$interface" off
  networksetup -setsecurewebproxystate "$interface" off
done
