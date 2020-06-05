# POC for the Cyber Combat Simulator 
### Author: starsnstripes

### Installation
On a new Ubuntu Server 20.04, run: 
`wget https://raw.githubusercontent.com/stars-n-stripes/battleSchool/master/challenges/test/build.sh -O /tmp/build.sh && chmod +x /tmp/build.sh`
to download the file. You need to provide two passwords (one for the developer, and one for the student).

### Description

**startwm.sh** is the script that XRDP runs after user authentication.

**build.sh** is how one provisions an Ubuntu 20.04 LTS Server to run the scenario defined in the Vagrantfile.

The **Vagrantfile** contains information on the scenario, as well as the parameters for the student attacker box.

##### Usage
`./build.sh <dev password> <student password>`
