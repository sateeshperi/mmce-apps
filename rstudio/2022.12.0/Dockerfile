FROM quay.io/centos/centos:stream8
WORKDIR /root
RUN yum update -y && \
    yum install -y epel-release dnf-plugins-core && \
    yum config-manager --set-enabled powertools && \
    yum install -y wget R initscripts compat-openssl10 && \
    yum clean all && rm -rf /var/cache/yum

# Install required R packages
RUN R -e "install.packages(c('readr', 'dplyr'), repos='https://cran.rstudio.com/')"

# Install Bioconductor packages
RUN R -e 'install.packages("BiocManager", repos="https://cran.rstudio.com/")' && \
    R -e 'BiocManager::install(version = "3.18", ask = FALSE)' && \
    R -e 'BiocManager::install(c("rtracklayer", "GenomicRanges", "AnnotationDbi"), ask = FALSE)'

RUN wget -q https://download2.rstudio.org/server/centos7/x86_64/rstudio-server-rhel-2022.12.0-353-x86_64.rpm \
    && yum install rstudio-server-rhel-2022.12.0-353-x86_64.rpm -y \
    && rm -f rstudio-server-rhel-2022.12.0-353-x86_64.rpm
COPY run_rstudio.sh /root
RUN chmod +x run_rstudio.sh

ENTRYPOINT ./run_rstudio.sh
