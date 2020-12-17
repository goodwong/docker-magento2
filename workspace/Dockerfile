FROM docker-magento2-php-fpm

# This Dockerfile adds a non-root 'vscode' user with sudo access. However, for Linux,
# this user's GID/UID must match your local user UID/GID to avoid permission issues
# with bind mounts. Update USER_UID / USER_GID if yours is not 1000. See
# https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# copied from official composer Dockerfile
# magento 要求 composer 1.x
RUN curl -s -f -L -o /tmp/installer.php https://getcomposer.org/installer \
    && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=1.10.6 \
    && composer --ansi --version --no-interaction \
    && rm -rf /tmp/* /tmp/.htaccess \
    #
    # install sockets
    # for composer install
    && docker-php-ext-install sockets \
    #
    # php 内存
    && cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini \
    && echo "memory_limit = 4096M" >> $PHP_INI_DIR/conf.d/memory_limit.ini


# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    #
    # 安装 git开发工具
    && apt-get install -y git tree \
    #
    # ssh server
    && apt-get install -y openssh-server \
    #
    ## Install MariaDB client
    #&& apt-get install -y mariadb-client \ 
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # Put the Magento file system owner in the web server’s group
    # The -a -G options are important because they add apache or www-data as a secondary group to the user account,
    # which preserves the user’s primary group. Adding a secondary group to a user account helps restrict file
    # ownership and permissions to ensure members of a shared group only have access to certain files.
    && usermod -a -G www-data $USERNAME \
    #
    #  创建用户目录权限
    && mkdir -p /home/$USERNAME \
    && chown -R $USERNAME /home/$USERNAME \
    #
    # [Optional] Add sudo support for the non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=


# 将magento加入命令列表
ENV PATH=$PATH:/var/www/html/bin
ENV SHELL /bin/bash

# 启动 ssh 
RUN service ssh start

# code server
RUN curl -fsSL https://code-server.dev/install.sh | sh

EXPOSE 22
EXPOSE 8080

ENTRYPOINT []
CMD (sudo /usr/sbin/sshd -D > /dev/null 2>&1 &); \
    ( /bin/bash code-server \
        --install-extension=bmewburn.vscode-intelephense-client \
        --install-extension=mhutchie.git-graph \
      && /bin/bash code-server \
        --bind-addr=0.0.0.0:8080 \
        /var/www/html/ \
    > /dev/null 2>&1 &); \
    sleep 2; cat /home/vscode/.config/code-server/config.yaml; \
    sleep infinity
