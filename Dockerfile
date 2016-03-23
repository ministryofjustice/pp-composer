FROM phusion/baseimage:0.9.18

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Set system locale
ENV LC_ALL="en_GB.UTF-8" \
    LANG="en_GB.UTF-8" \
    LANGUAGE="en_GB.UTF-8"

###
# INSTALL PACKAGES
###

RUN add-apt-repository -y ppa:ondrej/php && \
    add-apt-repository -y ppa:nginx/stable && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        php7.0-cli php7.0-curl php7.0-mcrypt php7.0-readline php-zip php-xml php-mbstring \
        nginx \
        git \
        nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /init

# Install composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Install satis
RUN composer create-project composer/satis --stability=dev --keep-vcs /opt/satis && \
    ln -s /opt/satis/bin/satis /usr/local/bin/satis

# Add satisbuild command
COPY bin/satisbuild.sh /usr/local/bin/satisbuild
RUN chmod +x /usr/local/bin/satisbuild

###
# CONFIGURE PACKAGES
###

# Configure nginx
COPY conf/nginx/server.conf /etc/nginx/sites-available/
RUN echo "daemon off;" >> /etc/nginx/nginx.conf && \
    rm /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/server.conf /etc/nginx/sites-enabled/server.conf

# Configure bash
RUN echo "export TERM=xterm" >> /etc/bash.bashrc && \
    echo "export EDITOR=/usr/bin/nano" >> /etc/bash.bashrc

# Configure services
COPY service/* /etc/service/
RUN mkdir /etc/service/nginx && \
    mv /etc/service/nginx.sh /etc/service/nginx/run && \
    chmod +x /etc/service/nginx/run

# Configure init scripts
#COPY init/* /etc/my_init.d/
#RUN chmod +x /etc/my_init.d/*

# Create directories for satis
RUN mkdir /satis && \
    mkdir /satis/config && \
    mkdir /satis/web

EXPOSE 80
