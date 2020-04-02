#!/bin/bash

###############################################################
# Licensed Materials - Property of IBM
# “Restricted Materials of IBM”
#  Copyright IBM Corp. 2019 ALL RIGHTS RESERVED
###############################################################

###############################################################
#
# Author: Eli M. Dow <emdow@us.ibm.com>
#
###############################################################

# Looks for an environment var named CLAI_DOCKER_IMAGE_NAME. If not
# defined, uses the default flag value 'claiplayground' for the docker image.
image_name=${CLAI_DOCKER_IMAGE_NAME-"claiplayground"}

# Looks for an environment var named CLAI_DOCKER_CONTAINER_NAME. If not
# defined, uses the default flag value 'CLAIBotPlayground' for the container.
image_name=${CLAI_DOCKER_CONTAINER_NAME-"CLAIBotPlayground"}

# Controls where CLAI would store internal states for persistence
DefaultBaseDir="${HOME}/.clai"
HostBaseDir="${CLAI_BASEDIR:-${DefaultBaseDir}}"
ContainerBaseDir="/root/.clai"

# If the CLAI_DOCKER_JENKINSBUILD environment variable is set, we are
# executing this from the 'test' stage of a Jenkins pipeline.  In that
# case, we want to change two things: (1) the root home directory should
# contain the files checked out from git, and (2) our entrypoint should be
# a call to pytest to run our automated unit test suite.
runargs=""
if [ -n "$CLAI_DOCKER_JENKINSBUILD" ]; then
    HostBaseDir="/root"
    runargs="-it --entrypoint pytest"
fi

# Run docker in privileged / unrestricted mode                (--privileged)
# Allocate a psuedo-terminal in the docker container          (-t)
# Run docker in a detached daemon mode                        (-d)
# Forward the ports to the localhost so we can SSH            (-P)
# Run docker with 2GB of memory                               (-m 2GB)
# Mount a host directory to the container directory           (-v ${HostBaseDir}:${ContainerBaseDir})
# Provide a handy human readable name for the container       (--name ${CLAI_DOCKER_CONTAINER_NAME})
# Follow with any additional docker run arguments             (${runargs})

docker run --privileged							  	  \
           -t -d                                      \
           -P                                         \
           -m 2g                                      \
           -v ${HostBaseDir}:${ContainerBaseDir}      \
           --name ${CLAI_DOCKER_CONTAINER_NAME}       \
           ${runargs}                                 \
	   $CLAI_DOCKER_IMAGE_NAME

echo 'User for ssh is root and the default pass Bashpass'
