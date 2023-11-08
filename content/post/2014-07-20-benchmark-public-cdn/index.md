---
title: Benchmark public javascipt CDNs on a VPS
tags: [cdn, benchmark, networking, linux]
date: 2014-07-20
slug: 2014-07-20-benchmark-public-cdn
categories:
- Legacy
---

> This is a legacy script from when I was 13 years old. Please don't give me a hard time

```sh
#!/bin/bash
function speedTest {
	# ripped off from http://freevps.us/downloads/bench.sh 
	local the_speed=$( wget -O /dev/null "http://$1" 2>&1 | awk '/\/dev\/null/ {speed = $3 $4} END {gsub(/\(|\)/,"",speed); print speed}')
	echo $the_speed
}

echo "jsTest.sh by IshanDS www.ishands.cf"
echo ""
# CDNJs
cdnjs=$(speedTest "cdnjs.cloudflare.com/ajax/libs/jquery/2.1.1/jquery.min.js")
echo "Speed from CDNJs:             $cdnjs"

# Google CDN
google=$(speedTest "ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js")
echo "Speed from Google CDN:        $google"

# jsDelivr
jsdelivr=$(speedTest "cdn.jsdelivr.net/jquery/2.1.1/jquery.min.js")
echo "Speed from jsDelivr:          $jsdelivr"

# MaxCDN OSS
maxcdn=$(speedTest "oss.maxcdn.com/jquery/2.1.1/jquery.min.js")
echo "Speed from MaxCDN:            $maxcdn"

# Jquery CDN
jquery=$(speedTest "code.jquery.com/jquery-2.1.1.min.js")
echo "Speed from Jquery CDN:        $jquery"

# Microsoft CDN
microsoft=$(speedTest "ajax.aspnetcdn.com/ajax/jquery/jquery-2.1.1.min.js")
echo "Speed from Microsoft CDN:     $microsoft"

echo ""
echo "Thank you for using jsTest.sh"
```
