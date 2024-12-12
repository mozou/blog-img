#!/bin/bash
#
# desc: 本脚本需要放到arthas的目录中，连同整个目录一起复制到docker容器中去。主要用途为在容器中切换目标服务的用户，并启动arthas

echo "开始查询目标服务的进程id和用户..."
PID=$(ps -eo pid,user:50,args | grep java | grep -v grep | awk '{print $1}')
echo "目标服务的进程id为${PID}"
USER=$(ps -eo pid,user:50,args | grep java | grep -v grep | awk '{print $2}')
echo "目标服务的用户为${USER}"

if [[ ! -d "/home/${USER}" ]]
then
  mkdir -p /home/${USER}
  echo "创建目录/home/${USER}"
fi
chmod 777 /home/${USER}

echo "开始切换用户并启动arthas..."
# 下面的arthas路径需要修改，并且要和startArthas.sh脚本中保持一致
ARTHAS_PATH="/opt/arthas"
su ${USER} -c "java -jar ${ARTHAS_PATH}/arthas-client.jar 127.0.0.1 3658 -c 'stop'"
su ${USER} -c "java -jar ${ARTHAS_PATH}/arthas-boot.jar ${PID}"
