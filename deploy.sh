#!/bin/bash
IMAGE_FILE_PATH="/home/ec2-user/app/image.txt"
ECR_URL_PATH="/home/ec2-user/app/ecr-url.txt"
IMAGE_NAME=$(cat "$IMAGE_FILE_PATH") #image.txt에 저장한 도커이미지 정보
ECR_URL=$(cat "$ECR_URL_PATH") #ecr-url.txt에 저장한 ECR URL 정보
CONTAINER_NAME="dev-container"

# 현재 실행 중인 컨테이너 ID들 중 해당 컨테이너 이름으로 된 것이 있는지 확인
CURRENT_PID=$(sudo docker ps -a --filter "name=$CONTAINER_NAME" -q)

if [ -z "$CURRENT_PID" ]; then
  echo "> 현재 $IMAGE_NAME 이미지로 구동 중인 Docker Container가 없습니다"
else
  echo "> 실행 중인 Docker 컨테이너 삭제"
  sudo docker stop $CURRENT_PID

  echo "> 기존 컨테이너 정지"
  sudo docker rm $CURRENT_PID

  echo "> 기존 Docker 이미지 삭제"
  sudo docker rmi $IMAGE_NAME

  echo "> Docker에서 사용하지 않는 자원 삭제"
  docker system prune -af
  sleep 4
fi


echo "> login to ECR"
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin $ECR_URL

echo "> docker pull $IMAGE_NAME"
docker pull $IMAGE_NAME

echo "> docker run $IMAGE_NAME"
docker run -d -p 3001:3000 --name $CONTAINER_NAME -e NODE_ENV=dev --restart always $IMAGE_NAME

