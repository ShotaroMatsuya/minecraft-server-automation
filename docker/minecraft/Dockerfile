FROM --platform=linux/x86_64 itzg/minecraft-server@sha256:a0d4c9713f75772b91cfaf929d5f8c2bd2aec161d8790bfec80efe90e448332f

ENV TZ=Asia/Tokyo
ENV S3_BUCKET_NAME="minecraftbucket"
ENV S3_PREFIX_NAME="backups-path"
ENV WEBHOOK_PATH="webhook-path"

ENV VERSION="1.20.2"
ENV TYPE="SPIGOT"

WORKDIR /data

# install aws cli and cleanup
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    unzip \
    tini \
    vim \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install -i /usr/local/aws-cli -b /usr/bin \
    && rm -rf awscliv2.zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /data/aws

ENV PLUGINS_FILE="/data/plugins.txt"
COPY --chown=1000:1000 ./plugins.txt ./
COPY --chown=1000:1000 ./dynmap/configuration.txt plugins/dynmap/
COPY --chown=1000:1000 ./scripts /scripts
RUN chmod -R 755 /scripts

# ベースイメージのSIGTERMの挙動をオーバーライドし、自前のスクリプトを実行する
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/scripts/entrypoint.sh"]