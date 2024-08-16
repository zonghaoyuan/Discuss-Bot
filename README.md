这个脚本用于自动化操作以保持 Linux.do 网站的活跃状态，包括浏览帖子并进行点赞，以及通过WxPusher推送消息到微信(可选)。

下面是详细介绍如何在 Windows、Linux 服务器、GitHub Workflow 中配置并运行此 `Linux.do保活脚本` 的 Markdown 文档。

---

# Linux.do 保活脚本配置与运行指南

## 概述

本指南将详细介绍如何在不同环境下（Windows、Linux 服务器、GitHub Workflow）配置并运行 `Linux.do保活脚本`。该脚本通过 Playwright 自动化操作对 `Linux.do` 网站的帖子进行浏览和点赞，并支持通过 WxPusher 发送通知。

## 环境依赖

- Python 3.7+
- [Playwright](https://playwright.dev/python/docs/intro) 库
- [requests](https://docs.python-requests.org/en/latest/) 库
- 在服务器或 CI 环境中运行时，需配置 WxPusher 以接收脚本执行结果通知(可选)
- WxPusher：https://wxpusher.zjiecode.com/ 查看官方手册(可选)

## 变量检查与说明

- USERNAME: 登录 Linux.do 的用户名。
- PASSWORD: 登录 Linux.do 的密码。
- LIKE_PROBABILITY: 点赞概率，值在 0 和 1 之间，例如 0.02 表示 2% 的概率点赞。
- HOME_URL: Linux.do 的主页 URL，默认为 https://linux.do/。
- CONNECT_URL: 连接信息页面的 URL，默认为 https://connect.linux.do/。
- USE_WXPUSHER: 是否使用 wxpusher 发送消息通知，true 或 false。
- APP_TOKEN: wxpusher 应用的 appToken，当 USE_WXPUSHER 为 true 时需要配置。
- TOPIC_ID: wxpusher 的 topicId，当 USE_WXPUSHER 为 true 时需要配置。
- MAX_TOPICS: 最大处理的主题数量，如果超过此数量则只处理前 MAX_TOPICS 个主题。

## 一、在 Windows 上配置与运行

### 1.1 安装依赖

首先，确保你已经安装了 Python 3.7 及以上版本。然后在命令行中执行以下命令以安装所需依赖：

```bash
pip install playwright requests tabulate configparser
playwright install
```

### 1.2 配置文件

在项目根目录下创建 `config.ini` 文件，内容如下：

```ini
[credentials]
username = your_username
password = your_password

[settings]
like_probability = 0.02
max_topics = 10

[urls]
home_url = https://linux.do/
connect_url = https://connect.linux.do/

[wxpusher]
use_wxpusher = false
app_token =
topic_id =
```

### 1.3 运行脚本

在命令行中进入脚本所在目录，执行以下命令运行脚本：

```bash
python main.py
```

## 二、在 Linux 服务器上配置与运行

### 2.1 安装依赖

同样，确保服务器上安装了 Python 3.7 及以上版本。安装所需依赖：

```bash
pip install playwright requests tabulate configparser
playwright install
```

### 2.2 配置文件

在服务器main.py的同级目录 `./` 目录下创建 `config.ini` 文件：

```ini
[credentials]
username = your_username
password = your_password

[settings]
like_probability = 0.02
max_topics = 10

[urls]
home_url = https://linux.do/
connect_url = https://connect.linux.do/

[wxpusher]
use_wxpusher = true
app_token = your_app_token
topic_id = your_topic_id
```

### 2.3 设置环境变量

在 `.bashrc` 或 `.bash_profile` 中添加以下环境变量：

```bash
export LINUXDO_USERNAME="your_username"
export LINUXDO_PASSWORD="your_password"
export USE_WXPUSHER=true
export APP_TOKEN="your_app_token"
export TOPIC_ID="your_topic_id"
```

使配置生效：

```bash
source ~/.bashrc
```

### 2.4 运行脚本

进入脚本所在目录，执行以下命令：

```bash
python3 main.py
```

## 三、在 GitHub Workflow 中配置与运行

### 3.1 配置 GitHub Secrets

在 GitHub 仓库中，配置以下 Secrets：

- `LINUXDO_USERNAME`
- `LINUXDO_PASSWORD`
- `LIKE_PROBABILITY`
- `MAX_TOPICS`
- `USE_WXPUSHER`（值为 `true` 或 `false`）
- `APP_TOKEN`（如果 `USE_WXPUSHER` 为 `true`）
- `TOPIC_ID`（如果 `USE_WXPUSHER` 为 `true`）

### 3.2 配置 GitHub Workflow 文件

在项目的 `.github/workflows/` 目录下创建一个新的 Workflow 文件 `run-linuxdo.yml`：

```yaml
name: Run Linux.do Script

on:
  push:
    branches:
      - main
  schedule:
    - cron: '0 0 * * *'  # 每天 UTC 时间午夜运行一次

jobs:
  run-linuxdo:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.7

    - name: Install dependencies
      run: |
        pip install playwright requests tabulate configparser
        playwright install

    - name: Run script
      env:
        LINUXDO_USERNAME: ${{ secrets.LINUXDO_USERNAME }}
        LINUXDO_PASSWORD: ${{ secrets.LINUXDO_PASSWORD }}
        LIKE_PROBABILITY: ${{ secrets.LIKE_PROBABILITY }}
        MAX_TOPICS: ${{ secrets.MAX_TOPICS }}
        USE_WXPUSHER: ${{ secrets.USE_WXPUSHER }}
        APP_TOKEN: ${{ secrets.APP_TOKEN }}
        TOPIC_ID: ${{ secrets.TOPIC_ID }}
      run: |
        python main.py
```

### 3.3 运行 Workflow

提交或合并代码到 `main` 分支，GitHub Actions 会自动触发 Workflow 并运行脚本。你可以在 GitHub 的 Actions 页面查看运行日志。

## 四、常见问题

### 4.1 如何调试登录失败的问题？

- 确保用户名和密码正确配置在环境变量或配置文件中。
- 尝试手动访问登录页面，检查登录元素的类名或 ID 是否有变化。

### 4.2 如何调整点赞概率？

在 `config.ini` 文件或环境变量中修改 `LIKE_PROBABILITY` 的值，例如将 `0.02` 修改为 `0.05`，意味着 5% 的概率会点赞。

### 4.3 WxPusher 配置失败怎么办？

- 确保 `APP_TOKEN` 和 `TOPIC_ID` 配置正确。
- 在 WxPusher 的管理后台确认 `appToken` 是否启用，以及 `topicId` 是否可用。
- WxPusher官册：https://wxpusher.zjiecode.com/ 查看官方手册

---

按照以上指南配置并运行脚本后，您将能够在不同环境下自动浏览和点赞 `Linux.do` 的帖子，并根据配置接收通知。
