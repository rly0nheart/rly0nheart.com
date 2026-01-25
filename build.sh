#!/bin/bash
curl -sL https://github.com/gohugoio/hugo/releases/download/v0.152.2/hugo_extended_0.152.2_linux-amd64.tar.gz | tar xz
./hugo --gc --minify
