FROM itzg/minecraft-server

ENV TZ=Asia/Tokyo
ENV S3_BUCKET_NAME="minecraftbucket"
ENV S3_PREFIX_NAME="backups-path"
ENV WEBHOOK_PATH="webhook-path"

# install aws cli
RUN apt-get update && apt-get install -y  \
    ca-certificates \
    curl \
    unzip \
    tini \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install -i /usr/local/aws-cli -b /usr/bin

WORKDIR /data

COPY --chown=1000:1000 ./scripts /scripts
RUN chmod -R 755 /scripts

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/scripts/entrypoint.sh"]