include ../Makefile

APP=$(notdir $(shell pwd))
TAG=v3.5.0
TARGET=$(FLOAT_NAMESPACE)/$(APP):$(TAG)

build:
	$(BUILDER) build -f $(TAG)/ContainerFile -t $(TARGET) .

push: build
	$(BUILDER) push $(TARGET)

run-aws:
	float submit -j run_jupyter_lab.sh -i jupyter_server:${TAG} -c 4 -m 16 -P 8888:8888 --dataVolume [size=10]:/data
