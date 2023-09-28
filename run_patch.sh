#!/bin/bash

cd tunnelblick/third_party/sources/openvpn/openvpn-2.6.6/openvpn-2.6.6

patch -p1 < ../patches/02-tunnelblick-openvpn_xorpatch-a.diff
patch -p1 < ../patches/03-tunnelblick-openvpn_xorpatch-b.diff
patch -p1 < ../patches/04-tunnelblick-openvpn_xorpatch-c.diff
patch -p1 < ../patches/05-tunnelblick-openvpn_xorpatch-d.diff
patch -p1 < ../patches/06-tunnelblick-openvpn_xorpatch-e.diff
