#!/usr/bin/env bash

#一键安装94list-laravel

#此脚本在一键安装青龙脚本的基础上所修改,一键安装青龙脚本的来源地址找不到了。


#94list-laravel源码  https://github.com/huankong233/94list-laravel



#解析主端口映射为6702  数据库端口映射为6706  admin管理端口映射为6703  php管理端口映射为6704  
#容器映射路径：/data/container/94list-laravel$(date +%Y%m%d)

Green="\033[32;1m"
Red="\033[31m"
Yellow="\033[33;1m"
Blue="\033[36;1m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
ERROR="${Red}[ERROR]${Font}"

ok() {
  echo
  echo -e " ${OK} ${Green} $1 ${Font}"
  echo
}
error() {
  echo
  echo -e "${ERROR} ${RedBG} $1 ${Font}"
  echo
}

ing () {
  echo
  echo -e "${Yellow} $1 ${Font}"
  echo
}


if [[ ! "$USER" == "root" ]]; then
  error "警告：请使用root用户操作!~~"
  exit 1
fi

datav=/data/container/94list-laravel-$(date +%Y-%m-%d)
mkdir -p $datav  && laravel_path=$datav

docker_run (){
if [  -z "$(docker ps -a | grep 94list-laravel  2> /dev/null)" ]; then
cd $laravel_path
cat > docker-compose.yml <<EOF
version: '3.8'

services:
  94list:
    # 容器名字
    container_name: 94list-laravel
    ### 镜像名字
    # 请使用 "huankong233/94list-laravel:0.1.3" 及以上版本
    image: huankong233/94list-laravel:latest
    # 使用的虚拟网口，必须配合底部 "network" 大项使用
    networks:
      - 94list
    # 开放端口
    ports:
      # 左侧为外部开放端口，请自行修改，右侧为容器内端口，请勿修改
      # 注意！左侧开放端口不要与其他项目端口重复
      - '6702:8080'
    # 目录映射
    volumes:
      # 左侧为宿主机目录，请自行修改，右侧为容器内部目录，请勿修改
      - ./94list-laravel/html:/var/www/html
    # 重启策略
    restart: always
    # 环境变量
    environment:
      ### 模式选择
      #  0 为.env模式
      #  1 为容器环境变量模式 
      # 使用模式0时，必须#注释或删除掉"数据库配置"大项，否则会出现参数被环境变量代替的情况
      # 使用模式1时，可搭配下方数据库配置一同使用
      - APP_INSTALL_MODE=1

      ### 基础配置
      # 网站名字
      - APP_NAME=94list-edit
      # 网站地址
      - APP_URL=http://localhost

      ### 数据库配置
      # db_type有效参数，"sqlite"、"mysql"
      # 如果需要使用sqlite请手动创建好一个空文件，然后在DB_DATABASE中指定数据库文件的绝对路径
      # 通常一般为 /var/www/html/database/database.sqlite 对应的宿主机位置就是 ./path/94list-laravel/html/database/database.sqlite
      - DB_CONNECTION=mysql
      # 数据库地址（注意！使用 "mysql" 数据库时，请改成可访问 "mysql" 的地址，请勿在 "brider" 模式下使用"localhost"、"127.0.0.1" 地址）
      # 同个"docker-compose"部署下，可直接填入容器名
      - DB_HOST=mysql
      # 数据库端口 （Tip:"mysql" 默认端口3306）
      - DB_PORT=3306
      # 数据库名字
      - DB_DATABASE=94list
      # 用户名
      - DB_USERNAME=94list
      # 登陆密码
      - DB_PASSWORD=123456
    depends_on:
      - mysql
      ### 邮箱配置
      # 邮件服务器协议类型
      #- MAIL_MAILER=smtp
      # 邮件服务器地址
      #- MAIL_HOST=smtp.qq.com
      # 邮件服务器端口
      #- MAIL_PORT=465
      # 邮件服务器登陆账号
      #- MAIL_USERNAME=hello@example.com
      # 邮件服务器授权码（注意！非账号登陆密码）
      #- MAIL_PASSWORD=passwd
      # 邮件服务器加密类型
      #- MAIL_ENCRYPTION=TLS
      # 发送人名字
      #- MAIL_FROM_ADDRESS=hello@example.com
      # 自定义用户名
      #- MAIL_FROM_NAME=自定义用户名



####### 数据库 #######

### mysql数据库 ###
  mysql:
    container_name: mysql
    # 请使用高于 "mysql:5.6" 的版本
    image: mysql:5.7
    networks:
      - 94list
    ports:
      # 注意！左侧开放端口不要与其他项目端口重复
      - 6706:3306
    restart: always
    volumes:
      - ./mysql/conf:/etc/mysql/conf.d
      - ./mysql/logs:/logs
      - ./mysql/data:/var/lib/mysql
    environment:
      # 用户组id
      - PUID=1000
      - PGID=1000
      # 时区
      - TZ=Asia/Shanghai
      # root用户登录密码
      - MYSQL_ROOT_PASSWORD=passwd
      # 94list用户登录账号密码
      - MYSQL_USER=94list
      - MYSQL_PASSWORD=123456
      - MYSQL_DATABASE=94list



###### 数据库UI管理 ######
# adminer 与 phpmyadmin 二选一即可，无需搭建两个

### adminer-UI管理 ###
  adminer_ui:
    container_name: adminer
    image: adminer:latest
    networks:
      - 94list
    ports:
      # 注意！左侧开放端口不要与其他项目端口重复
      - 6703:8080
    restart: always
    environment:
      # 绑定数据库，请填入可访问数据库的地址，同个"docker-compose"部署下，"network" 相同也可以直接填入容器名
      - ADMINER_DEFAULT_SERVER=mysql
    depends_on:
      - 94list

### phpmyadmin-UI管理 ###
  phpmyadmin_ui:
    container_name: phpmyadmin
    image: phpmyadmin
    networks:
      - 94list
    ports:
        # 注意！左侧开放端口不要与其他项目端口重复
      - 6704:80
    restart: always
    environment:
      - TZ=Asia/Shanghai
      - PMA_ARBITRARY=0
      # 绑定数据库，请填入可访问数据库的地址，同个"docker-compose"部署下，"network" 相同也可以直接填入容器名
      - PMA_HOST=mysql
    depends_on:
      - 94list



##### 自动创建网卡 #####
### 必选项！！！ ###
# 定义网口类型
networks:
  94list:
    driver: bridge
EOF
    docker-compose up -d
    if [ $? -ne 0 ] ; then
        error "** 错误：容器创建失败，请翻译以上英文报错，Google/百度尝试解决问题！"
    else
        sleep 30
        ok "94list-laravel容器已启动，输入：docker ps -a 查看容器启动情况！"
	ok "浏览器访问: http://宿主机ip:6702\t访问解析初始化安装页面"
	ok "浏览器访问:http://宿主机ip:6703\t>访问admin后台管理页面"
	ok "浏览器访问:http://宿主机ip:6704\tphpadmin后台管理页面"
	ok "宿主机ip:6706数据库端口"
    fi
else
    error "已有94list-laravel名称的容器在运行，不能重复创建！"
        exit 1
fi
}

docker_install() {
    if [ -x "$(command -v docker)" ]; then
        ok  "检测到 Docker 已安装!"
    else
        if [ -r /etc/os-release ]; then
            lsb_dist="$(. /etc/os-release && echo "$ID")"
        fi
        if [ $lsb_dist == "openwrt" ]; then
            error  "openwrt 环境请自行安装 docker"
            exit 1
        else
            ing  "开始安装 docker 环境..."
#            curl -sSL https://get.daocloud.io/docker | sh
	    wget https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz  && gunzip docker-24.0.7.tgz && tar -xf docker-24.0.7.tar

	    cp -a docker/*  /usr/bin/

	    cat > /etc/systemd/system/docker.service << EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
  
[Service]
Type=notify
ExecStart=/usr/bin/dockerd 
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
  
[Install]
WantedBy=multi-user.target
EOF

	    chmod 777 /etc/systemd/system/docker.service
            sleep 2

                    if [ -x "$(command -v docker)" ]; then
            mkdir /etc/docker
            cat > /etc/docker/daemon.json <<EOF
{
    "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn/","https://hub-mirror.c.163.com","https://registry.docker-cn.com"]
}
EOF
            chmod +x /etc/docker/daemon.json
            ok "安装 docker 环境...完成!"
	    ok "删除docker安装包"
	    rm -rf ./docker*
            systemctl enable docker
            systemctl restart docker
                        else
                        error "docker安装失败，请排查原因或手动完成安装在重新运行"
                        exit 2
                        fi
        fi
    fi
}


docker_compose() {
if [ -x "$(command -v docker-compose)" ]; then
ok "docker-compose已安装"
else
ing "开始安装docker-compose..."
#curl -L https://get.daocloud.io/docker/compose/releases/download/v2.6.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
#curl -L https://github.com/docker/compose/releases/download/2.23.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
wget https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-`uname -s`-`uname -m` -O /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ok "安装docker-compose...完成"
fi
}

ing "开始下载docker镜像并安装，速度根据您的网速决定，请耐心等待....."
read -p "按任意键开始部署。。。"
docker_install
docker_compose
ing "开始创建容器，如果长时间卡住 ctrl+c终止后重试！！！"
docker_run 
read -p "浏览器确认已经能访问安装页面了?，那就按任意键继续！"
sleep 2
ok "94list-laravel已部署完成，数据保存路径为$datav，输入docker ps -a查看所有容器。admin管理登陆页面账号密码为：admin/admin。\t数据库登陆账号密码可选root，root密码为passwd。可选94list，94list密码为123456。数据库名：94list。\tphp管理页面的登陆账号密码与数据库登陆账号密码相同"









