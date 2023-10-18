SERVER_DOMAIN ?= localhost
SERVER_ENDPOINT ?= /my-btc-usdt-order
SERVER ?= local

SERVER_DOMAIN_PAYPAL ?= api-m.sandbox.paypal.com
SERVER_ENDPOINT_PAYPAL ?= /v2/checkout/orders
SERVER_PAYPAL = paypal

PROXY_URL ?= localhost:8082
PROXY_SERVER ?= localhost:8080 

ROOT_DIR := $(shell pwd)
circuit_directory = local_storage/circuits

DEBUG ?= true
MEASURE ?= false

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
	@cd proxy && go run main.go -debug=$(DEBUG) -listen -proxylistener=$(PROXY_URL) -proxyserver=$(PROXY_SERVER)

.PHONY: client
client:
	@echo "--------------------------------------------"
	@echo "--------- RUNNING THE CLIENT  --------------"
	@echo "--------------------------------------------"
	@cd client && go run main.go -debug=$(DEBUG) -measure=$(MEASURE) -request -server=$(SERVER) -serverdomain=$(SERVER_DOMAIN) -serverendpoint=$(SERVER_ENDPOINT) -proxylistener=$(PROXY_URL) -proxyserver=$(PROXY_SERVER) && wait
	@cd client && go run main.go -debug=$(DEBUG) -measure=$(MEASURE) -prove -proxyserver=$(PROXY_SERVER)

client-paypal:
	@echo "--------------------------------------------"
	@echo "--------- RUNNING THE CLIENT  --------------"
	@echo "--------------------------------------------"
	@SESSION_ID=$$(uuidgen) && \
	cd client && \
	go run main.go -debug=$(DEBUG) -measure=$(MEASURE) -request -sessionid=$$SESSION_ID -server=$(SERVER_PAYPAL) -serverdomain=$(SERVER_DOMAIN_PAYPAL) -serverendpoint=$(SERVER_ENDPOINT_PAYPAL) -proxylistener=$(PROXY_URL) -proxyserver=$(PROXY_SERVER) && \
	wait && \
	go run main.go -debug=$(DEBUG) -measure=$(MEASURE) -prove -sessionid=$$SESSION_ID -proxyserver=$(PROXY_SERVER) -server=$(SERVER_PAYPAL)

