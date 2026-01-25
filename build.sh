#!/bin/bash
LATEST=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
VERSION=${LATEST#v}
echo "Installing Hugo $VERSION"
curl -sL "https://github.com/gohugoio/hugo/releases/download/${LATEST}/hugo_extended_${VERSION}_linux-amd64.tar.gz" | tar xz
./hugo --gc --minify
