install-osx
===========

Initialization of Mac OS X

If you want to get this script from github, you need at the first place to install git. You can get it with command line tools of OS X.
For this you need to launch on terminal this command :
```sh
xcode-select --install
```

After that you need to connect on github and add your SSH Key, if you don't have anymore, you can generate it with this command :
```sh
# Look at the user folder if you have an .ssh folder
ls -al ~/.ssh

# If you don't have *.pub
ssh-keygen -t rsa -C "your_email@example.com"

# Copies the contents of the id_rsa.pub file to your clipboard
pbcopy < ~/.ssh/id_rsa.pub

# Clone the repository
git clone git@github.com:Fr0zenSide/install-osx.git
```

To launch the installations you need to launch on the project folder, the install script :
````sh
sh ./install-osx.sh
```

