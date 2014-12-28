#!/bin/bash

# Settup Mac OS X
# if you want to get this script from github, to install git, you need to install command line tools with xcode-select --install

# Settup animation duration to apply expose
defaults write com.apple.dock expose-animation-duration -float 0.15
killall Dock

# Allow the selection of text on QuickLoock
defaults write com.apple.finder QLEnableTextSelection -bool true && killall Finder

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
#echo "xCode is installed :  ${input}"
#echo "xCode is installed :  $input"

echo 'command line tools is installed'
fi


# add git alias config
cp .gitconfig $HOME/.gitconfig

# install Homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
tmp=$(brew -v)
echo '$tmp installed'
wait

# install brew cask, it use to install others softs
brew install caskroom/cask/brew-cask
wait

echo "install dev environment (node, python, pip, venv, postgres)"
brew install node
tmp=$(node -v)
echo "node $tmp installed"
tmp=$(npm -v)
echo "npm v$tmp installed"
# check if you need to launch the next command to update npm
# npm install -g npm@latest

brew install python
pip install virtualenv
wait

brew install postgres
# creating the datbabase
initdb /usr/local/var/postgres -E utf8
wait
# start Postgres at login and running on the background
mkdir -p ~/Library/LaunchAgents
ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist

# install ffmpeg
brew install ffmpeg

# change order on PATH environment
tmp=$(cat $HOME/.bash_profile)
printf "$tmp\nexport PATH=/usr/local/bin:/usr/local/sbin:\$PATH" > $HOME/.bash_profile
echo "PATH => $(cat $HOME/.bash_profile)"
source $HOME/.bash_profile
wait

echo "install quicklook plugin"
brew cask install qlcolorcode
brew cask install qlstephen
brew cask install qlmarkdown
brew cask install quicklook-json
brew cask install qlprettypatch
brew cask install quicklook-csv
brew cask install betterzipql
brew cask install webpquicklook
brew cast install qlimagesize
brew cask install suspicious-package
brew cask install provisionql
brew cask install qlvideo
brew cask install quickpvr
wait

echo "install of my softs"
brew cask install gfxcardstatus
brew cask install google-chrome
brew cask install firefox
brew cask install alfred
brew cask install handbrake
brew cask install spectacle
brew cask install steam
brew cask install skype
brew cask install sublime-text
brew cask install vlc
brew cask install utorrent
brew cask install vox
brew cask install charles
brew cask install paragon-ntfs
brew cask install paragon-extfs
brew cask install istat-menus
brew cask install unity-web-player
brew cask install flash-player
brew cask install logitech-control-center
brew cask install onyx
brew cask install apikitchen
brew cask install 4k-video-downloader
brew cask install 4k-youtube-to-mp3
brew cask install chromecast
brew cask install sequential
wait

# If it doesn't work, you can manually add /opt/homebrew-cask/Caskroom to the Search Scope in Alfred Preferences 
brew cask alfred
brew update && brew upgrade brew-cask && brew cleanup
wait

sudo reboot
