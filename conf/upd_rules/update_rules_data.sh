#!/bin/bash
#-*-coding utf-8 -*-
#########################################################################
# File Name: update_rules_data.sh
# Author: 
# mail:
# Created Time: Thu 06 Apr 2023 09:04:26 PM CST
#########################################################################
echo "=== download geoip.dat ==="
wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -O geoip.dat.new
if [ $? -ne 0 ]; then
    echo "[Err]: download geoip.dat failed!"
else
    echo "download geoip.dat done, replace it..."
    mv geoip.dat.new geoip.dat
    echo "update geoip.dat done."
fi

echo "=== download geosite.dat ==="
wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -O geosite.dat.new
if [ $? -ne 0 ]; then
    echo "[Err]: download geosite.dat failed"
else
    echo "download geosite.dat done, replace it..."
    mv geosite.dat.new geosite.dat
    echo "update geosite.dat done."
fi

echo "=== download Country.mmdb ==="
wget -q https://raw.githubusercontent.com/Loyalsoldier/geoip/release/Country.mmdb -O Country.mmdb.new
if [ $? -ne 0 ]; then
    echo "[Err]: download Country.mmdb failed"
else
    echo "download Country.mmdb done, replace it"
    mv Country.mmdb.new Country.mmdb
    echo "update Country.mmdb done."
fi

