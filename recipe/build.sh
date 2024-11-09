#!/bin/bash

set -ex

GO_VERSION="1.23.3"

# Determine OS and architecture for Go download
# Set empty GOROOT for Linux builds based on
# https://stackoverflow.com/a/57892698
if [[ "$target_platform" == "linux-ppc64le" ]]; then
    GO_TARBALL="go${GO_VERSION}.linux-ppc64le.tar.gz"
    export GOROOT=""
fi

# Download and install external Go
curl -LJO "https://go.dev/dl/${GO_TARBALL}"
mkdir -p ${PREFIX}/go_installed
tar -C ${PREFIX}/go_installed -xzf ${GO_TARBALL}
export PATH=${PREFIX}/go_installed/go/bin:${PATH}
go version


# Build Hugo
export GO111MODULE=on
export CGO_ENABLED=1

cd $SRC_DIR
go build -ldflags "-s -w -X main.revision=conda-forge -X github.com/gohugoio/hugo/common/hugo.vendorInfo=conda-forge" -tags extended,withdeploy -trimpath -v -o $PREFIX/bin/hugo
go-licenses save . --save_path ./library_licenses
chmod -R u+w $(go env GOPATH) && rm -r $(go env GOPATH)

# Clean up Go installation files
rm -f "${GO_TARBALL}"