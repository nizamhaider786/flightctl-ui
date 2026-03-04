#Makefile to build flightctl-ui
IMAGE_REGISTRY ?= 10.200.170.11:5000
IMAGE_NAME ?= flightctl-ui
PLUGIN_IMAGE_NAME ?= flightctl-ocp-ui
IMAGE_TAG ?= latest
CONTAINER_FILE ?= flightctl-ui.offline
PLUGIN_CONTAINER_FILE ?= Containerfile.ocp

# Declare phony targets (targets that don't represent physical files)
.PHONY: all build-ui container push clean

all: container

build-ui:
	@echo "==> Building the flightctl-ui static assets..."
	npm run build

container: build-ui
	@echo "==> Building the Podman container using $(CONTAINER_FILE)..."
	podman build -f $(CONTAINER_FILE) -t $(IMAGE_REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG) .
	@echo "==> Building the Podman ocp plugin container using $(PLUGIN_CONTAINER_FILE)..."
	podman build -f $(PLUGIN_CONTAINER_FILE) -t $(IMAGE_REGISTRY)/$(PLUGIN_IMAGE_NAME):$(IMAGE_TAG) .

push:
	@echo "==> Pushing $(IMAGE_NAME) to $(IMAGE_REGISTRY)..."
	podman push $(IMAGE_REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
clean:
	@echo "==> Cleaning up compiled UI directories..."
	rm -rf dist/ apps/*/dist/ packages/*/dist/
	@echo "==> Removing local container image..."
	-podman rmi $(IMAGE_REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG) || true
