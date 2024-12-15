#!/bin/bash
set -ex
payload_dumper="https://github.com/ssut/payload-dumper-go/releases/download/1.3.0/payload-dumper-go_1.3.0_linux_amd64.tar.gz"
wget -O pdg.tgz $payload_dumper
tar xf pdg.tgz payload-dumper-go
rm pdg.tgz
for device in barbet; do
        rm -rf $device || true
        mkdir $device
        pushd $device
        curl -Lso json.json "https://download.lineageos.org/api/v2/devices/$device/builds"
        zip_url=$(jq -r '.[0].files[0].url' < json.json)
        super_url=$(jq -r '.[0].files[] | select(.filename=="super_empty.img").url' < json.json)
        rm json.json
        wget -O super_empty.img $super_url
        wget -O zip.zip $zip_url
        ../payload-dumper-go zip.zip
        rm zip.zip
        mv extracted* factory
        echo -n "require board=$device" > factory/android-info.txt
        cp super_empty.img factory/
        rm super_empty.img
        cd factory
        zip ../factory.zip -r .
        cd ..
        rm -rf factory
        popd
done
rm payload-dumper-go
 
