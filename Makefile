BUMP_VERSION := $(GOPATH)/bin/bump_version
RELEASE := $(GOPATH)/bin/github-release

$(BUMP_VERSION):
	go get github.com/Shyp/bump_version

$(RELEASE):
	go get -u github.com/aktau/github-release

release: $(BUMP_VERSION) $(RELEASE)
ifndef version
	@echo "Please provide a version"
	exit 1
endif
ifndef GITHUB_TOKEN
	@echo "Please set GITHUB_TOKEN in the environment"
	exit 1
endif
	git tag $(version)
	git push origin --tags
	mkdir -p releases/$(version)
	# Change the binary names below to match your tool name
	GOOS=linux GOARCH=amd64 go build -o releases/$(version)/megacheck-linux-amd64 ./cmd/megacheck
	GOOS=darwin GOARCH=amd64 go build -o releases/$(version)/megacheck-darwin-amd64 ./cmd/megacheck
	GOOS=windows GOARCH=amd64 go build -o releases/$(version)/megacheck-windows-amd64 ./cmd/megacheck

	GOOS=linux GOARCH=amd64 go build -o releases/$(version)/unused-linux-amd64 ./cmd/unused
	GOOS=darwin GOARCH=amd64 go build -o releases/$(version)/unused-darwin-amd64 ./cmd/unused
	GOOS=windows GOARCH=amd64 go build -o releases/$(version)/unused-windows-amd64 ./cmd/unused

	GOOS=linux GOARCH=amd64 go build -o releases/$(version)/staticcheck-linux-amd64 ./cmd/staticcheck
	GOOS=darwin GOARCH=amd64 go build -o releases/$(version)/staticcheck-darwin-amd64 ./cmd/staticcheck
	GOOS=windows GOARCH=amd64 go build -o releases/$(version)/staticcheck-windows-amd64 ./cmd/staticcheck

	# Change the Github username to match your username.
	# These commands are not idempotent, so ignore failures if an upload repeats
	$(RELEASE) release --user kevinburke --repo go-tools --tag $(version) || true
	$(RELEASE) upload --user kevinburke --repo go-tools --tag $(version) --name megacheck-linux-amd64 --file releases/$(version)/megacheck-linux-amd64 || true
	$(RELEASE) upload --user kevinburke --repo go-tools --tag $(version) --name megacheck-darwin-amd64 --file releases/$(version)/megacheck-darwin-amd64 || true
	$(RELEASE) upload --user kevinburke --repo go-tools --tag $(version) --name megacheck-windows-amd64 --file releases/$(version)/megacheck-windows-amd64 || true

	$(RELEASE) upload --user kevinburke --repo go-tools --tag $(version) --name unused-linux-amd64 --file releases/$(version)/unused-linux-amd64 || true
	$(RELEASE) upload --user kevinburke --repo go-tools --tag $(version) --name unused-darwin-amd64 --file releases/$(version)/unused-darwin-amd64 || true
	$(RELEASE) upload --user kevinburke --repo go-tools --tag $(version) --name unused-windows-amd64 --file releases/$(version)/unused-windows-amd64 || true

	$(RELEASE) upload --user kevinburke --repo go-tools --tag $(version) --name staticcheck-linux-amd64 --file releases/$(version)/staticcheck-linux-amd64 || true
	$(RELEASE) upload --user kevinburke --repo go-tools --tag $(version) --name staticcheck-darwin-amd64 --file releases/$(version)/staticcheck-darwin-amd64 || true
	$(RELEASE) upload --user kevinburke --repo go-tools --tag $(version) --name staticcheck-windows-amd64 --file releases/$(version)/staticcheck-windows-amd64 || true
