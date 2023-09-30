# minecraft-server-automation
# minecraft-server-automation

### ECS Exec実行

```bash
cl=$(aws ecs list-clusters | jq -r '.clusterArns[0]' )
prefix=`echo ${cl} | sed -E 's/.+cluster\///g' `
taskarn=$(aws ecs list-tasks --cluster ${cl} | jq -r '.taskArns[0]')
taskid=`echo ${taskarn} | sed -E 's/.+task\/.+\///g' `
CONTAINER_NAME="minecraft"

echo ${cl};     \
echo ${prefix} ; \
echo ${taskarn}; \
echo ${taskid};  \
echo ${CONTAINER_NAME};  \

aws ecs execute-command  \
 --region    ap-northeast-1 \
 --cluster   ${cl} \
 --task      ${taskarn} \
 --container ${CONTAINER_NAME}\
 --command "/bin/sh" \
 --interactive
```

### Simple Load Test

CPU load by repeatedly hitting the yes command

```bash
yes > /dev/null &
yes > /dev/null &
yes > /dev/null &
yes > /dev/null &
yes > /dev/null &
```

```bash
$ jobs
[1]   実行中               yes > /dev/null &
[2]   実行中               yes > /dev/null &
[3]   実行中               yes > /dev/null &
[4]   実行中               yes > /dev/null &
[5]   実行中               yes > /dev/null &
```

```bash
$ kill %1 %2 %3
[1] 終了しました yes > /dev/null
[2]- 終了しました yes > /dev/null
[3]+ 終了しました yes > /dev/null
```

The process that consumes 500MB of memory for each press of Enter is described as follows

```bash
(load-memory.sh)
#! /bin/bash
# "--bytest 5000000" is 500MB.
echo PID=$$
echo -n "[ Enter : powerup! ] , [ Ctrl+d : stop ]"
c=0
while read byte; do
   eval a$c'=$(head --bytes 5000000 /dev/zero |cat -v)'
   c=$(($c+1))
   echo -n ">"
done
echo
```

#### Run the script as follows

```bash
chmod +x load-memory.sh
./load-memory.sh
```

### Restart ECS Cluster
```bash
cl=$(aws ecs list-clusters | jq -r '.clusterArns[0]' )
svc=$(aws ecs list-services --cluster ${cl} | jq -r '.serviceArns[0]' | sed -E 's/.+cluster\///g')

aws ecs update-service --force-new-deployment --cluster ${cl} --service ${svc}

```