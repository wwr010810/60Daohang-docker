# LyLme_spage 的 Docker 部署

[LyLme_spage](https://github.com/LyLme/lylme_spage) 是 [@LyLme](https://github.com/LyLme) 的一个导航页项目，这里是其 Docker 部署指南。

为了 Docker 部署 [LyLme_spage](https://github.com/LyLme/lylme_spage) ，你需要安装 [Docker](https://docs.docker.com/engine/install/) 和 [`docker-compose`](https://docs.docker.com/compose/install/) ，并且具有互联网连接。

本指南在 Linux 下进行。如果你使用其他操作系统，请自行寻求解决办法

## 脚本自动部署

要进行自动部署，你需要：

* 架构为 `x86_64 Linux`。其他架构未经过测试，而且很可能不能运行。
* 已经安装了 [Docker](https://docs.docker.com/engine/install/) 和 [`docker-compose`](https://docs.docker.com/compose/install/) 
* 当前用户有 Docker 权限

执行命令：

```bash
curl -L 'https://aka.caomingjun.com/lylme/install.sh' | bash
```

即可完成部署。

如果不满足全部条件，建议使用手动部署。

## 手动部署

你需要一个新的文件夹，比如 `navpage` （你也可以改名）：

```bash
$ cd ~
$ mkdir navpage
cd navpage
```

下面所有过程都在 `~/navpage` 下进行。

建议不要在 `root` 下运行，以免你打错命令翻车。但是你非要这样也没关系。

### 下载文件

将本文件夹下的 `conf.d` 、 `php-mysqli` 、`docker-compo下载到 `navpage` 下(`README.md` 可以不下载)，并且新建两个文件夹 `html` 和 `sqldata` 。完成后的情况应当为：

```bash
$ cd ~/navpage
$ tree 
.
├── conf.d
│   └── nginx.conf
├── docker-compose.yml
├── html
├── php-mysqli
│   └── Dockerfile
└── sqldata

4 directories, 3 files
```

然后前往 [Gitee Releases](https://gitee.com/LyLme/lylme_spage/releases/) 或 [Github Releases](https://github.com/LyLme/lylme_spage/releases/) 下载 LyLme_spage 最新版本源码压缩包，上传到 `~/navpage/html` 并解压。

你也可以通过命令行直接在服务器下载：

```bash
$ cd ~/navpage/html
$ wget https://gitee.com/LyLme/lylme_spage/attach_files/1049110/download/lylme_spage_v1.1.5.zip
$ unzip ./lylme_spage_v1.1.5.zip
$ rm ./lylme_spage_v1.1.5.zip
```

本指南是在 `lylme_spage` 更新到 `v1.1.5` 时编写的，如果你知道你在干什么，你可以自行更改版本号、下载链接等。

### 首次启动

#### 修改数据库密码

你需要在 `docker-compose.yml` 中修改数据库密码。在第 28 行，将 `123456` 修改为你的密码。

#### 启动 Docker 镜像

```bash
$ cd ~/navpage
$ docker-compose up -d
```

首次启动时会构建镜像，可能需要一定时间。

如果你的 `80` 端口已经被占用，你可以更改端口，或者采用进阶配置中的方案。

#### 初始化网站

此时网站已经可以从 `80` 端口访问。你可以按照指引进行网站初始化，其中需要填写这些字段：

| 项目         | 值                 |
| ------------ | ------------------ |
| 数据库地址   | `10.10.10.4`       |
| 数据库用户名 | `root`             |
| 数据库密码   | 你设置的数据库密码 |
| 数据库名     | `navpage`          |

### 修改 `docker-compose.yml`

执行以下命令停止 Docker：

```bash
$ cd ~/navpage
$ docker-compose down
```

编辑 `docker-compose.yml` ，注释掉第 `17` 行，以免下次启动时重新构建镜像。

再次启动：

```bash
$ cd ~/navpage
$ docker-compose up -d
```

#### 后续管理

此时网站的配置已经完成，你今后可以这样控制它：

启动：

```bash
$ cd ~/navpage
$ docker-compose up -d
```

关闭：

```bash
$ cd ~/navpage
$ docker-compose down
```

## 进阶

**警告：进行此部分的任何操作前，确保你清楚你在干什么！不要在不了解的情况下执行任何修改和命令！**

### 通过其它nginx反向代理

你可能正在宿主机上运行 `nginx` 来管理你的 `80` 端口，或者通过 [NginxProxyManager](https://github.com/NginxProxyManager/nginx-proxy-manager) 或其他类似方式来进行反向代理。此时你需要作以下设置。

首先你可以将 `navpage-nginx` 的端口映射关闭，即注释掉 `docker-compose.yml` 第 7,8 行。

然后添加反向代理：

* 如果你使用的是宿主机的 `nginx` ，你可以直接将 `10.10.10.5` 的 `80` 端口作为反向代理的目标主机。

* 如果你使用的是 [NginxProxyManager](https://github.com/NginxProxyManager/nginx-proxy-manager) 这样Docker类型的软件，你可以将 `navpage-nginx` 加入 [NginxProxyManager](https://github.com/NginxProxyManager/nginx-proxy-manager) 所在的网络，并在 [NginxProxyManager](https://github.com/NginxProxyManager/nginx-proxy-manager) 的管理面板中设置，此时反向代理的目标主机为 `navpage-nginx` 的 `80` 端口。

### 访问控制

你可能不希望别人访问你的 `/admin` 管理界面。此时你可以修改 `nginx` 配置，为特定的 `location` 进行访问控制。

你可以参考：

* [nginx针对某个url限制ip访问，常用于后台访问限制](https://www.cnblogs.com/flying1819/articles/9162332.html)
