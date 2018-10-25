
# docker for magento 2.x
为 Magento `2.2` 准备的docker环境，可能`2.1`也能用

> 寻找 Magento 1.x 的docker环境？[点这里](https://github.com/goodwong/docker-magento "For Magento 1.x")

## 安装 docker-magento 环境

1. 安装 docker & docker-compose
    参见docker 官方文档  
    https://docs.docker.com/install/linux/docker-ce/ubuntu/  
    https://docs.docker.com/compose/install/#master-builds  


2. 创建项目文件夹
    ```shell
    # 项目文件夹
    mkdir magento-domain-2/ && cd magento-domain-2/
    mkdir magento2/ # <------ 此magento2文件夹名对应.env文件的`APPLICATION`值
    ```

3. 克隆
    ```shell
    cd magento-domain-2/
    git clone https://github.com/goodwong/docker-magento2.x .docker-compose
    ```

4. 配置 `docker-magento`
    ```shell
    cd .docker-compose/
    cp .env.example .env
    ```
    默认配置即可运行，如果有多个magento站点运行，分别修改以下变量为不同的值：
    - `COMPOSE_PROJECT_NAME`=  
    - `NGINX_HOST_HTTP_PORT`=  
    - `DB_ADMINER_PORT`=  

    > 生产环境下，建议修改数据库密码  
    > - `DB_ROOT_PASSWORD`=  
    > - `DB_PASSWORD`=  
    > - `DB_USER`=  
    > - `DB_NAME`=  

5. 运行 `docker-magento`服务
    ```shell
    cd .docker-compose/
    docker-compose up -d web

    # 查看日志
    docker-compose logs -f
    ```



## 安装 magento 站点

> 分为 全新安装 和 使用现有magento源码安装 两种情况

### 全新 Magento 站点

1. 解压magento代码
    ```shell
    cd magento-domain-2/magento2/
    # 下载Magento CE文件包
    # 解压包
    # tar -xzvf Magento-CE-2.2.6-2018-09-07-02-17-04.tar.bz2
    ```
    > 移动文件时候，不要漏了隐藏文件

2. 文件夹结构
    ```
    magento-domain-2/
    ├── .docker-compose/ # <---- docker-compose 配置及数据文件夹
    │   ├── .env
    │   ├── README.md
    │   ├── adminer/
    │   ├── cron/
    │   ├── db/ # <------------- mysql 数据库文件
    │   ├── docker-compose.yml
    |   ....
    │   ├── nginx/
    │   ├── php-fpm/
    │   └── workspace/
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


3. 设置文件权限
    ```shell
    # 需要提前 docker-compose up -d web
    # 登陆php-fpm容器
    docker-compose exec php-fpm bash
    #find var vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
    #find var vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
    chown -R www-data:www-data .
    chmod u+x bin/magento
    exit
    ```

4. 浏览器安装
    然后在浏览器里访问 `http://你的服务器ip或域名:nginx端口号/setup`
    安装过程中，配置数据库： 
    > 数据库地址：`db`  
    > 数据库用户名：见.env文件`<DB_USER>`  
    > 数据库密码：见.env文件 `<DB_PASSWORD>`  
    > 数据库名称：见.env文件 `<DB_NAME>`

5. （或者）命令行安装
    ```shell
    # 登陆workspace容器
    docker-compose up -d workspace
    docker-compose exec workspace bash

    # 执行安装
    ./bin/magento setup:install \
    --admin-firstname=William --admin-lastname=Wong \
    --admin-email=goodwong@foxmail.com --admin-user=admin --admin-password=******** \
    --db-host=db --db-name=app --db-user=app --db-password=app
    #                                                                          ^
    #                                                                   密码肯定是要改的啦
    
    ```
    > 参见 https://devdocs.magento.com/guides/v2.0/install-gde/install/cli/install-cli-install.html




### 使用现有的 Magento站点代码
1. 解压代码至 `magento-domain-2/magento2/`文件夹
    > 文件结构（参见前文）

2. 设置文件权限
    > 参见前文

2. 修改`app/etc/env.php`数据库信息：
    > 数据库地址：`db`  
    > 数据库用户名：见.env文件`<DB_USER>`  
    > 数据库密码：见.env文件`<DB_PASSWORD>`  
    > 数据库名称：见.env文件 `<DB_NAME>`  



## 导入/管理数据库
> 有两种方式管理数据库：

- 方法一，通过`adminer`的web界面操作
    ```shell
    cd .docker-compose/
    docker-compose up adminer
    ```
    打开浏览器 http://IP地址:<DB_ADMINER_PORT>  
    `Server`地址填写`db`  


- 方法二，进入mysql容器，使用命令行界面  
    首先将数据文件解压并放在`项目文件夹`下（如:magento-domain-2/magento2/）
    ```shell
    # 登陆db容器
    cd .docker-compose/
    docker-compose exec db bash

    cd /var/www/html/
    mysql -p db_name < database_backup_file.sql
    #           ^                ^
    #        数据库名         数据库备份文件
    #       见.env文件
    ```

## Cron
> 请确保Magento正确安装后，再启用本服务

```shell
cd .docker-compose/
docker-compose up -d cron
```

## magento 命令行工具
```shell
cd .docker-compose/
docker-compose up -d workspace

# 登陆workspace容器
docker-compose exec workspace bash
# 进入容器后，即可以执行magento命令：
# 如：magento magento cache:status
# 同时也支持composer工具
```

## 多站点多项目
> 注意分别修改`.env文件`里端口变量为不同的值  

建议使用`nginx`作前端机，配置代理规则
```nginx
# 宿主机
# ／etc/nginx/sites-available/domain-1.conf

server {
    listen 80;
    listen [::]:80;

    server xxx.com www.xxx.com;

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
