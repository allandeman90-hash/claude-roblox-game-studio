---
title: "Experience Notifications — Roblox Platform Feature"
type: raw-source
source_url: https://devforum.roblox.com/t/introducing-experience-notifications/2826474
source_type: devforum
captured_at: 2026-04-15
captured_by: research-agent-phase3
category: social-features
author: Roblox Staff
post_date: 2024-02-01
tags: [notifications, engagement, re-engagement, social, ExperienceNotificationService]
---

# Experience Notifications

## Overview

Experience Notifications enable developers to deliver targeted, personalized messages to users aged 13+. These notifications inform players about significant in-game moments like pet hatches, base attacks, or weekly challenge reminders.

## Key Features

### Personalization and Triggers
Developers define customizable notification strings and set trigger conditions. The system automatically personalizes content based on developer-established parameters.

### User Opt-In System
Users enable notifications via "Notifications" button (formerly "Follow") on Experience Details Pages. Existing followers remain opted-in. 13+ users become eligible. Management via Settings > Notifications Preferences page.

## Delivery and Rate Limits

- Maximum: 1 notification per day per user per experience (relaxed from 1 per 3 days, June 2024)
- Delivery is not guaranteed (protects against flooding)
- Prevents notification saturation across all experiences

## Implementation

### Setup Process
1. Define customizable notification strings and personalizable parameters in Creator Dashboard
2. Make API calls to trigger notifications when criteria are met
3. Estimated implementation time: 1 hour to 1 day including testing

### API Options
- OpenCloud API (server-side HTTP calls)
- Engine/Lua API (ExperienceNotificationService, in-experience)

Both released for testing February 2024, full launch March 2024.

## Analytics

Notifications Analytics Dashboard in Creator Hub tracks:
- Opted-in user counts (immediately available)
- Overall impressions and clicks
- Individual campaign performance
- Engagement metrics
- Minimum 100 user impressions required to view data

## User Mentions (May 2024)

Developers can mention users within notifications. Recipient and mentioned users must be friends for delivery eligibility.

## In-Experience Permission Prompts

A Lua API allows prompting users to enable notifications directly within the experience (released September 2024).

## Best Practices

1. Focus on high-value, actionable moments relevant to users
2. Leverage opt-in nature for timely, relevant messaging
3. Monitor analytics to refine strategies
4. Use personalizable parameters for user-specific content over generic broadcasts

## Current Limitations

- Only users 13+ can receive notifications
- No documented delivery status return values for retry logic
- Friends requirement for user mentions
- Rate limits enforced per experience per user
