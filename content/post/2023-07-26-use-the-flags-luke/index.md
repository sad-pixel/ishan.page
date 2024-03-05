---
title: Dear past me, use the flags
date: 2023-07-26
tags: [programming]
slug: 2023-07-26-use-the-flags-luke
---

Dear past me,

I know you've just launched your first desktop application. It's a nightmare isn't it? Well you're in for a bigger one.

Your boss calls you, and they need a new feature immediately. You bang it out and send out the update.

Oh yeah, that's right. You didn't include an update mechanism. Please use one, you'll save yourself a lot of pain.

You send out the update to users, but soon you find out everyone hasn't updated yet. The boss **insists** that people on an older app version shouldn't be able to use it.

But you didn't include a forced version based lockout mechanism either. Well, you'll remember that for next time!

Desperate times call for desperate measures, and you decide to break the server so it returns bad data to old app versions. Never mind that this permanently corrupts the local database and will require future tech support to help them clear their cache. But that's future you's problem.

The boss is happy, the app is chugging along. This cycle repeats a couple more times in various ways.

Save yourself the pain next time. Implement a feature flag / version system. Later, it'll even help you roll out features to users incrementally.

Use the flags, Luke.

Sincerely,
Present me

{{% read-next %}}
