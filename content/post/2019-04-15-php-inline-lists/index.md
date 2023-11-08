---
title: 3 ways to render inline lists in PHP
tags: [php, web]
date: 2019-04-15
slug: 2019-04-15-php-inline-lists
categories:
- Snippets
---

Given a list of items and a separator, render it in a single line, with separators between. 
```php
$items = [ 
    "apples",
    "oranges",
    "bananas"
];

$separator = " / ";
```

## Method 1: Basic `foreach`
This approach is the one that comes to mind first, but it is incorrect because it will emit an
additional separator after the last element.

```php
foreach ($items as $value) { 
    echo $value . $separator;
}
```

Output:
```
apples / oranges / bananas /
```

## Method 2: Using `implode()`
Cleaner and shorter, this usage is appropriate for most applications:
```php
echo implode($separator, $items);
```

Output:
```
apples / oranges / bananas
```

While the `implode()` method is great for most purposes, it does break down when there is heavy templating
involved. 

## Method 3: Using `foreach` and 
When heavier templating functionality is required, it's best to use 

```php
foreach ($items as $key => $value) {
    echo $value;

    if ($key !== array_key_last($items)) {
        echo $separator;
    }
}
```

The third method has the same output as the second one, but gives you more flexibility in how you might organize
your templates.
