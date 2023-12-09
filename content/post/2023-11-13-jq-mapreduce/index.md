---
title: Who Needs Hadoop? Building Distributed MapReduce With Jq, Parallel, and SSH
slug: 2023-11-13-jq-mapreduce
description: 
date: 2023-11-13
tags: [jq, mapreduce, ssh, featured, parallel]
description: A poor man's quest to understand MapReduce by building it from first principles
weight: 1
image: "elephant.jpg"
draft: true
categories:
- featured-articles
---

> Cover Photo by [PRENATO CONTI](https://www.pexels.com/photo/silhouette-photo-of-elephant-during-golden-hour-2677843/)

I was in a mood to mess around with some more `jq` after my [last post](/blog/2023-11-06-jq-by-example/), and I came across the New York City Taxi and Limousine Comission's [dataset](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page).

## Downloading The Data
### Getting the URLs
I want to download all the parquet files on this page so I can do things with them. To do that, I need a list. I can extract that by using `wget` and this [neat trick](https://unix.stackexchange.com/a/181275)

All we need is a terminal and some basic commands. Here's how it works:

```bash
wget -qO- https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page | 
tr \" \\n | 
grep https\*:// | 
grep \.parquet > urls.txt
```

First, we use the `wget` command to download the content of the specified URL. The `-q` option makes `wget` operate in quiet mode (no output except for errors), and the `-O-` option directs the output to the standard output (stdout). This way, we don't have to save the page to a file and then read it.

Next, we use the `tr` command to translate (replace) double quotes (`"`) with newline characters (`\n`). This effectively separates the content of the downloaded page so that each URL is on a new line. This makes it easier to filter them later.

Then, we use the `grep` command twice: First, to filter lines that contain URLs starting with `"https://"`, and again to filter the lines to include only those containing ".parquet". 

The backslash (`\`) is used to escape the asterisk (`*`) and period (`.`) to ensure that it is treated as a literal character rather than a wildcard. These two __could__ have been kept in one command, but I kept things broken down here for simplicity's sake.

Finally, we send the output to a file, `urls.txt`

And that's it! We have a list of parquet files that you can download from the web page. Pretty cool, huh?

Checking the number of urls (as of writing in November 2023):
```bash
$ cat urls.txt | wc -l
456
```

That's a LOT of files!

### Checking the size
Let's find the amount of data we'll be downloading:
```
cat urls.txt | 
xargs -n 1 sh -c 'curl -s -I $@ | grep "content-length" | cut -d" " -f2' sh | 
python3 -c "import sys; print(sum(int(l) for l in sys.stdin))" | 
numfmt --to=iec-i --suffix=B --format="%9.2f"
```

This command calculates the total size of the files that are to be downloaded. Here is how it works:

- The `cat urls.txt` part reads the file urls.txt. This file contains one URL per line.
- The `xargs -n 1 sh -c 'curl -s -I $@ | grep "content-length" | cut -d" " -f2' sh` part takes each URL from the left side of the pipe (`cat`) and executes an embedded one-liner. The output of the curl command is something like this:
```
curl -s -I https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2023-01.parquet
```

```
HTTP/2 200
content-type: application/x-www-form-urlencoded; charset=utf-8
content-length: 47673370
date: Sat, 11 Nov 2023 08:54:50 GMT
last-modified: Mon, 20 Mar 2023 20:46:51 GMT
etag: "c1744317232f0b94f424e50e381189b5-3"
x-amz-server-side-encryption: AES256
accept-ranges: bytes
server: AmazonS3
x-cache: Hit from cloudfront
via: 1.1 aa3540758216629202cc04ae30ab5604.cloudfront.net (CloudFront)
x-amz-cf-pop: SLC50-C1
x-amz-cf-id: K1c7Gt8bad9NG00_toV9y_epff3yNb7exUdKoaZ81J7ehXyL9tQ1BA==
age: 41619
```
  This makes it easier to understand how the one-liner is working:
  - The `curl -s -I $@` part downloads the header of the URL and prints it to the standard output. The `-s` option makes curl silent, and the `-I` option makes it only show the header. The `$@` variable represents the argument passed to the shell script, which is the URL in this case.
  - The `grep "content-length"` part filters the output of curl and only keeps the line that contains the string "content-length". This line shows the size of the file in bytes.
  - The `cut -d" " -f2` part splits the line by spaces and extracts the second field, which is the size of the file in bytes.
- The `python3 -c "import sys; print(sum(int(l) for l in sys.stdin))"` part takes the sizes of all the files from the standard input and sums them.
- The `numfmt --to=iec-i --suffix=B --format="%9.2f"` part formats the output of Python using a utility called numfmt. The `--to=iec-i` option converts the number to a human-readable format using binary prefixes, such as KiB, MiB, GiB, etc. The `--suffix=B` option adds a B at the end to indicate bytes. The `--format="%9.2f"` option specifies how to display the number, using two decimal places and a fixed width of nine characters.

### It takes too long
It takes an awfully long time to run-- on my laptop with decent internet, it takes over 9 minutes-- why?

It takes so long because xargs is only doing one thing at a time. It waits for each request to complete before moving on to the next one. 

We can try to make this faster by running more of the same thing at the same time. But how?

### Enter GNU Parallel

GNU Parallel is a command-line tool for *nix operating systems created by [Ole Tange](http://ole.tange.dk/), a Danish computer scientist and bioinformatician using Perl. This tool facilitates parallel execution of shell commands, simplifying the utilization of multiple processors and cores for parallel processing tasks. It works great as a replacement for some use cases, and a complement to `xargs`. 

Let's take a moment to review the basic usage of `parallel`. 

Imagine we have a directory full of text files, and we want to create one gzip file for each file. We can do that like so:

```bash
ls *.txt | parallel gzip {}
```

We can also modify the number of concurrent processes that `parallel` should spawn using the `-j` flag. By default it is the number of CPU cores on the system.

```bash
ls *.txt | parallel -j 4 gzip {}
```

This consumes lines from the left side of the pipe, and runs the given command in parallel. Like in `xargs` we have the `$@` which substitues the argument, here we use `{}`.

We can easily tweak this into our previous workflow. Let's use `parallel` instead of `xargs` to get the file sizes:


```bash
cat urls.txt | parallel -j 4 "curl -s -I {} | grep 'content-length' | cut -d' ' -f2"
```

A nice side effect is that it looks a lot cleaner as well. We limit the workers to be polite and not send too many requests too fast.

It runs a lot faster. Using 4 worker processes, it now takes only 1 minute and 7 seconds to get the size of all the files I would need to download

```bash
cat urls.txt | parallel -j 4 "curl -s -I {} | grep 'content-length' | cut -d' ' -f2" | cat | python3 -c "import sys; print(sum(int(l) for l in sys.stdin))" | numfmt --to=iec-i --suffix=B --format="%9.2f"
# $ time ./get_total_download_size.sh urls.txt
# 16.12GiB
# 
# real    1m7.406s
# user    0m37.730s
# sys     0m4.285s
```

Wow! Let's download all the parquet files in the same way:

```
cat urls.txt | parallel -j 4 wget {}
```
Since my home internet is quite slow, I ran this on a server with a 25GB SSD, only to be surprised at my disk filling up. A deeper investigation into this is warranted, but that's a topic for later.

Faced with a roadblock, let's back up and re-evaluate

## The situation so far

* There are a bunch of large parquet files which make up the dataset we are interested in
* I don't want to query parquet files, since this is an article about `jq`   
  * I need to get all the data in JSON
* I can't download all the files at home or in one server

Thinking further,

* What if I can distribute the task among many servers?
  * I can create a number of servers on demand, say 4.
  * I can ask them to download each file and convert it into JSON
  * Then I can store all the converted JSON files in some central location
  * Since the data is already nicely segmented, I can re use those same servers to do queries on the segmented data
