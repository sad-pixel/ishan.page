---
title: The Ultimate Interactive JQ Guide
slug: 2023-11-06-jq-by-example
description: Learn how to search, query, and modify JSON data with 25 interactive jq examples and explanations
tags: [jq, featured]
date: 2023-11-06
lastmod: 2023-11-29
layout: "jq_post"
weight: 1
image: "numbers.jpg"
categories: 
- featured-articles
---

> Cover Photo by [Pixabay](https://www.pexels.com/photo/airport-bank-board-business-534216/)

<noscript>
This article requires JavaScript. Sorry...
</noscript>

Has this ever happened to you?

You've just received a massive JSON file that looks like it was designed to confuse you. Or maybe you entered a command, and you got so much JSON that it looks incomprehensible. 

The data you need is buried inside, and you're dreading the hours it'll take to extract and clean it up.

I've been there. I've `grep`ped my way through JSON and written ad-hoc Python scripts to process it for me. 

But things don't have to be like this.

## Introduction

`jq` is one of the best-kept secrets in the data processing world.

Here are some scenarios where `jq` could swoop in to save your day (and saves mine regularly):

1. Integrating with APIs in shell scripts often means handling JSON responses, requiring data extraction and manipulation.

2. Data from different sources may need to be converted to or from JSON format for compatibility.

3. Managing software configuration files in JSON format can be a regular task.

4. Extracting data from websites often results in dealing with JSON data that requires parsing and filtering.

5. Server logs and monitoring data often use JSON, necessitating parsing and analysis.

6. Infra as Code tools like Ansible and Terraform use JSON-like configurations, requiring management. JSON is a subset of YAML, so every valid JSON file is also a valid YAML file.

All examples are _✨fully interactive✨_, so I encourage you to play around!   
In fact, I'll be downright heartbroken if you don't, because I put a lot of effort into it. You can edit both the input JSON data, and the jq program as well.

Let's dive in! We'll start off easy, and get slowly deeper into the weeds.

## Basic Operations
### Selecting values

Everything in `jq` is a filter. The dot `.` is used to select the current object or element, and we can put the property name after it to access a key from an object:

<jq-view name="example1"></jq-view>

<noscript>
```bash
echo '{"name": "Alice", "age": 30}' | \ 
jq '.name'
# Output: "Alice"
```
</noscript>

### Filtering Arrays

The `.[]` notation is used to iterate over the elements of an array in a JSON document. It allows you to access each element of an array and perform operations on them. 

The `select()` function is used to filter JSON data based on a specified condition or criteria. It is a powerful tool for extracting specific elements from a JSON document that meet certain conditions. 

Similiar to shell scripting, `jq` works on a pipes-and-filters manner. We use the `|` to send the data from one filter to the next.
<jq-view name="example2"></jq-view>

<noscript>
```bash
echo '[{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}]' | \ 
jq '.[] | select(.age > 28)'
# Output: {"name": "Alice", "age": 30}
```
</noscript>

### Mapping Arrays

We can use the `map` function to run any operation on every element of the array and return a new array containing the outputs of that operation:
<jq-view name="example3"></jq-view>

<noscript>
```bash
echo '[1, 2, 3, 4, 5]' | jq 'map(. * 2)'
# Output: [2,4,6,8,10]
```
</noscript>

### Combining Filters

The pipe operator `|` can be used to chain as many filters or functions as we want:
<jq-view name="example4"></jq-view>

<noscript>
```bash
echo '[{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}]' | jq '.[] | select(.age > 28) | .name'
# Output: "Alice"
```
</noscript>

### Splitting Strings
We can use the `split()` function to a split a string on a particular separator character.    
Note also the usage of `.[0]` to select the first index from the split array.

<jq-view name="example9"></jq-view>

<noscript>
```bash
echo '{"name": "Alice Smith"}' | jq '.name | split(" ") | .[0]'
# Output: "Alice"
```
</noscript>

### Conditional Logic
We can use `if` to create expressions
<jq-view name="example6"></jq-view>

<noscript>
```bash
echo '{"name": "Alice", "age": 30}' | jq 'if .age > 18 then "Adult" else "Child" end'
# Output: "Adult"
```
</noscript>

### Handling Null Values
Null values can often mess up logic in our scripts, so we can filter them all out using `map` and `select`
<jq-view name="example17"></jq-view>

<noscript>
```bash
echo '[1, null, 3, null, 5]' | jq 'map(select(. != null))'
# Output: [1,3,5]
```
</noscript>

### Formatting Output
Sometimes we don't want JSON output. We want it in a particular string format.   
Note the use of the `-r` flag, it makes the output raw. Without it, it would be displayed with quote marks around it.
<jq-view name="example10"></jq-view>

<noscript>
```bash
echo '{"name": "Alice", "age": 30}' | jq -r '"Name: \(.name), Age: \(.age)"'
# Output: Name: Alice, Age: 30
```
</noscript>

### Multiple Outputs

Curly braces create a new object, which we can use for multiple outputs:
<jq-view name="example5"></jq-view>

<noscript>
```bash
echo '{"name": "Alice", "age": 30}' | jq '{name: .name, age: (.age + 5)}'
# Output: {"name": "Alice", "age": 35}
```
</noscript>

## Dealing with Nested Items

![](russian_dolls.jpg)
> [Photo by cottonbro studio](https://www.pexels.com/photo/two-yellow-and-red-ceramic-owl-figurines-4966180/)

JSON is very commonly used to store nested objects, and we often need to traverse or manipulate such structures. `jq` gives us all the tools we need to make it easy:
### Recursive Descent
We can use `..` to recursively descend through a tree of an object.

<jq-view name="example8"></jq-view>

<noscript>
```bash
echo '{"data": {"value": 42, "nested": {"value": 24}}}' | jq '.. | .value?'
# Output: null, 42, 24
```
</noscript>

### Filtering Nested Arrays
<jq-view name="example13"></jq-view>

<noscript>
```bash
echo '{"data": [{"values": [1, 2, 3]}, {"values": [4, 5, 6]}]}' | jq '.data[].values[] | select(. > 3)'
# Output: 4, 5, 6
```
</noscript>

### Flattening Nested JSON Objects
Often, we just want all the key-values, and flattening the object may be the most convenient way to go. 

This is an example where the operation we want to do is fairly straightforward, but the program looks way too scary. 

Let's try to break it down:
* It takes a JSON input and applies the paths function, which returns an array of all possible paths to the values in the JSON object. Each path is itself an array of keys or indices that can be used to access the value. For example, if the input is `{"a": {"b": 1, "c": [2, 3]}}`, then the paths function will return `[[], ["a"], ["a", "b"], ["a", "c"], ["a", "c", 0], ["a", "c", 1]]`.
* The query then assigns this array to a variable `$p` using the `as` keyword, which can be used to store intermediate results for later use.
* The query then applies the select function, which filters the array based on a condition. The condition is `getpath($p) | type != "object"`, which means that only the paths that lead to values that are not objects are selected. The `getpath` function takes a path and returns the value at that path in the JSON input. The `type` function returns the type of the value, such as `“string”`, `“number”`, `“array”`, or `“object”`. For example, `getpath(["a", "b"]) | type` will return `“number”` for the input `{"a": {"b": 1, "c": [2, 3]}}`.
* The query then applies another pipe, which passes the filtered array to the next filter. The next filter is `($p | join(".")) + " = " + (getpath($p) | tostring)`, which constructs a string for each path and its corresponding value. The `join` function takes an array and concatenates its elements with a separator, in this case a dot. The `tostring` function converts any value to a string representation. The `+` operator concatenates strings. For example, `(["a", "b"] | join(".")) + " = " + (getpath(["a", "b"]) | tostring)` will return `“a.b = 1”` for the input `{"a": {"b": 1, "c": [2, 3]}}`.
* The query then outputs the resulting strings, one per line, to the standard output. 

<jq-view name="example21"></jq-view>

<noscript>
```bash
echo '{"person": {"name": {"first": "Alice", "last": "Smith"}, "age": 30}}' | jq 'paths as $p | select(getpath($p) | type != "object") | ($p | join(".")) + " = " + (getpath($p) | tostring)'
# Output: "person.name.first = Alice", "person.name.last = Smith", "person.age = 30"
```
</noscript>

### Recursive Object Manipulation
We can use the `recurse` as well, to traverse a tree.
<jq-view name="example18"></jq-view>

<noscript>
```bash
echo '{"data": {"value": 42, "nested": {"value": 24}}}' | jq 'recurse | .value? | select(. != null) | { value: (. * 5) } | add'
# Output: 210, 120
```
</noscript>

### Complex Object Transformation
<jq-view name="example14"></jq-view>

<noscript>
```bash
echo '{"items": [{"name": "Apple", "price": 1}, {"name": "Banana", "price": 0.5}]}' | jq '.items | map({(.name): (.price * 2)}) | add'
# Output: {"Apple": 2, "Banana": 1}
```
</noscript>


### Walk through object and apply a transformation conditionally
The `walk()` function provides a convenient way to traverse a nested object and apply some transformation to it.
<jq-view name="example24"></jq-view>

<noscript>
```bash
echo '{"data": {"values": [1, 2, 3], "nested": {"values": [4, 5, 6]}}}' | jq 'walk(if type == "number" then . * 2 else . end)'
# Output: {"data":{"values":[2,4,6],"nested":{"values":[8,10,12]}}}
```
</noscript>



## Statistical Operations
![](stats.jpg)
> Photo by [Leeloo Thefirst](https://www.pexels.com/photo/magnifying-glass-on-white-paper-with-statistical-data-5561913/)

`jq` is incredibly handy for doing quick and dirty statistical analysis in the field. Here's most of the common operations related to that

### Sorting Arrays
Sorting an array is a basic operation that is useful for many things in statistics.
<jq-view name="example7"></jq-view>

<noscript>
```bash
echo '[3, 1, 4, 2, 5]' | jq 'sort'
# Output: [1,2,3,4,5]
```
</noscript>

### Extracting Unique Values from an Array
Extracting unique values from an array is another fairly basic operation that we need for many things.
<jq-view name="example12"></jq-view>

<noscript>
```bash
echo '[1, 2, 2, 3, 4, 4, 5]' | jq 'unique'
# Output: [1,2,3,4,5]
```
</noscript>

### Calculating Averages
Calculating the mean or average of a dataset is a common statistical operation we may often need to do
<jq-view name="example20"></jq-view>

<noscript>
```bash
echo '[{"score": 90}, {"score": 85}, {"score": 95}]' | jq 'map(.score) | add / length'
# Output: 90
```
</noscript>

### Grouping and Aggregating
We can group an array of objects by a particular key and get an aggregated value of the other keys fairly easily:
<jq-view name="example11"></jq-view>

<noscript>
```bash
echo '[{"category": "A", "value": 10}, {"category": "B", "value": 20}, {"category": "A", "value": 5}]' | jq 'group_by(.category) | map({category: .[0].category, sum: map(.value) | add})'
# Output: [{"category": "A", "sum": 15}, {"category": "B", "sum": 20}]
```
</noscript>

### Filtering after Aggregation

<jq-view name="example25"></jq-view>

<noscript>
```bash
echo '[{"category": "A", "value": 10}, {"category": "B", "value": 20}, {"category": "A", "value": 5}]' | jq 'group_by(.category) | map({category: .[0].category, sum: (map(.value) | add)}) | .[] | select(.sum > 17)'
# Output: {"category":"B","sum":20}
```
</noscript>


### Custom Aggregation with reduce
We can also use `reduce` to perform a single-output aggregation from an array
<jq-view name="example23"></jq-view>

<noscript>
```bash
echo '[{"value": 10}, {"value": 20}, {"value": 30}]' | jq 'reduce .[] as $item (0; . + $item.value)'
# Output: 60
```
</noscript>

### Calculating Histogram Bins
We may want to calculate a histogram from an array of data.
<jq-view name="example22"></jq-view>

<noscript>
```bash
echo '[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]' | jq 'group_by(. / 5 | floor * 5) | map({ bin: .[0], count: length })'
# Output: 
[
  {
    "bin": 1,
    "count": 4
  },
  {
    "bin": 5,
    "count": 5
  },
  {
    "bin": 10,
    "count": 5
  },
  {
    "bin": 15,
    "count": 1
  }
]
```
</noscript>

## Other Common Operations
These are some other common operations I frequently find myself doing every day, but I couldn't think of a better way to categorize them.
### Extracting Values Based on Multiple Conditions
We can combine multiple conditions in a `select` call. The `test()` function is used to check if the passed string contains one of the substrings or not.
<jq-view name="example15"></jq-view>

<noscript>
```bash
echo '[{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}, {"name": "John", "age": 35}]' | jq 'map(select(.age > 28 and (.name | test("a", "i"))))'
# Output: [{"name": "Alice", "age": 30}]
```
</noscript>

### Formatting Unix Timestamps
Various tools emit Unix Timestamps, and we can use the handy `strftime` function to format it so it's easier to understand at a glace.
<jq-view name="example16"></jq-view>

<noscript>
```bash
echo '{"timestamp": 1630768200}' | jq '.timestamp | strftime("%Y-%m-%d %H:%M:%S")'
# Output: "2021-09-04 15:10:00"
```
</noscript>


### Enumerating by Top Level Key and Value
<jq-view name="example19"></jq-view>

<noscript>
```bash
echo '{"a": 1, "b": 2, "c": 3}' | jq 'to_entries[] | "\(.key) is \(.value)"'
# Output: "a is 1", "b is 2", "c is 3"
```
</noscript>

## Closing Thoughts

Whew! That's been a long article 😅 If you're still here, then I appreciate you staying till the very end. 

I hope you've learned something new, and that you'll be able to quickly identify use cases for `jq` in your current workflow and apply your learnings there. 


### How Does This Article Work?

- I have used web components to create a custom component `<jq-view>`. 
- There is some Javascript in this page which renders all the `<jq-view>`s when the page is loaded.
- The WebAssembly build of `jq`, as well as all the code for calling out to it is provided by BioWasm.
- I have used AlpineJs to make the examples interactive. When the button is clicked, it sends an event to a listener, which makes it run `jq` and then update the output.
- Since I am not good at front-end, this was a substantial learning experience for me.

### Get In Touch
If you have any suggestions on how this may be improved, errors that I might have made, or you just want to discuss any other topic, please feel free to [email me](mailto:ishan.dassharma1@gmail.com). I always love to hear from you.

### Extra Resources
- [JQ Manual](https://jqlang.github.io/jq/manual/): The official JQ manual. Covers everything, but a bit difficult to digest.
- [Learn JQ the Hard Way](https://zwischenzugs.com/2023/06/27/learn-jq-the-hard-way-part-i-json/): A good series of blog posts covering introductory theoretical aspects of jq.
- [JSON Wrangling with jq](https://sandbox.bio/tutorials?id=jq-intro): Another interactive series on jq that dives into more detail on the theoretical aspects.

## Changelog
- 2023-11-29
  - Add a "Reset" button
  - Fixed some examples that were incorrect in the non javascript version of this page
  - Added some more resources
  - Added explanation for [Flattening Nested JSON Objects](#flattening-nested-json-objects)