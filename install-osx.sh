#!/bin/bash

# Settup Mac OS X
# if you want to get this script from github, to install git, you need to install command line tools with xcode-select --install

# Move on directory of this script
DIR=$(dirname $0)
cd $DIR


echo ""
unset input
echo "###  Do you want to do? "
echo "##   1 - Install Command Line Tools in MacOS"
echo "##   2 - Install Homebrew"
echo "##   3 - Install Xcode* (require Homebrew and use mas)"
echo "##   4 - Setup iOS environment* (require Xcode & Homebrew)"
echo "##   5 - Install Oh my zsh"
echo "##   6 - Setup MacOS & Install softwares with cask & mas"
printf "##   >   "
read input
echo ""
echo ""



# Install Command Line Tools in MacOS
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



	#echo "Xcode is installed :  $input"

	echo 'command line tools is installed'



# Install Xcode* (require Homebrew and use mas)
elif [[ $input == 3 ]]; then 


    # intall MAS (Mac App Store command line interface)
    brew install mas
    mas install 497799835 # identifier of xcode => mas search xcode
    # we can also use mas lucky xcode => but the day your have another app in first result, you don't install xcode 😅
    # You have to agree the Xcode license. Please resolve this by running:
    echo 'You have to agree the Xcode license. Please enter the admin password. \nRunning > $sudo xcodebuild -license accept'
    sudo xcodebuild -license accept



# Setup iOS environment* (require Xcode & Homebrew)
elif [[ $input == 4 ]]; then 



	# add git alias config
	cp .gitconfig $HOME/.gitconfig

	# Inception:: install a wew OS ¯\_(ಥ‿ಥ)_/¯ 
	brew install emacs

	# helper for see tree in terminal
	brew install tree

	# install IOS environment with cocoapods
	# update ruby gem
	sudo gem update -n /usr/local/bin --system

	# install fastlane
	brew install fastlane

	echo install Xcode environnement

	# Display the building time on xcode HUD
	defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES
	
	# install carthage
	brew install carthage

	
	# install cocoapods
	#sudo gem install -n /usr/local/bin cocoapods # Doesn't work in time from macOS Catalina (10.15.x)
	brew install cocoapods 
	# clone the repository on ~/.cocoapods/
	pod setup
	wait

	# install sourcery
	brew install sourcery

	# install command-line to generate your project’s documentation 
	gem install jazzy

	# install SwiftLint to enforce Swift style and conventions
	brew install swiftlint

	# install bundle exec
	sudo gem install -n /usr/local/bin bundler

	# install xcpretty
	sudo gem install -n /usr/local/bin xcpretty



# Install Oh my zsh
elif [[ $input == 5 ]]; then 



	# change order on PATH environment
	printf "\nexport PATH=/usr/local/bin:/usr/local/sbin:\$PATH\n" >> $HOME/.bash_profile
	echo "PATH => $(cat $HOME/.bash_profile)"
	printf "\nalias tree=\"find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'\"\n" >> $HOME/.bash_profile
	source $HOME/.bash_profile

	# Install Oh my zsh
	sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"



# Install softwares with cask
elif [[ $input == 6 ]]; then 



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
	# brew cask install betterzipql # Error: Cask 'betterzipql' is unavailable: No Cask with this name exists.
	brew cask install webpquicklook
	brew cask install qlimagesize
	brew cask install suspicious-package
	brew cask install provisionql
	brew cask install qlvideo
	wait

	echo "install of my softs throught cask"
	brew cask install google-chrome # it's already installed
	brew cask install srware-iron
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
	brew cask install istat-menus
	brew cask install onyx
	brew cask install postman
	brew cask install 4k-video-downloader
	brew cask install 4k-youtube-to-mp3
	brew cask install sequential
	brew cask install wwdc
	brew cask install transmit
	brew cask install aerial
	brew cask install whatsapp
	brew cask install flixtools
	brew cask install motrix
	brew cask install coconutbattery
	brew cask install wintertime
	wait

	echo "install of my softs throught mas"
	mas install 425424353  # identifier of The Unarchiver     (4.2.0)
	mas install 736189492  # Notability                       (4.2.4)
	mas install 1330801220 # Paste JSON as Code • quicktype   (8.2.22)
	mas install 1381004916 # Discovery - DNS-SD Browser       (2.0.3)
	mas install 1380446739 # InjectionIII                     (1.8)
	mas install 1102494854 # System Designer                  (4.4.0)
	mas install 824183456  # Affinity Photo                   (1.8.1)
	mas install 824171161  # Affinity Designer                (1.8.1)
	mas install 461369673  # VOX: MP3 & FLAC Music Player     (3.3.17)
	# TODO: Add my new tools of productivity
	mas lucky "Planny 3 Listes intelligentes"
	mas lucky "Tot"
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
