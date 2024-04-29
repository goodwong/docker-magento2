# sudo /usr/sbin/sshd -D > /dev/null 2>&1 &
if [ ! -f /var/www/.bashrc ]; then
    cp /home/vscode/.bashrc ~ && \
    chown -R www-data:www-data ~/.bashrc && \
    sed -i 's/# *alias /alias /g' ~/.bashrc && \
    source ~/.bashrc

    # 加入magento命令
    echo 'export PATH=$PATH:/var/www/html/bin' >> ~/.bashrc

    # bash支持中文（修改后需要退出后重新进）
    echo 'export LANG=C.UTF-8' >> ~/.bashrc

    # git 支持中文显示
    git config --global core.fileMode false
    git config --global core.quotepath off
    git config --global core.pager more

    # vscode设置
    mkdir -p ~/.local/share/code-server/User/
    cp ~/.docker/workspace/vscode-settings.json ~/.local/share/code-server/User/settings.json

    # 生成证书
    ssh-keygen -q -t rsa -f ~/.ssh/id_rsa -N ""
fi

/bin/bash code-server \
    --install-extension=bmewburn.vscode-intelephense-client \
    --install-extension=mhutchie.git-graph;
/bin/bash code-server --bind-addr=0.0.0.0:8080 /var/www/html/
