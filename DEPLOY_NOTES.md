# LskyPro Docker 部署说明

## 重要提示

### 每次容器重启后的必要操作

由于 Dockerfile 构建时的限制，每次重启容器后需要手动执行以下命令来启用 Apache mod_rewrite 模块：

```bash
docker exec lskypro-official a2enmod rewrite
docker exec lskypro-official apachectl graceful
```

如果不执行此操作，访问 LskyPro 时会出现 404 Not Found 错误。

### 手动安装 BCMath 扩展

如果容器重启后发现 BCMath 扩展丢失（安装向导显示 BCMath 检测失败），需要手动安装：

```bash
docker exec lskypro-official docker-php-ext-install bcmath
docker exec lskypro-official apachectl graceful
```

## 数据库配置信息

数据库密码在 docker-compose.yml 中配置，默认为 `xxxxxx`。

安装 LskyPro 时使用的数据库配置：
```
数据库主机: lskypro-db-official
数据库端口: 3306
数据库名称: lskypro
数据库用户名: lskypro
数据库密码: xxxxxx
```

### 重要：.env 文件配置

`.env` 文件被 .gitignore 忽略，需要手动配置。在首次部署前，确保 `.env` 文件中的数据库配置正确：

```env
DB_CONNECTION=mysql
DB_HOST=lskypro-db-official
DB_PORT=3306
DB_DATABASE=lskypro
DB_USERNAME=lskypro
DB_PASSWORD=xxxxxx
```

配置后执行以下命令清除缓存：
```bash
docker exec lskypro-official php artisan config:clear
```

## 修改数据库密码

如需修改数据库密码，需要编辑 `docker-compose.yml` 文件中的两处：

1. LskyPro 服务环境变量中的 `DB_PASSWORD`
2. MySQL 服务环境变量中的 `MYSQL_PASSWORD`

修改后需要重新创建容器：
```bash
docker compose down -v
docker compose up -d
```

## Docker 构建说明

### Dockerfile-simple 包含的扩展

- PHP 8.1 with Apache
- ImageMagick 和 Imagick PECL 扩展
- BCMath 扩展（用于数学精度处理）
- PDO MySQL 扩展
- Apache mod_rewrite 模块

### 构建镜像

```bash
docker compose build
```

注意：由于网络问题，`pecl install imagick` 可能会失败。如果构建失败，可以使用现有镜像并在运行时手动安装扩展。

## 访问地址

- LskyPro 安装页面: http://localhost:8091/install
- LskyPro 管理后台: http://localhost:8091

## 常见问题

### 404 Not Found

原因：Apache mod_rewrite 模块未启用

解决方法：
```bash
docker exec lskypro-official a2enmod rewrite
docker exec lskypro-official apachectl graceful
```

### BCMath 扩展检测失败

原因：BCMath 扩展未安装

解决方法：
```bash
docker exec lskypro-official docker-php-ext-install bcmath
docker exec lskypro-official apachectl graceful
```

### 容器无法启动

检查 Docker 和 Docker Compose 是否正常运行：
```bash
docker ps -a
docker compose logs
```

## 代码修改说明

本项目对官方 LskyPro 代码进行了以下修改：

1. **app/Services/ImageService.php**: 添加了对 `album_id` 参数的支持，允许上传时指定相册ID
2. **config/image.php**: 设置图像驱动为 `imagick`（使用 ImageMagick）
3. **docker-compose.yml**: 添加了 MySQL 8.0 数据库服务和环境变量配置
4. **Dockerfile-simple**: 简化的 Dockerfile，包含所有必需的 PHP 扩展

## 与 Obsidian 插件的集成

此版本的 LskyPro 支持通过 API 上传图片到指定相册。Obsidian 插件可以使用以下参数：

- `album_id`: 指定上传到的相册ID

这解决了原版 coldpig/lskypro-docker 镜像不支持 album_id 参数的问题。
