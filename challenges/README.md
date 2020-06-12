# Battle School Challenge Format
##### Author: starsnstripes

## Overview

battleSchool challenges are based around a few constraints:

1. Challenges need to be hosted on a single machine, physical or virtual.
    + The reason behind this is that [Azure Classroom Labs](https://docs.microsoft.com/en-us/azure/lab-services/classroom-labs/) can only provision one VM per student, and that is the preferred cloud platform for this project's use case.
2. Challenges and their component services need to be modular
    + By using Vagrant and Docker on a common base of shell scripts, we can deploy services interchangeably between VMs and containers, local or cloud-based.
3. Challenges need to be in a blackbox environment.
4. The student must be able to revert containers or VMs within the challenge framework.
5. The challenge environment should be built with future expansion in mind.
    + Three major projects looking forward would be an onboard knowledge base for students, the ability to communicate with a remote server for flag generation and verification, and the ability to eventually connect to another server for multiplayer scenarios.

## Technologies Used
_If you're looking to develop challenges, this would be a good place to start:_

+ [Vagrant](https://www.vagrantup.com/docs) for building the Student VM and other scenario services. This includes docker containers [built](https://www.vagrantup.com/docs/providers/docker) by Vagrant.
+ [Docker](docs.docker.com), for a better understanding of what Vagrant is doing and for building containers to support faster scenario load times
+ [Bash Scripting](https://tldp.org/LDP/abs/html/), which will be our primary method of provisioning services on both Docker and Vagrant objects within the scenarios
+ [Django](https://docs.djangoproject.com/en/3.0/), which is used for the [Battle School Scenario Manager](https://github.com/stars-n-stripes/battleSchoolSM) and may one day be expanded for an internal knowledge base.
