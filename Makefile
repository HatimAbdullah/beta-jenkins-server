all: stop start exec

start:
	docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock -v $$(pwd):/work -v $$PWD/creds:/root/.aws -v terraform-plugin-cache:/plugin-cache -w /work --name beta-env  lordblackfish/mars-env

build:
	time packer build packer.json

init:
	rm -rf .terraform ssh
	mkdir ssh
	time terraform init
	ssh-keygen -t rsa -f ./ssh/id_rsa -q -N ""

plan:
	time terraform plan -out plan.out

apply:
	time terraform apply plan.out

cnct:
	ssh -i ssh/id_rsa ubuntu@$$(terraform output -json | jq '.jenkins-gateway.value' | xargs)

