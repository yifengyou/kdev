

# skill

## github relase get filename list

```
curl -s "https://api.github.com/repos/yifengyou/kdev/releases/tags/opencloudos-rootfs"   | jq -r '.assets[].name'
```
