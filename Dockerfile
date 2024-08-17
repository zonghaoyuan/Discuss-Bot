# 使用官方的 Python 3.7 镜像作为基础镜像
FROM python:3.7-slim

# 设置工作目录为 /app
WORKDIR /app

# 复制项目文件到容器的 /app 目录
COPY . .

# 安装项目依赖
RUN pip install playwright requests tabulate configparser && playwright install

# 设置时区为中国时区
ENV TZ=Asia/Shanghai

# 指定容器启动时执行的命令
CMD ["python", "main.py"]
