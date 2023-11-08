---
slug: 2023-07-01-linux-ip-geolocation-list
title: Get frequency distribution of countries in a list of newline separated IP addresses in Linux
tags: [linux, xargs, sed, geoip, statistics]
date: 2023-07-01
categories:
- Snippets
---

Assuming that the IP addresses are in a file called `list.txt` in a format such as below:

```
104.28.29.66
92.40.175.51
116.255.32.201
91.150.51.170
108.167.20.103
5.187.159.175
166.198.250.121
74.78.184.213
...
```
A prerequisite for this is the `geoiplookup` command, which is available in the `geoip-bin` package on most distros.

Run the following command to get the frequency distribution:

```sh
cat list.txt | xargs -n 1 geoiplookup | sed 's/GeoIP Country Edition: //g' | sort | uniq -c | sort -r
```

This will give you an output as:

```
    462 US, United States
    124 DE, Germany
     62 CA, Canada
     47 GB, United Kingdom
     34 AU, Australia
     31 NL, Netherlands
     23 FR, France
     19 IN, India
     18 SE, Sweden
     14 FI, Finland
     10 BE, Belgium
      9 NO, Norway
      9 IT, Italy
      9 BR, Brazil
      7 SG, Singapore
      7 PT, Portugal
      7 IL, Israel
      7 CH, Switzerland
      7 AT, Austria
      6 IR, Iran, Islamic Republic of
```
