# renode_docker
(WORK IN PROGRESS)

Repository containing a Docker workflow for the Silicon Labs public fork of Renode.  
The container produced by the Dockerfile has this version of Renode preinstalled, while the Github Actions workflow builds and packages Renode upon changes to the main
branch of SiliconLabsSoftware/renode, and builds the container based on this package.
