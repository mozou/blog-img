#! /bin/bash
#
# desc: 本脚本主要用途为启动arthas诊断工具来诊断某个docker中java服务

if [[ ${1} == '' ]]
then
  echo "请选择一个服务："
  sudo docker ps | awk 'NR>1 {print $2}'
  exit 0
fi

echo "开始寻找服务${1}的容器..."
DOCKER_LIST=`sudo docker ps | awk 'NR>1 {print $2}'`
FLAG=0
for i in ${DOCKER_LIST[@]}
do
  if [[ ${i} == ${1} ]]
  then
    FLAG=1
    break
  fi
done

if [[ ${FLAG} == 0 ]]
then
  DOCKER_NAME=`sudo docker ps | awk 'NR>1 {print $2}' | grep ${1}`
  if [[ ${DOCKER_NAME} == '' ]]
  then
    echo "未找到该服务的容器，请重新选择服务："
    sudo docker ps | awk 'NR>1 {print $2}'
  else
    echo "请输入服务的完整名称："
    sudo docker ps | awk 'NR>1 {print $2}' | grep ${1}
  fi

else
  ID=`sudo docker ps --filter ancestor=${1} | awk '{print $1}' | sed -n '2p'`
  echo "找到容器${ID}"

  echo "开始复制arthas到容器中..."
  # 下面的arthas路径需要修改，并且要和arthasDocker.sh脚本中保持一致
  ARTHAS_PATH="/opt/arthas"
  sudo docker exec -it ${ID} /bin/bash -c "rm -rf ${ARTHAS_PATH}"
  sudo docker cp ${ARTHAS_PATH} ${ID}:${ARTHAS_PATH}
  echo "复制完成"

  echo "即将进入容器中..."
  sudo docker exec -it ${ID} /bin/bash -c "bash ${ARTHAS_PATH}/arthasDocker.sh"
fi
