# renode_docker

Repository containing Docker workflows based around the Silicon Labs public fork of Renode. 

### renode_build container

Container including an environment for building and packaging Renode (from source at SiliconLabsSoftware/renode).  Requires the Renode repository to be mounted into the container before building, and is mostly intended for CI workflows to provide access to the environment they need to package Renode for the renode container.
The build environment is currently based on .NET 8.0 and Ubuntu 24.04 + x86_64 architecture.

### renode container

Container includes a preinstalled version of Renode built from the renode_build container. 
Includes 'renode' (to launch the Renode monitor) and 'renode-test' (to run one of the Robot tests packaged inside the container) as commands on PATH.
