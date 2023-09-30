FROM itzg/minecraft-server

ENV S3_BUCKET_NAME="minecraft-backend"
ENV S3_PREFIX_NAME="backups"

# install aws cli
RUN apt-get update && apt-get install -y  \
    ca-certificates \
    curl \
    unzip \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install -i /usr/local/aws-cli -b /usr/bin


RUN aws --version
