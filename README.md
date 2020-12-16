
docker for magento 2.x
======================
为 Magento `2.4` 准备的docker环境，可能`2.3`也能用

> 寻找 Magento 1.x 的docker环境？[点这里](https://github.com/goodwong/docker-magento "For Magento 1.x")   



安装步骤
-----------------------

1. 安装环境
    安装 docker & docker-compose，参见docker 官方文档  
    https://docs.docker.com/install/linux/docker-ce/ubuntu/  
    https://docs.docker.com/compose/install/#master-builds  


2. 创建项目文件夹，下载代码
    1. 创建文件夹
        > 目录结构见附录  
        ```sh
        # 项目文件夹
        mkdir magento-domain-2/ && cd magento-domain-2/
        mkdir magento2/ # <------ 此magento2文件夹名对应.env文件的`APPLICATION`值
        mkdir mysql57/ # <------ 此magento2文件夹名对应.env文件的`DB_DIR`值
        ```

    2. 准备 magento2 源码  
        解压源码到 magento2/文件夹下
        ```
        # 例如
        git clone git@github.com/xxxx/xxxx.git magento2/
        ```

    3. 克隆 docker-magento2.x
        ```sh
        cd magento-domain-2/
        git clone https://github.com/goodwong/docker-magento2.x .docker-compose
        ```
    
    4.（可选）初始化数据库文件（可选，也可以在后面步骤手工导入）
        将 数据库备份文件 .sh, .sql 或 .sql.gz 文件放到 .docker-compose/db/initdb.d/目录下

3. 配置
    1. `docker-magento`
        ```sh
        cd .docker-compose/
        cp .env.example .env
        ```
        默认配置即可运行，如果有多个magento站点运行，分别修改以下变量为不同的值：
        - `COMPOSE_PROJECT_NAME`=  
        - `NGINX_HOST_HTTP_PORT`=  
        - `DB_ADMINER_PORT`=  

        > 生产环境下， ***务必修改*** 数据库密码  
        > - `DB_ROOT_PASSWORD`=  
        > - `DB_PASSWORD`=  
        > - `DB_USER`=  
        > - `DB_NAME`=  

    2. 创建/修改 magento2/app/etc/.env.php，修改 db 连接参数
        ```php
        <?php
        return [
            'db' => [
                'table_prefix' => '',
                'connection' => [
                    'default' => [
                        'host' => 'db',
                        'dbname' => 'app',
                        'username' => 'app',
                        'password' => 'secret',
        ```
    3. 创建 host nginx 的 site 配置（参见附录）

4. 启动
    1. 启动服务
        ```sh
        cd .docker-compose/
        # ！！提示
        # 请确保 magento2/目录下 有nginx.conf.sample文件，否则 容器内的 nginx 起不来
        docker-compose up -d web workspace

        # 查看日志
        docker-compose logs -f
        ```

    2. 验证并重启 nginx
        ```
        nginx -t
        service nginx reload
        ```

    3. 更新 letsencrypt
        ```
        sudo certbot --nginx
        ```

    4. 文件权限设置
        ```sh
        cd magento2/ # 宿主机
        find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
        find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
        chown -R 1000:www-data . # vscode 用户 uid=1000
        chmod u+x bin/magento
        ```
        > 更多参考：
        > https://devdocs.magento.com/guides/v2.4/install-gde/prereq/file-system-perms.html#perms-private

    5. 安装包依赖
        ```sh
        docker-compose exec workspace bash

        # 预设 magento api token
        echo "{"http-basic": {"repo.magento.com":{"username":"____","password":"____"}}}" > ~/.composer/auth.json
        # 或者安装过程中会要求输入 key 和密码 

        # 开始安装
        composer install
        ```

5. （可选）导入数据
    1. 复制数据库到 mysql57/ 文件夹
    2. 导入数据库
        ```sh
        docker-compose exec -w /var/lib/mysql/ db bash 
        mysql -p app < database_backup_file.sql
        ```
    3. 重新编译
        ```sh
        rm -rf pub/static/*  # 这个很重要，不然主题会出不来
        php bin/magento setup:di:compile
        php bin/magento cache:clean
        php bin/magento setup:upgrade
        php bin/magento setup:static-content:deploy
        ```
    4. 修改 base_url
        ```sh
        docker-compose exec workspace bash

        BASE_URL=https://dev-xxx.app.com
        php bin/magento setup:store-config:set --base-url-secure="${BASE_URL}"
        php bin/magento setup:store-config:set --base-url="${BASE_URL}" # 这条也要，不然后台无法访问报404
        php bin/magento cache:flush
        ```



附录
-------------------

* 文件夹结构

    ```sh
    magento-domain-2/
    ├── .docker-compose/ # <---- docker-compose 配置及数据文件夹
    │   ├── .env
    │   ├── README.md
    │   ├── adminer/
    │   ├── cron/
    │   ├── docker-compose.yml
    |   ....
    │   ├── nginx/
    │   ├── php-fpm/
    │   └── workspace/
    ├── mysql57/ # <------------- mysql 数据库文件
    |   ....
    └── magento2/ # <----------- magento 2.x 代码文件夹
        ├── CHANGELOG.md
        ├── COPYING.txt
        ├── Gruntfile.js.sample
        ├── LICENSE.txt
        ├── LICENSE_AFL.txt
        ├── app/
        ├── auth.json.sample
        ├── bin/
        ....
        ├── var/
        └── vendor/
    ```


* 使用 magento命令行
    ```sh
    # 登陆workspace容器
    docker-compose up -d workspace
    docker-compose exec workspace bash

    # 执行安装
    magento setup:install \
    --admin-firstname=William --admin-lastname=Wong \
    --admin-email=goodwong@foxmail.com --admin-user=admin --admin-password=******** \
    --db-host=db --db-name=app --db-user=app --db-password=app
    
    # 执行magento命令：
    magento cache:status

    # 执行composer命令
    composer list
    ```
    > 参见 https://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-install.html




* 导入/管理数据库
    > 有两种方式管理数据库：

    - 方法一，通过`adminer`的web界面操作
        ```sh
        cd .docker-compose/
        docker-compose up adminer
        ```
        打开浏览器 `http://IP地址:<DB_ADMINER_PORT>?server=db`


    - 方法二，进入mysql容器，使用命令行界面  
        首先将数据文件解压并放在` 数据库文件夹`下（如:magento-domain-2/mysql57/）
        ```sh
        # 登陆db容器
        docker-compose exec -w /var/lib/mysql/ db bash 
        mysql -p db_name < database_backup_file.sql
        #           ^                ^
        #        数据库名         数据库备份文件
        #       见.env文件
        ```

* CRON
    > 请确保Magento正确安装后，再启用本服务

    ```sh
    cd .docker-compose/
    docker-compose up -d cron
    ```


* 多站点多项目
    > 注意分别修改`.env文件`里端口变量为不同的值  

    建议使用`nginx`作前端机，配置代理规则
    ```nginx
    # 宿主机
    # ／etc/nginx/sites-available/domain-1.conf

    server {
        listen 80;
        listen [::]:80;

        server_name xxx.com www.xxx.com;

        location / {
            proxy_set_header HOST $host;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            proxy_pass http://127.0.0.1:8888/; # <--- 末尾必须有/符号
                                               # <--- 端口号见<NGINX_HOST_HTTP_PORT> 变量
        }
    }
    ```
