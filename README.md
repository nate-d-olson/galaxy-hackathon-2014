galaxy-hackathon-2014
=====================

To demonstrate creating a new tool for galaxy that uses docker for installing dependencies a Dockerfile and galaxy tool config file were generated for BAYSIC.  BAYSIC (http://www.biomedcentral.com/1471-2105/15/104) used bayesian statistics to calculate the posterior probabilities for a set of variant calls given multiple independent variant calls sets for the same sample or dataset.  The tool was developed on EC2 galaxy server on a EC2 instance.

I will first covered installing galaxy on an EC2 instance then installing the BAYSIC tool.

## Personal Galaxy EC2 Server

### EC2 instance

* start with a base Ubuntu 14.04 64 bit image (ubuntu-trusty-14.04-amd64-server-20140416.1 (ami-1d8c9574))   
* add a rule to the security group with for port 8080 (or whatever port you use for galaxy), custom tcp protocol, and source 0.0.0.0/0 (can change to specific IPs for increased security)

### Galaxy Install

* clone galaxy repository pull-request with modified code for using tools with Docker dependencies
```bash
$ hg clone https://bitbucket.org/galaxy/galaxy-central/pull-request/401/allow-tools-and-deployers-to-specify/diff
$ sh run.sh
```

* Uncomment `host=0.0.0.0` (can change to specific IPs for increased security)   

```
# The address on which to listen.  By default, only listen to localhost (Galaxy
# will not be accessible over the network).  Use '0.0.0.0' to listen on all
# available network interfaces.
host = 0.0.0.0
```

 
* Add docker runner to sudoers (`sudo visudo`) file (replace `galaxy` with your username you are running galaxy under):stolen from apetkau [https://github.com/apetkau/galaxy-hackathon-2014](https://github.com/apetkau/galaxy-hackathon-2014)

```
galaxy  ALL = (root) NOPASSWD: SETENV: /usr/bin/docker
```
* run `sh run.sh` to check galaxy installation.  Go to instance public DNS port 8080, e.g. `http://ec2-54-91-222-102.compute-1.amazonaws.com:8080`. 

### Install Docker
* Following steps from *docker* documentation for installing *docker* on ubuntu [http://docs.docker.com/installation/ubuntulinux/](http://docs.docker.com/installation/ubuntulinux/)

```curl -s https://get.docker.io/ubuntu/ | sudo sh```

* Testing docker install

```sudo docker run -i -t ubuntu /bin/bash```

## Setup BAYSIC Tool

* Create a directory for docker tools and move the tool config to the docker directory and the Dockerfile to a tools specific subdirectory. Note: Dockerfiles must be named "Dockerfile", inorder to prevent conflicts place Dockerfiles in independent directories.

```
bash
$ mkdir tools/docker tools/docker/BAYSIC
$ cp baysicDocker.xml tools/docker/
$ cp Dockerfile tools/docker/BAYSIC 
```

* In `tool_conf.xml` add 

```xml
  <section>
    <tool file="docker/baysicDocker.xml"/>
  </section>
```
### Create Docker image with BAYSIC dependencies
* Build docker image using Dockerfile

```
bash
cd tools/docker/BAYSIC
sudo docker build .
```

* Save docker image


# Not sure I did this is this part of Johns pull request?
Create `job_conf.xml` and add

```bash
cp job_conf.xml.sample_basic job_conf.xml
```

Add in `job_conf.xml`:

```xml
    <destinations default="docker_local">
       <destination id="local" runner="local"/>
       <destination id="docker_local" runner="local">
         <param id="docker_enabled">true</param>
       </destination>
    </destinations>
```

### Run Galaxy

```bash
$ sh run.sh
```

Run test tool **Concatenate datasets (in docker)**

Check log file.  If tool ran you should see entries like:

```
 command is: sudo docker run -e "GALAXY_SLOTS=$GALAXY_SLOTS" -v /home/aaron/Projects/galaxy-central:/home/aaron/Proje
cts/galaxy-central:ro -v /home/aaron/Projects/galaxy-central/tools/docker:/home/aaron/Projects/galaxy-central/tools/docker:ro -v /home/aaron/Projects/galaxy-central/datab
ase/job_working_directory/000/6:/home/aaron/Projects/galaxy-central/database/job_working_directory/000/6:rw -v /home/aaron/Projects/galaxy-central/database/files:/home/aa
ron/Projects/galaxy-central/database/files:rw -w /home/aaron/Projects/galaxy-central/database/job_working_directory/000/6 --net none busybox:ubuntu-14.04 /home/aaron/Projects/galaxy-central/database/job_working_directory/000/6/container.sh; return_code=$?; if [ -f /home/aaron/Projects/galaxy-central/database/job_working_directory/000/6/wo
rking_file ] ; then cp /home/aaron/Projects/galaxy-central/database/job_working_directory/000/6/working_file /home/aaron/Projects/galaxy-central/database/files/000/dataset_10.dat ; fi; sh -c "exit $return_code"
```


