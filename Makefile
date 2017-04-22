#! /usr/bin/make
#
# Makefile for goa examples in appengine
#
# Targets:
# - appengine
# This command makes necessary changes to use with GAE / Go.
# Also, please be sure to vendoring If you use this command.
#

##### For Example ######

for_example: install bootstrap delete

delete:
	rm ./hello.go
	rm ./main.go

##### Convenient command ######

REPO:=github.com/goadesign/examples/appengine
GAE_PROJECT:=projectName

init: install bootstrap appengine
all: clean generate appengine

bootstrap:
	@goagen bootstrap -d $(REPO)/design

clean:
	@rm -rf app
	@rm -rf client
	@rm -rf tool
	@rm -rf swagger

generate:
	@goagen app     -d $(REPO)/design
	@goagen swagger -d $(REPO)/design
	@goagen client  -d $(REPO)/design

install:
	@which glide || go get -v github.com/Masterminds/glide
	@glide install

appengine:
	@which gorep || go get -v github.com/novalagung/gorep
	@gorep -path="./vendor/github.com/goadesign/goa" \
          -from="context" \
          -to="golang.org/x/net/context"
	@gorep -path="./app" \
          -from="context" \
          -to="golang.org/x/net/context"
	@gorep -path="./client" \
          -from="context" \
          -to="golang.org/x/net/context"
	@gorep -path="./tool" \
          -from="context" \
          -to="golang.org/x/net/context"
	@gorep -path="./" \
          -from="../app" \
          -to="$(REPO)/app"
	@gorep -path="./" \
          -from="../client" \
          -to="$(REPO)/client"
	@gorep -path="./" \
          -from="../tool/cli" \
          -to="$(REPO)/tool/cli"

deploy:
	goapp deploy -application $(GAE_PROJECT) ./app

rollback:
	appcfg.py rollback ./app -A $(GAE_PROJECT)

local:
	goapp serve ./server