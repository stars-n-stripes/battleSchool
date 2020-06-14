# POC for the Cyber Combat Simulator 
### Author: starsnstripes

### Installation
On a new Ubuntu Server **20.04**, run: 
`wget https://raw.githubusercontent.com/stars-n-stripes/battleSchool/master/build/build.sh -O /tmp/build.sh && chmod +x /tmp/build.sh`
to download the file. You need to provide two passwords (one for the developer, and one for the student).

### Description

**startwm.sh** is the script that XRDP runs after user authentication. If the `student` user logs in, they are redirected to an `xfce4-session` on their Kali VM via `ssh`.

**build.sh** is how one provisions an Ubuntu 20.04 LTS Server to run the scenario defined in the Vagrantfile. It does a whole lot, but is well-commented - review the source code itself for a complete explanation of what it does.

**xsudo.sh** is installed as an alias for `sudo` on the student's Kali VM. It is a simple (and hacky) wrapper that ensures that `root` has the `X-Session-Cookie` and `DISPLAY` environment variables properly set so X applications will use the student's X Session.

##### Usage
`./build.sh <dev password> <student password>`
