---
title: How to Force Google Calendar Account Picker When Adding ICS Subscriptions
date: 2025-11-26
tags:
  - google
  - calendar
  - web
slug: google-calendar-account-picker
categories:
  - Snippets
---

If you share a link that lets people subscribe to an `.ics` feed in Google Calendar, you’ve probably seen this pattern:

```
https://calendar.google.com/calendar/render?cid=webcal://your-feed.ics
```

It works, but there’s a catch:
If the user is logged into multiple Google accounts, Google just picks one. No warning. No choice. Easy way to end up adding the calendar to the wrong account.

Here’s the fix.

## Use AccountChooser to Force the Picker

Google has a built-in account picker page. If you send users through it first, they *will* be asked which account to use before they land in Calendar.

Wrap your calendar URL like this:

```
https://accounts.google.com/AccountChooser?continue=https://calendar.google.com/calendar/render?cid=webcal://your-feed.ics
```

That’s it. Clicking this link always shows the account picker, then kicks the user over to the Calendar subscribe screen.

## Why This Works

Calendar doesn’t expose a “show picker” flag. AccountChooser does. It pauses the flow, lets the user choose an account, and then continues to whatever URL you gave it.

## Make Your Own AccountChooser Link

Here's a quick tool to generate your own AccountChooser-enabled calendar subscription links:

<script src="https://unpkg.com/alpinejs" defer></script>

<script>
document.addEventListener('alpine:init', () => {
  Alpine.data('accountChooserTool', () => ({
    icsUrl: 'https://example.com/calendar.ics',
    getEncodedLink() {
      // Remove scheme (http://, https://, webcal://, etc.) if present
      const effectiveIcsUrl = this.icsUrl.replace(/^(https?:|webcal:)\/\//, '');
      const calendarUrl = `https://calendar.google.com/calendar/render?cid=webcal://${effectiveIcsUrl}`;
      const encodedCalendarUrl = encodeURIComponent(calendarUrl);
      return `https://accounts.google.com/AccountChooser?continue=${encodedCalendarUrl}`;
    }
  }))
})
</script>

<style>
input, textarea {
  font-family: monospace !important;
  display: block;
  background-color: var(--pre-background-color);
  color: var(--pre-text-color);
  width: 100%;
}

button {
  background: var(--accent-color);
  box-shadow: var(--shadow-l2);
  border-radius: var(--tag-border-radius);
  padding: 8px 20px;
  color: var(--accent-color-text);
  font-size: 1.4rem;
  transition: all .3s ease;
  border: 0;
  cursor: pointer;
}

button:hover {
  background: var(--accent-color-darker);
}

.flex-col {
  display: flex;
  flex-direction: column;
  margin-bottom: 20px;
}
</style>

<div x-data="accountChooserTool">
<div class="flex-col">
<label for="icsUrl">Your ICS URL:</label>
<input type="text" id="icsUrl" x-model="icsUrl">
</div>
<div class="flex-col">
<label>Your AccountChooser Link:</label>
<textarea x-text="getEncodedLink()" style="height: 80px;" readonly></textarea>
</div>
<button @click="navigator.clipboard.writeText(getEncodedLink())">Copy to Clipboard</button>
</div>

## When to Use It

Anytime you expect users to have more than one Google account (so… basically always), and you don’t want support emails about “Why did this add to my work calendar?”
