---
title: sqlc Culture Shock
date: 2023-11-18
tags:
- go
- sqlc
- programming
draft: true
---

As a web developer who has been using Django and Laravel for years, I was used to the convenience and security of using ORMs to interact with databases. I never had to write raw SQL queries, and I trusted that the ORMs would handle the escaping and sanitizing of user input to prevent SQL injection attacks. But in 2020, I decided to learn Go, a language that is praised for its simplicity and performance, I was in for a huge culture shock-- especially with regards to how databases are handled.

The first thing that we have to discuss here is that there is no Go equivalent framework to Django or Laravel. There are some projects like Beego, but they don't have substantial community reach or support. As a result, the Go community uses to take a much more minimal approach instead, and use the standard library for most things, and pulling in external libraries for routing, caching, etc as they need. It is very much configuration over convention. 

Whether this is better or worse is debatable-- The point of this article is not to stir up any controversy. The reader is expected to do their own research and make a choice. 

My personal opinion is to use the right tool for the right job, and while Go is a great tool for certain jobs, building business crud applications in a fast-paced agency setting is not one of those jobs, especially in a IT market like India's, where it is much harder to find Go developers. The correct business choice for someone who wants to develop those kinds of applications here are things like Django, Laravel, and maybe Spring Boot. 

Unlike in Go does not have a standard ORM library, and most Go developers prefer to use plain SQL queries instead. They argue that SQL is a powerful and expressive language that should not be abstracted away by ORMs, and that writing raw SQL gives them more control and flexibility over their database operations. They also claim that SQL injection is not a problem in Go, because the standard database/sql package provides a way to execute parameterized queries that are safe from malicious input.

One of the tools that caught my eye was sqlc, a code generator that turns SQL queries into type-safe Go code. It sounded like a neat way to combine the best of both worlds: writing SQL queries without losing the benefits of static typing and code completion. I decided to give it a try and see how it compared to using ORMs.

The first thing I noticed was that sqlc required me to write a lot of boilerplate code. I had to create a schema.sql file that defined the tables and columns of my database, and then run sqlc generate to create Go structs and methods for each table. I also had to write a queries.sql file that contained all the SQL queries I wanted to use, and then run sqlc generate again to create Go functions for each query. This felt tedious and repetitive, especially compared to the ease of using ORMs.

The second thing I noticed was that sqlc was very strict about the syntax and structure of my SQL queries. It only supported a subset of SQL features, and it enforced some rules that I was not used to. For example, it required me to use aliases for table names and column names, and it did not allow me to use subqueries or joins in some cases. It also did not support some common SQL functions, such as COALESCE or CONCAT. I had to rewrite some of my queries to make them compatible with sqlc, or resort to using raw SQL with database/sql.

The third thing I noticed was that sqlc did provide some advantages over using raw SQL. It generated Go code that was easy to read and use, and it checked for errors at compile time rather than at runtime. It also integrated well with my editor and IDE, providing code completion and documentation for the generated structs and functions. It made working with SQL in Go more pleasant and productive.

Overall, my experience with sqlc was mixed. It was not as easy or flexible as using ORMs, but it was not as hard or unsafe as using raw SQL. It was a different way of thinking about database access in Go, one that required me to embrace SQL rather than avoid it. It was a culture shock, but also a learning opportunity.
