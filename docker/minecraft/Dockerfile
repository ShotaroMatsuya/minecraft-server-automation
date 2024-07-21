FROM --platform=linux/x86_64 itzg/minecraft-server@sha256:c411b939cebf644159e2a239c713407d2bb12b8aee53c7662ce801c5c7386b7f

ENV TZ=Asia/Tokyo
ENV S3_BUCKET_NAME="minecraftbucket"
ENV S3_PREFIX_NAME="backups-path"
ENV WEBHOOK_PATH="webhook-path"


WORKDIR /data

# AWS CLIのインストール
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    unzip \
    vim \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install -i /usr/local/aws-cli -b /usr/bin \
    && rm -rf awscliv2.zip /var/lib/apt/lists/* /data/aws \
    && apt-get clean

COPY --chown=1000:1000 ./plugins.txt ./
COPY --chown=1000:1000 ./squaremap/*.yml plugins/squaremap/
COPY --chown=1000:1000 ./scripts /scripts
RUN chmod -R 755 /scripts

# 特定のbackupからworldを復元(backup日時(%Y%m%d%H%M%S)を指定 例：20231101201531)
ENTRYPOINT ["/scripts/entrypoint2.sh"]
