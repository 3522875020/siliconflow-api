# 使用Python 3.9作为基础镜像
FROM python:3.9-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV PORT=10000
ENV FLASK_APP=app.py
ENV FLASK_ENV=production

# 安装curl用于健康检查
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用程序代码
COPY . .

# 暴露端口
EXPOSE 10000

# 添加健康检查
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:10000/health || exit 1

# 启动命令（将由render.yaml覆盖）
CMD ["gunicorn", "--bind", "0.0.0.0:10000", "--workers", "4", "--timeout", "600", "--access-logfile", "-", "--error-logfile", "-", "app:app"] 