#!/bin/bash

curl -L -o g.tar.gz https://github.com/fullstorydev/grpcurl/releases/download/v1.8.7/grpcurl_1.8.7_linux_x86_64.tar.gz

tar xf g.tar.gz

mv grpcurl /root/.local/bin

rm g.tar.gz
