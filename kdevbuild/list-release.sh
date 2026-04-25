#!/bin/bash

curl -s -H "Accept: application/vnd.github+json" "https://api.github.com/repos/yifengyou/kdev/releases/tags/rockylinux-qcow2" | jq -r '.assets[] | "\(.name)"'
curl -s -H "Accept: application/vnd.github+json" "https://api.github.com/repos/yifengyou/kdev/releases/tags/centos-qcow2" | jq -r '.assets[] | "\(.name)"'
curl -s -H "Accept: application/vnd.github+json" "https://api.github.com/repos/yifengyou/kdev/releases/tags/ubuntu-qcow2" | jq -r '.assets[] | "\(.name)"'
curl -s -H "Accept: application/vnd.github+json" "https://api.github.com/repos/yifengyou/kdev/releases/tags/debian-qcow2" | jq -r '.assets[] | "\(.name)"'
curl -s -H "Accept: application/vnd.github+json" "https://api.github.com/repos/yifengyou/kdev/releases/tags/openeuler-qcow2" | jq -r '.assets[] | "\(.name)"'
curl -s -H "Accept: application/vnd.github+json" "https://api.github.com/repos/yifengyou/kdev/releases/tags/opencloudos-qcow2" | jq -r '.assets[] | "\(.name)"'
curl -s -H "Accept: application/vnd.github+json" "https://api.github.com/repos/yifengyou/kdev/releases/tags/anolis-qcow2" | jq -r '.assets[] | "\(.name)"'


