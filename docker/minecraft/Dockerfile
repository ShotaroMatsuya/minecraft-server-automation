FROM --platform=linux/x86_64 itzg/minecraft-server@sha256:dc57072644f235b5e766b5007859118326c4e5594c80111c46d2a5f58925bed2

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