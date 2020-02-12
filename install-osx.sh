#!/bin/bash

# Settup Mac OS X
# if you want to get this script from github, to install git, you need to install command line tools with xcode-select --install

# Move on directory of this script
DIR=$(dirname $0)
cd $DIR


echo ""
unset input
echo "###  Do you want to do? "
echo "##   1 - Install Xcode"
echo "##   2 - Install Homebrew"
echo "##   3 - Setup iOS environment* (require Xcode & Homebrew)"
echo "##   4 - Install Oh my zsh"
echo "##   5 - Setup MacOS & Install softwares with cask"
printf "##   >   "
read input
echo ""
echo ""



# Install Xcode
if [[ $input == 1 ]]; then 



	# install command line tools and ask before if you need it
	unset input
	echo "Have you already install command line tools? [y/n]"
	read input
	if [[ $input != y && $input != Y ]];
	then 

		xcode-select --install
		    
		unset input
		#while [[ ! ${input} = y ]]; do
		while [[ ${input} != y && $input != Y ]]; do
		    echo "Have you finished to install command line tools? [y/n]"
    	read input
	done
	#echo "Xcode is installed :  ${input}"
	#echo "Xcode is installed :  $input"

	echo 'command line tools is installed'
	fi



# Install brew
elif [[ $input == 2 ]]; then 


	# install Homebrew
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	tmp=$(brew -v)
	echo '$tmp installed'
	wait



# Setup iOS environment* (require Xcode & Homebrew)
elif [[ $input == 3 ]]; then 



	# add git alias config
	cp .gitconfig $HOME/.gitconfig

	# Inception:: install a wew OS ¯\_(ಥ‿ಥ)_/¯ 
	brew install emacs

	# install IOS environment with cocoapods
	# update ruby gem
	sudo gem update -n /usr/local/bin --system

	# install fastlane
	brew install fastlane

	# install carthage
	brew install carthage

	echo install Xcode environnement
	# install cocoapods

	# Display the building time on xcode HUD
	defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES

	#sudo gem install cocoapods
	sudo gem install -n /usr/local/bin cocoapods
	# clone the repository on ~/.cocoapods/
	pod setup
	wait

	# install command-line to generate your project’s documentation 
	gem install jazzy

	# install SwiftLint to enforce Swift style and conventions
	brew install swiftlint

	# install bundle exec
	sudo gem install -n /usr/local/bin bundler



# Install Oh my zsh
elif [[ $input == 4 ]]; then 



	# change order on PATH environment
	printf "\nexport PATH=/usr/local/bin:/usr/local/sbin:\$PATH\n" >> $HOME/.bash_profile
	echo "PATH => $(cat $HOME/.bash_profile)"
	printf "\nalias tree=\"find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'\"\n" >> $HOME/.bash_profile
	source $HOME/.bash_profile

	# Install Oh my zsh
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"



# Install softwares with cask
elif [[ $input == 5 ]]; then 



	# Settup animation duration to apply expose
	defaults write com.apple.dock expose-animation-duration -float 0.1
	defaults write com.apple.Dock autohide-delay -float 0
	killall Dock

	# Allow the selection of text on QuickLoock
	defaults write com.apple.finder QLEnableTextSelection -bool true && killall Finder

	# Allow Apple crash reports like notifications
	defaults write com.apple.CrashReporter UseUNC 1

	echo "install quicklook plugin"
	brew cask install qlcolorcode
	brew cask install qlstephen
	brew cask install qlmarkdown
	brew cask install quicklook-json
	brew cask install qlprettypatch
	brew cask install quicklook-csv
	brew cask install betterzipql
	brew cask install webpquicklook
	brew cask install qlimagesize
	brew cask install suspicious-package
	brew cask install provisionql
	brew cask install qlvideo
	wait

	echo "install of my softs"
	# brew cask install google-chrome # it's already installed
	brew cask install firefox
	brew cask install handbrake
	brew cask install spectacle
	brew cask install steam
	brew cask install sublime-text
	brew cask install textmate
	brew cask install vlc
	brew cask install beardedspice
	brew cask install spotify
	brew cask install spotify-notifications
	# brew cask install spotifree
	brew cask install bonjour-browser
	brew cask install istat-menus
	brew cask install onyx
	brew cask install postman
	brew cask install 4k-video-downloader
	brew cask install 4k-youtube-to-mp3
	brew cask install sequential
	brew cask install wwdc
	wait

	brew update && brew upgrade && brew cleanup
	wait



else



	echo "I don't understand your choice..."
	echo ""
	echo "###  :("
	echo ""



fi

unset input
exit 0