# 使用Python 3.9作为基础镜像
FROM python:3.9-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PORT=10000 \
    FLASK_APP=app.py \
    FLASK_ENV=production \
    PYTHONDONTWRITEBYTECODE=1

# 安装系统依赖
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# 复制依赖文件
COPY requirements.txt .

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt \
    && rm -rf ~/.cache/pip/*

# 创建非root用户
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# 复制应用程序代码
COPY --chown=appuser:appuser . .

# 暴露端口
EXPOSE 10000

# 添加健康检查
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:10000/health || exit 1

# 使用gunicorn作为生产服务器
CMD ["gunicorn", "--bind", "0.0.0.0:10000", \
     "--workers", "4", \
     "--worker-class", "gthread", \
     "--threads", "4", \
     "--timeout", "600", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "--log-level", "info", \
     "app:app"] 