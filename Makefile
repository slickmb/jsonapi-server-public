PACKAGE_DESCRIPTION="A config driven NodeJS framework implementing json:api"
APP_NAME="jsonapi-server"
APP_VERSION:=$(shell git describe --tags 2>/dev/null || echo untagged)

shell:
	/bin/bash

yarn_install:
	yarn install --no-progress

install_deps: yarn_install
	npm install nodemon -g --no-progress

test: yarn_install
	# Remove the - when we have tests to make it report errors
	-yarn test

update_package_version:
	npm --no-git-tag-version version $(APP_VERSION)

build_rpm: yarn_install
	fpm \
	    -f \
	    -s dir \
	    -t rpm \
	    -n $(APP_NAME) \
	    -v $(APP_VERSION) \
	    -C ./ --prefix=/opt/$(APP_NAME) \
	    --description $(PACKAGE_DESCRIPTION) \
	    -p /app/$(APP_NAME)-VERSION_ARCH.rpm

build_npm: yarn_install
	mkdir -p ./dist
	npm pack
	mv $(APP_NAME)-*.tgz ./dist && \
	echo $(APP_NAME)

install: install_deps build_rpm
	yum -y localinstall *.rpm

publish_rpm:
	/usr/local/bin/jfrog rt upload \
		--user expelcircleci \
		--password '$(ARTIFACTORY_PW)' \
		--url https://expel.jfrog.io/expel \
		"*.rpm" expel-yum-dev

publish_npm: build_npm
	/usr/local/bin/jfrog rt upload \
	        --user expelcircleci \
		--password '$(ARTIFACTORY_PW)' \
	    	--url https://expel.jfrog.io/expel \
		"dist/*.tgz" expelnpm-local/$(APP_NAME)/

autodeploy:
	expelctl tower deploy --package-file *.rpm $(APP_NAME)

clean:
	rm -rf node_modules $(APP_NAME)-*.rpm tmp ./dist

run: install_deps
	cd /app
	# Uncomment this and change it to suit your app.
	#nodemon -V ./bin/www ./
