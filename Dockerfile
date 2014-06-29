# Dockerfile installation of dependencies for BAYSIC


# Base image 
FROM ubuntu:13.10

# Dockerfile for BAYSIC dependencies 
MAINTAINER NateOlson

# install of basic dependencies
RUN apt-get update

RUN apt-get install  -y \
	apt-utils \
	git \
	make \
	gcc \
     	g++ \
     	zlib1g-dev \ 
     	r-base \
     	jags \
     	liblapack-dev \
     	liblapack3gf
	 
# install R packages
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "install.packages('reshape2')"
RUN Rscript -e "install.packages('getopt')"
RUN Rscript -e "install.packages('rjags')"
RUN Rscript -e "install.packages('R2jags')"

# install Perl modules
RUN apt-get install -y cpanminus
RUN cpanm -v JSON File::Temp Getopt::Long List::Util File::Next Test::Warn File::Slurp PerlIO::gzip File::Which local::lib

# retrieving BAYSIC rep and compiling dependencies
RUN git clone https://bitbucket.org/jtr4v/baysic.git
RUN cd baysic
RUN cd baysic/lib/tabix*/ && make clean && make && cd ../../
RUN cd baysic/lib/vcftools*/ && make clean && make && cd ../../

# run baysic tests
#RUN perl baysic/baysic.pl --statsOutFile combined.stats --pvalCutoff 0.8 --vcf S0h-1_S1_L001_R1_001.sort.hc.vcf --vcf S0h-1_S1_L001_R1_001.sort.realign.vcf --countsOutFile combined.cts --vcfOutFile combined.vcf
