FLAGS=-trimpath -ldflags "-s -w"
VER=$(shell git describe --tags --long --always)
BINS=spyderbat-event-forwarder.x86_64 spyderbat-event-forwarder.aarch64
FILES=$(BINS) example_config.yaml spyderbat-event-forwarder.service install.sh README.md

help:
	@echo please visit README.md

tests:
	go test ./...

release: clean tests
	GOARCH=amd64 go build $(FLAGS) -o spyderbat-event-forwarder.x86_64 ./spyderbat-event-forwarder
	GOARCH=arm64 go build $(FLAGS) -o spyderbat-event-forwarder.aarch64 ./spyderbat-event-forwarder
	tar cfz spyderbat-event-forwarder.$(VER).tgz $(FILES)
	@echo '>>>' spyderbat-event-forwarder.$(VER).tgz

deploy: release
	sudo ./install.sh
	sudo systemctl restart spyderbat-event-forwarder.service
	sudo journalctl -fu spyderbat-event-forwarder.service

clean:
	rm -f $(BINS) *.tgz

updatecontainer:
	aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/a6j2k0g1
	docker buildx build --platform=linux/amd64,linux/arm64 --push -t public.ecr.aws/a6j2k0g1/event-forwarder:latest .

