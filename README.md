Initialization of Mac OS X
===========

If you want to get this script from github, you need at the first place to install git. You can get it with command line tools of OS X.
For this you need to launch on terminal this command :
```sh
xcode-select --install
```

After that you need to connect on github and add your SSH Key, if you don't have anymore, you can generate it with this command :
```sh
# Look at the user folder if you have an .ssh folder
ls -al ~/.ssh
```

```sh
# If you don't have *.pub
ssh-keygen -t rsa -C "your_email@example.com"
```

```sh
# Copies the contents of the id_rsa.pub file to your clipboard
pbcopy < ~/.ssh/id_rsa.pub
```

```sh
# Get this code and launch the install script

## Create Workspace
mkdir -p ~/Documents/Workspaces/devops
cd ~/Documents/Workspaces/devops

## Clone the repository
git clone git@github.com:Fr0zenSide/install-osx.git

## Launch & select the install script you need
cd install-osx
sh ./install-osx.sh

```

# GNU Stow is used with oh my zsh install script
# Stow (symlink magic)
You can use GNU stow to create symlinks of dotfiles in home directory
```sh
brew install stow
cd dotfiles
stow -t ~/ .
```

```sh
# if you want to cleaning up symbolic links stow add in home folder
stow -D .
```
