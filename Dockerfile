FROM ibmcom/swift-ubuntu

RUN apt-get update && apt-get install -y autoconf libtool libkqueue-dev libkqueue0 libdispatch-dev libdispatch0 libhttp-parser-dev libcurl4-openssl-dev libhiredis-dev libbsd-dev
RUN mkdir /root/zosconnect-for-swift
COPY Sources /root/zosconnect-for-swift/Sources
COPY Tests /root/zosconnect-for-swift/Tests
COPY Package.swift /root/zosconnect-for-swift
WORKDIR /root/zosconnect-for-swift
RUN swift build -Xcc -fblocks
