---
title: What I Learned Using Neon Postgres for a Week of Live Traffic
slug: dbms-neon
date: 2025-12-09
tags: ["postgres", "neon", "serverless", "database", "devlog"]
---

I recently built a [SQL practice platform](https://dbms.ishan.page) for my DBMS course at [IITM BS Degree](/blog/jeeification). About 50-100 students were hitting it simultaneously during peak exam prep. I chose Neon as the backend database, mostly because I was curious about their serverless Postgres offering. Here's what I learned after a week of actual traffic.

Let me be clear about what this actually tested: student queries don't hit Neon at all. Those run in WASM on the client side (which I'll write about in Part 2 because that setup was *wild*). Neon's job was simple: serve metadata like problem sets, some aggregate stats, and admin operations. This is basically the lightest possible database workload - maybe 2-3 queries per page load, all reads except when I manually added new problems through TablePlus.

Strictly speaking, this website didn't even need a database since it could have been entirely pre-rendered. But this project is experimental for me. I used Lovable to scaffold the UI, tried TRPC for the first time, used Bun instead of my usual Python stack, and generally did things quite differently from my usual approach. I'll detail those decisions in future posts. For now, Neon's role was serving the application's metadata and admin operations.

So this isn't "I ran a high-traffic production database on Neon." This is "I used Neon as a metadata store for a small educational app." Keep that context in mind.

## What I Was Actually Running

The traffic pattern looked like this:
- 50-100 concurrent users during exam prep peaks
- Each user session: load homepage (one query for aggregate stats - yes, I could have cached this but I was lazy), fetch problem set list (one query), load problem set metadata (one query), load all problems in that set (one query)
- Peak query rate: probably 10-20 queries per second, ballpark
- Total data volume: laughably small, maybe 50MB including all the problem descriptions
- No complex joins, no aggregations, just basic CRUD on small tables

The application server ran on Fly.io (legacy free tier, Singapore region because they don't let me deploy in India). Neon database also in Singapore since they don't have an India region. This meant server-to-database latency was negligible, which matters more than client-to-server latency for this architecture.

## The Good Parts
Cold starts are legitimately fast. I measured a few wake-ups from scale-to-zero: consistently under 1 second from first query to response. For my use case where users might access the site after a few hours of inactivity, this was completely acceptable. Nobody noticed.

Database provisioning is instant. Supabase takes 2-3 minutes to spin up a new project. Neon takes 5-10 seconds. 

Branching is as advertised. I used it to create a dev copy of production data for testing new problem sets. The branch showed up in under 10 seconds, and I could connect to it immediately. I didn't use any fancy "branch per feature" workflows - just treated it as a really fast database clone. That alone was useful.

Connection quality from TablePlus was surprisingly good. I'm in Kolkata, database is in Singapore, and there was no perceptible lag when browsing tables or running manual queries. For comparison, when I've used Supabase instances hosted in Mumbai, there's a noticeable delay on every interaction in TablePlus. With Neon in Singapore, it felt instant. I don't know if this is connection pooling magic or better routing or what, but it made admin work much smoother.

The serverless driver handled reconnections gracefully. When the compute scaled down and back up, my application code didn't notice. No error handling needed, no retry logic, just worked. Compare this to using a direct psql connection: when the compute scales down, you get an "SSL connection has been closed unexpectedly" error, then it auto-reconnects after a few seconds. Functional but ugly.

## The Tradeoffs

No India region. For my users (all in India), this added latency. Hard to measure exactly since the app is lightweight, but it's not ideal. Singapore was acceptable but not optimal.

The serverless driver is noticeably slower than direct Postgres. I didn't benchmark this rigorously, but subjectively, queries that should return in 10-20ms via direct connection felt like 50-100ms via the serverless driver. This is the cost of the pooling/scaling architecture. For my workload, it didn't matter. For something latency-sensitive, you'd feel it.

Query metrics reset when compute scales to zero. This is both unexpected, and annoying. You can't track query patterns over time because the dashboard wipes clean after each scale-down. If you're trying to optimize slow queries or understand usage patterns, you're out of luck unless you set up external monitoring.

Connection pooling limit is per-project. The serverless driver supports 10,000 pooled connections, which sounds like a lot until you realize it's shared across all clients accessing that project. My usage never exceeded a single connection, so I can't speak to what happens near the limit, but it's worth knowing the boundary exists.

## Thoughts on Pricing

Here's where Neon's model gets weird.

The free tier gives you 80 projects, each with 100 compute-unit hours per month. That sounds generous: 80 × 100 = 8,000 CU-hours total.

But there's a catch: **you cannot pool these hours across projects.** Each project gets exactly 100 CU-hours, period. You can't run one project for 800 hours and leave the others idle.

The minimum compute size is 0.25 CU. A month has ~750 hours. Do the math: 100 CU-hours ÷ 0.25 CU = 400 hours maximum. **You cannot run even a single free-tier project 24/7.** You'd hit the cap halfway through the month.

This would be fine if serverless actually scaled to zero in practice. But here's what I learned the hard way:

### Serverless Databases Require Frontend Discipline

Even one user being online keeps the compute running.

I forgot to disable React Query's automatic background refetching. The default behavior polls the API every few minutes when the window is focused, and refetches on tab focus. This meant anyone leaving the homepage open - even if they weren't actively using it - would keep hitting the backend, which kept the database compute alive.

A single browser tab, sitting idle on someone's screen, was enough to prevent scale-to-zero from ever triggering.

This is the fundamental thing about serverless databases that nobody emphasizes: **your database doesn't scale to zero because it's idle. It scales to zero when clients stop making requests.**

With a traditional VPS running Postgres, your frontend behavior doesn't affect hosting costs. A $5 VPS costs $5 whether your React app polls every second or stays silent for hours. Serverless inverts this. Every automatic refetch, every "check for updates" feature, every WebSocket keepalive becomes a line item on your infrastructure costs.

If you're building on serverless infrastructure, audit your frontend's network behavior:
- Disable automatic refetching unless you genuinely need real-time data
- Use longer polling intervals (or better: don't poll at all, use manual refresh)
- Think about what happens when users leave tabs open for hours
- Consider whether that "sync on window focus" behavior is worth keeping the database awake

The backend being "serverless" is irrelevant if your frontend keeps it awake 24/7.

### My Actual Usage

Over the 5-day exam prep period, I used about 25 CU-hours. Compute was active almost 24 hours a day for that period. I stayed comfortably within the 100 CU-hour monthly limit.

But here's the thing: I spent way too much mental energy worrying about it. Watching the number climb in the Neon dashboard, not knowing when students would be active, wondering if someone had a tab open and was quietly burning through my allocation - the "serverless" cost model added stress that a fixed $5/month VPS wouldn't have.

For anyone considering Neon for similar usage: 50-100 concurrent users doing light reads will use roughly 5 CU-hours per day if the compute stays mostly active. Scale accordingly.

### The Paid Tier Math

Running one database continuously at minimum compute (0.25 CU) would cost about $20/month:

0.25 CU × 750 hours × $0.106/CU-hour ≈ $20

That's steep for hobby projects. Neon's marketing targets indie developers and side projects, but the economics don't support always-on applications at that scale. A $5 DigitalOcean droplet running Postgres would be way cheaper, though you'd handle your own backups, scaling, and operations.

## Would I Use It Again?

For this specific use case - a platform serving metadata during a concentrated exam period with real idle gaps - Neon worked well. The cold start performance didn't hurt user experience, database provisioning was smooth, and the connection quality made development pleasant.

For a project that needs to run continuously, I'd probably look elsewhere. The serverless architecture makes sense for workloads with genuine idle periods, but the reality is that even sporadic traffic prevents scale-to-zero from being useful. The per-project compute caps and pricing make it less attractive for always-on applications than traditional hosting.

**Where Neon actually makes sense:**
- Scheduled jobs that run a few times per day (data processing, reports, maintenance scripts)
- Dev/staging environments that only spin up during work hours
- Bursty workloads with predictable idle periods (weekly reports, monthly processing)
- Projects where you value operational simplicity over cost optimization

**Where I'd think twice:**
- Always-on production apps with steady traffic
- Anything latency-sensitive (use direct Postgres, not the serverless driver)
- High query volume applications where you need persistent metrics
- Projects where you can't enforce strict frontend discipline around polling/refetching

So yeah, I'd probably use Neon again, but I'd probably reach for SQLite first. The technology works as advertised. The pricing model just doesn't align well with how real applications behave in the wild.

---

*The platform is live at [dbms.ishan.page](https://dbms.ishan.page) if you want to check it out. Part 2 will cover the WASM SQL execution setup, why I went that route, and the cursed things I had to do to get Python in WASM to talk to a PGLite database running in the browser.*
