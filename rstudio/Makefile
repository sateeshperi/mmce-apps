include ../Makefile

APP=$(notdir $(shell pwd))
TAG=2022.12.0
TARGET=$(FLOAT_NAMESPACE)/$(APP):$(TAG)

build:
	$(BUILDER) build -f $(TAG)/ContainerFile -t $(TARGET) .

push: build
	$(BUILDER) push $(TARGET)

run-aws:
	float submit -j run_rstudio.sh -i rstudio:${TAG} -c 4 -m 16 -P 8787:8787 --dataVolume [size=20]:/data
