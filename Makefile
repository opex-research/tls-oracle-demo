SERVER_DOMAIN ?= localhost
SERVER_ENDPOINT ?= /my-btc-usdt-order
PROXY_URL ?= localhost:8082
PROXY_SERVER ?= http://localhost:8080 

ROOT_DIR := $(shell pwd)
circuit_directory = local_storage/circuits

DEBUG ?= true
MEASURE ?= true

init-submodules:
	@cd $(ROOT_DIR)/proxy && git submodule init && git submodule update
	@cd $(ROOT_DIR)/client && git submodule init && git submodule update

.PHONY: server
server: 
	@echo "--------------------------------------------"
	@echo "--------- RUNNING THE SERVER  --------------"
	@echo "--------------------------------------------"
	@cd server && go run main.go -debug=$(DEBUG)

.PHONY: proxy
proxy: 	
	@echo "--------------------------------------------"
	@echo "--------- RUNNING THE PROXY VERIFIER  ------"
	@echo "--------------------------------------------"
	@cd proxy && go run main.go -debug=$(DEBUG) -listen

.PHONY: client
client:
	@echo "--------------------------------------------"
	@echo "--------- RUNNING THE CLIENT  --------------"
	@echo "--------------------------------------------"
	@cd client && go run main.go -debug=$(DEBUG) -measure=$(MEASURE) -request -serverdomain=$(SERVER_DOMAIN) -serverendpoint=$(SERVER_ENDPOINT) -proxylistener=$(PROXY_URL) -proxyserver=$(PROXY_SERVER) && wait
	@cd client && go run main.go -debug=$(DEBUG) -measure=$(MEASURE) -prove -proxyserver=$(PROXY_SERVER)
