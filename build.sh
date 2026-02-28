#!/bin/bash
VERSION="0.157.0"
echo "Installing Hugo ${VERSION}"
curl -sL "https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_extended_${VERSION}_linux-amd64.tar.gz" | tar xz
./hugo --gc --minify
