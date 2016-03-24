FROM debian:8.3

# Install PHP
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
        php5-cli \
        curl \
        nano \
        python-pip \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /init

# Install composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Install satis
RUN composer create-project composer/satis --stability=dev --keep-vcs /opt/satis && \
    ln -s /opt/satis/bin/satis /usr/local/bin/satis

# Install s3cmd
RUN pip install s3cmd
COPY config/s3cmd.conf /root/.s3cfg

# Add satisbuild command
COPY bin/satisbuild.sh /usr/local/bin/satisbuild
RUN chmod +x /usr/local/bin/satisbuild

# Configure bash
RUN echo "export TERM=xterm" >> /etc/bash.bashrc && \
    echo "export EDITOR=/usr/bin/nano" >> /etc/bash.bashrc

# Create directories for satis
RUN mkdir /satis && \
    mkdir /satis/config && \
    mkdir /satis/web

CMD ["satisbuild"]