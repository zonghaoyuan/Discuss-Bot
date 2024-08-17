# 使用官方的 Python 3.7 镜像作为基础镜像
FROM python:3.7-slim

# 设置工作目录为 /app
WORKDIR /app

# 复制项目文件到容器的 /app 目录
COPY . .

# 更换 pip 镜像源为国内镜像源，并安装 requests、tabulate 和 configparser
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip install requests tabulate configparser

# 单独安装 playwright
RUN pip install playwright && \
    playwright install

# 设置时区为中国时区
ENV TZ=Asia/Shanghai

# 指定容器启动时执行的命令
CMD ["python", "main.py"]
