#!/bin/bash

# TERRAFORM_OUTPUT=$(terraform output -json container_id | jq -r '.' | jq -c '.[]' | sed "s/\"//g")
# echo $TERRAFORM_OUTPUT
NUMBER_OF_AGENTS=$(terraform output -json container_id | jq -r '.' | jq -c '.[]' | sed "s/\"//g" | wc -l)
NUMBER_OF_RUNNING_AGENT=0

getContainerInfo() {
	DOCKER_CONTAINER_ID="$1"
	DOCKER_CONTAINER_NAME=$(docker inspect $DOCKER_CONTAINER_ID --format "{{.Name}}" | sed 's/\///')

	IS_CONTAINER_EXIST=$(docker ps -a | awk '{print $NF}' | grep -e "^$DOCKER_CONTAINER_NAME$")	

	[[ -z $IS_CONTAINER_EXIST ]] && (
		sh -c "terraform apply -lock=false -auto-approve"	
	) || (
		IS_CONTAINER_RUNNING=$(docker ps | awk '{print $NF}' | grep -e "^$DOCKER_CONTAINER_NAME$")
	
		[[ ! -z $IS_CONTAINER_RUNNING ]] && (
			echo "Container $DOCKER_CONTAINER_NAME is running with port:" $(docker port $DOCKER_CONTAINER_ID | awk '{print $3}' | cut -d : -f 2)
			NUMBER_OF_RUNNING_AGENT=$(($NUMBER_OF_RUNNING_AGENT + 1))
		)  || (docker start $DOCKER_CONTAINER_NAME)
	)
}

terraform output -json container_id | jq -r '.' | jq -c '.[]' | sed "s/\"//g" | while read i; do
	getContainerInfo $i
done


