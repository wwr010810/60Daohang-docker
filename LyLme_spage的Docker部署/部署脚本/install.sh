set -e

echo 正在确认依赖状态...
docker --version
docker-compose --version
git --version
wget --version > /dev/null

echo 输入你希望部署的目标目录，这个目录必须是未创建的:
read TARGET < /dev/tty
TARGET=$(eval echo "$TARGET")
if [ -d $TARGET ]; then
    echo $TARGET 目录已存在，请重新运行
    exit
else
    mkdir $TARGET
    cd $TARGET
    echo 正在部署到 $TARGET ...
fi

URL_BASE='https://aka.caomingjun.com/lylme/'

echo 正在初始化部署目录...
wget -nv "${URL_BASE}docker-compose.yml" -O docker-compose.yml
mkdir conf.d sqldata
wget -nv "${URL_BASE}nginx.conf" -O conf.d/nginx.conf

echo 请设置数据库密码:
read PASSWORD < /dev/tty
echo 您设置的密码是:
echo $PASSWORD
echo 请记住该密码
sed -i "s/<mysql_password>/$PASSWORD/" docker-compose.yml
echo 您希望将端口映射到:
read PORT < /dev/tty
echo 您设置的端口是：$PORT
sed -i "s/<target_port>/$PORT/g" docker-compose.yml
sed -i "s/<target_port>/$PORT/" conf.d/nginx.conf

echo 正在下载Docker镜像...
docker pull caomingjun/navpage:latest
docker pull nginx:latest
docker pull mysql:5.6

echo 正在下载网页代码...
git clone -b master https://gitee.com/LyLme/lylme_spage.git html

echo 正在启动Docker。如果启动失败，可能是出现网段或其他资源冲突，请按照输出自行解决。

docker-compose up -d

echo 部署已经完成，你可以在$PORT端口访问。数据库配置：
echo 数据库地址：10.10.10.4
echo 数据库端口：3306
echo 数据库用户：root
echo 数据库密码：$PASSWORD
echo 数据库名：navpage
echo 进阶部署教程：$URL_BASE
