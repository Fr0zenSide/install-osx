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
echo "##   2 - Install Homebrew, Oh my zsh and my terminal env (emacs, tmux, fzf, kitty, etc.)"
echo "##   3 - Install xcodes (via brew)"
echo "##   4 - Setup iOS environment* (require Xcode & Homebrew)"
echo "##   5 - Install ruby env to iOS development"
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



# Install brew / oh my zsh / terminal env
elif [[ $input == 2 ]]; then 


    
    # install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"

    tmp=$(brew -v)
    echo '$tmp installed'

    
    # Inception:: install a new OS ¯\_(ಥ‿ಥ)_/¯ 
    brew install emacs
    brew services start emacs 

    
    # install oh my zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    wait
    
    # add brew to zshrc
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zshrc


    # add git alias config
    # Keep to copy gitconfig instead to add in dotfiles
    # 'coz when you add [maintenance]
    # $ git maintenance start ~/workspaces/repo_folder
    # your .gitconfig depend of the project your listen with maintenance
    cp .gitconfig $HOME/.gitconfig

    
    # helper for regexp and fzf search in terminal
    brew install tre

    
    echo "install oh my zsh plugins"
    cd $HOME/.oh-my-zsh/custom/plugins
    git clone https://github.com/zsh-users/zsh-completions.git
    git clone https://github.com/zsh-users/zsh-autosuggestions.git
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
    cd $DIR
    echo "Apply installed omz pluglins in .zshrc"

    echo "" >> $HOME/.zshrc
    echo "# add zsh-completions to source path of zsh\n" >> $HOME/.zshrc
    echo "fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src" >> $HOME/.zshrc
    # replace plugins in ~/.zshrc with sed :
    # plugins=(
    #   git
    #   // zsh-completions # rm because doesn't work cf. https://github.com/zsh-users/zsh-completions/issues/603 
    #   zsh-autosuggestions
    #   zsh-syntax-highlighting
    # )
    sed -i '' -e 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' $HOME/.zshrc
    
    
    # Set default editor
    echo '\n# Setup default code editors' >> $HOME/.zshrc
    echo 'export EDITOR=emacs' >> $HOME/.zshrc
    echo 'export VISUAL="$EDITOR"' >> $HOME/.zshrc

    
    # use GNU stow to create symlinks of dotfiles in home directory
    brew install stow
    cd dotfiles && stow -t ~/ . && cd ../

    
    # Install terminal tools
    brew install tmux
    # with stow you don't need to copy this dotfile anymore
    # cp .tmux.conf $HOME/.tmux.conf
    # enable copy and paste in tmux
    brew install reattach-to-user-namespace

    # Minimal tmux setup (install tmux package manager + source new conf)
    # set-environment -g TMUX_PLUGIN_MANAGER_PATH '~/.config/tmux/plugins/'
    echo "" >> $HOME/.zshrc
    echo "# Export tmux env variables" >> $HOME/.zshrc
    echo "export TMUX_PLUGIN_MANAGER_PATH='~/.config/tmux/plugins'" >> $HOME/.zshrc
    # add in backup the plugins system in .tmux.conf file
    # git clone https://github.com/tmux-plugins/tpm ${TMUX_PLUGIN_MANAGER_PATH}/tpm
    tmux source ~/.config/tmux/.tmux.conf
    tmux set-option -g display-time 4000

    
    # Generaly you can add XDG_CONFIG_HOME ▶︎ ~/Library/Preferences/
    echo "" >> $HOME/.zshrc
    echo "# Export default linux equivalent env variables" >> $HOME/.zshrc
    echo 'export XDG_CONFIG_HOME="$HOME/.config"' >> $HOME/.zshrc
    echo 'export XDG_DATA_HOME="$HOME/.local/share"' >> $HOME/.zshrc
    echo 'export XDG_STATE_HOME="$HOME/.local/state"' >> $HOME/.zshrc
    echo 'export XDG_CACHE_HOME="$HOME/.cache"' >> $HOME/.zshrc

    
    # tools.sh is my custom tools like tmux function
    # with stow you don't need to copy this script anymore
    # cp .tools.sh $HOME/dotfiles/tools.sh
    echo "" >> $HOME/.zshrc
    echo "# link .tools.sh with zsh func" >> $HOME/.zshrc
    echo 'source ~/.config/scripts/tools.sh' >> $HOME/.zshrc

    
    brew install bat
    echo "" >> $HOME/.zshrc
    echo "# Replace cat with bat" >> $HOME/.zshrc
    echo 'alias cat="bat --paging=never --plain"' >> $HOME/.zshrc
    echo 'export BAT_THEME="Catppuccin Frappe"' >> $HOME/.zshrc
    mkdir -p "$(bat --config-dir)/themes"

    
    # brew install wget2
    brew install fzf # Require zsh
    # Set up fzf key bindings and fuzzy completion
    echo "" >> $HOME/.zshrc
    echo "# Set up fzf key bindings and fuzzy completion" >> $HOME/.zshrc
    echo 'source <(fzf --zsh)' >> $HOME/.zshrc
    
    # install thefuck to auto fix typo in cli
    # you have custom alias with ff in tools.sh
    brew install thefuck
    echo "" >> $HOME/.zshrc
    echo "# thefuck alias binding => fuck()" >> $Home/.zshrc
    echo 'eval $(thefuck --alias)' >> $HOME/.zshrc

    
    # install btop => a better htop
    brew install btop

    
    # install my new terminal ? => alacritty
    # brew install alacritty

    
    # install my new terminal ? => kitty
    brew install kitty	

        
    # helper for see tree in terminal | can open result in $EDITOR with eXX
    # brew install tree
    brew install tre-command
    echo "" >> $HOME/.zshrc
    echo "# Add tree helper called tre | can open result in $EDITOR with eXX" >> $HOME/.zshrc
    echo 'tre() { command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null; }' >> $HOME/.zshrc
    echo 'source /tmp/tre_aliases_$USER' >> $HOME/.zshrc

    
    # Create workspaces and add symlinks to go fast to xcode folders (cd ~/.wsx)

    mkdir -p ~/Documents/Workspaces/xcode
    ln -s ~/Documents/Workspaces/ ~/.ws
    ln -s ~/Documents/Workspaces/xcode/ ~/.wsx
    echo "Symlinks to Wokspaces added to env (~/.ws & ~/.wsx)"
    
    
    # When you setup your project with a git repo for daily tasks
    # go to project forlder
    # launch $ git maintenance start
    # now git prefetch automatically the remote code
    echo ""
    echo "------------------------------------------------"
    echo ""
    echo "------------------- Tips -----------------------"
    echo ""
    echo "To track a project with git in your daily flow"
    echo "Move to the root project & use git maintenance:"
    echo ""
    echo "$ cd ~/wsx/plop && git maintenance start"
    echo ""
    echo "------------------------------------------------"
    echo "------------------------------------------------"
    echo ""

    
    # source updated .zshrc file
    source $HOME/.zshrc
    wait
    echo 'command line tools is installed'



# Install xcodes (require Homebrew)
elif [[ $input == 3 ]]; then 


    # install xcodes
    brew install --cask xcodes
    open /Applications/Xcodes.app


# Setup iOS environment* (require Xcode & Homebrew)
elif [[ $input == 4 ]]; then 



    # install VSCode
    brew install --cask vscodium

    # !! Don't install this if it not mandatory
    # install IOS environment with cocoapods
    # update ruby gem
    # sudo gem update -n /usr/local/bin --system

    # !! Don't install this if it not mandatory
    # install fastlane
    # brew install fastlane

    echo install Xcode environnement

    # Display the building time on xcode HUD
    defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES

    # !! Don't install this if it not mandatory
    # install carthage
    # brew install carthage

    # !! Don't install this if it not mandatory
    # install cocoapods
    # sudo gem install -n /usr/local/bin cocoapods # Doesn't work in time from macOS Catalina (10.15.x)
    # brew install cocoapods 
    # clone the repository on ~/.cocoapods/
    # pod setup
    # wait

    # install sourcery
    brew install sourcery

    # install command-line to generate your project’s documentation 
    # gem install jazzy

    # install SwiftLint to enforce Swift style and conventions
    brew install swiftlint

    # !! Don't install this if it not mandatory
    # install bundle exec
    # sudo gem install -n /usr/local/bin bundler

    # install xcpretty
    sudo gem install -n /usr/local/bin xcpretty



# Install ruby env to iOS development
elif [[ $input == 5 ]]; then 



    # install Fastlane
    brew install fastlane

    # move in project folder
    cd ~/.wsx/iOS-Project-Folder

    # install ruby env
    brew install rbenv ruby-build && rbenv install

    # check version installed
    rbenv version
    which -a bundle
    ruby --version
    rbenv which bundle

    # add rbvend to your profile (zsh here)
    echo 'eval "$(rbenv init -)"' >> $HOME/.zshrc
    source ~/.zshrc
    gem install bundler



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
	brew install --no-quarantine syntax-highlight
	# xattr -r -d com.apple.quarantine "/Applications/Syntax Highlight.app" // "FULL PATH OF Syntax Highlight.app"
	# Setup > Render HTML + Light theme > neovim (dark) + Dark theme > Base 16 Rebecca
	brew install --no-quarantine qlmarkdown
	# xattr -r -d com.apple.quarantine "/Applications/QLMarkdown.app" //  "FULL PATH OF THE QLMarkdown.app"	

	# brew install qlcolorcode       # Seems not working on Apple Silicon m1+
	# brew install qlstephen         # Not working anymore (Apple m1+)
	# brew install quicklook-json    # Not working anymore (Apple m1+)
	# brew install qlprettypatch     # Replaced by Syntax Highlight
	brew install quicklook-csv
	# brew cask install betterzipql # Error: Cask 'betterzipql' is unavailable: No Cask with this name exists.
	brew install suspicious-package
	brew install apparency
	brew install provisionql
	brew install qlvideo
	wait

	echo "install of my softs throught cask"
	brew install slack
	brew install eloston-chromium
#	brew cask install srware-iron
#	brew cask install firefox
	brew install handbrake
	brew install rectangle // swift version of spectacle
	brew install MonitorControl
	brew install meetingbar
#	brew cask install steam
#	brew install sublime-text
#	brew install textmate
	brew install vlc
#	brew install beardedspice
#	brew install spotify
#	brew install spotify-notifications
	# brew cask install spotifree
	brew install istat-menus
#	brew install stats # open source alternative to istat-menus
	brew install onyx
	brew install postman
#	brew cask install sequential
	brew install wwdc
#	brew cask install transmit
#	brew cask install aerial
#	brew cask install flixtools
#	brew cask install motrix
	brew install coconutbattery
#	brew cask install wintertime
	wait

	echo "install of my softs throught mas"
	brew install mas
	mas install 425424353  # identifier of The Unarchiver     (4.2.0)
	mas install 736189492  # Notability                       (4.2.4)
	mas install 1330801220 # Paste JSON as Code • quicktype   (8.2.22)
	mas install 1381004916 # Discovery - DNS-SD Browser       (2.0.3)
#	mas install 1380446739 # InjectionIII                     (1.8)
#	mas install 1102494854 # System Designer                  (4.4.0)
	mas install 824183456  # Affinity Photo                   (1.8.1)
	mas install 824171161  # Affinity Designer                (1.8.1)
	mas install 461369673  # VOX: MP3 & FLAC Music Player     (3.3.17)
	# TODO: Add my new tools of productivity
#	mas lucky "Planny 3 Listes intelligentes"
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
