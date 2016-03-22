REGISTRY_NAME ?= markbnj
SHELL = /bin/bash
IMAGE_NAME ?= cluster-iperf
TAG ?= 0.0.1
LOG_NAME ?= image-build.log
CLIENT_NAME = iperf-client
SERVER_NAME = iperf-server
SERVER_PORT = 5001

.rm-client:
	if (docker ps -a | grep -q $(CLIENT_NAME)); then docker rm -f $(CLIENT_NAME); fi

.rm-server:
	if (docker ps -a | grep -q $(SERVER_NAME)); then docker rm -f $(SERVER_NAME); fi

cluster-iperf:
	docker build --tag=$(REGISTRY_NAME)/$(IMAGE_NAME):$(TAG) --rm=true --force-rm=true docker | tee docker/$(LOG_NAME)

run-server: .rm-server
	docker run -it -h $(SERVER_NAME) --name=$(SERVER_NAME) -p $(SERVER_PORT):$(SERVER_PORT) -e "ROLE=server" $(REGISTRY_NAME)/$(IMAGE_NAME):$(TAG)

run-client: .rm-client
	docker run -it -h $(CLIENT_NAME) --name=$(CLIENT_NAME) -e "ROLE=client" -e "REMOTE_ADDR=iperf-server" --link iperf-server:iperf-server $(REGISTRY_NAME)/$(IMAGE_NAME):$(TAG)

clean: .rm-client .rm-server
	if (docker images | grep -q $(REGISTRY_NAME)/$(IMAGE_NAME)); then docker rmi $(REGISTRY_NAME)/$(IMAGE_NAME):$(TAG); fi
	rm -f docker/image-build.log

build: clean cluster-iperf
