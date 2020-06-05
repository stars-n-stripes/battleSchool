# POC for the Cyber Combat Simulator 
### Author: starsnstripes

### Installation
On a new Ubuntu Server 20.04, run: 
`wget [script] -O /tmp/build.sh && chmod +x /tmp/build.sh`
To download the file. You need to provide two passwords (one for the developer, and one for the student).

### Description

**startwm.sh** is the script that XRDP runs after user authentication
**build.sh** is how one provisions an Ubuntu 20.04 LTS Server to run the scenario
**Vagrantfile** contains information on the scenario

##### Usage
`./build.sh <dev password> <student password>
