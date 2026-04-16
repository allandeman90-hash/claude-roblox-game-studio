---
title: Rate limits and throttling
type: raw-source
source_url: https://create.roblox.com/docs/cloud/guides/data-stores/throttling
github_source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud/guides/data-stores/throttling.md
source_type: official-roblox-docs
captured_at: 2026-04-16
captured_by: research-agent-4
category: best-practice
subcategory: open-cloud
tags: [open-cloud, data-stores, throttling, rate-limits]
---

# Rate limits and throttling

The [Data Stores API](/cloud/reference/DataStore) enforces two types of throttling: **requests per minute** and **throughput**. Each experience allows a certain number of requests per minute and a certain amount of data per minute. These limits are enforced for the universe regardless of the number of API keys used.

Unlike the Engine API, these limits do **not** scale based on user count. Exceeding either one causes the endpoint to return `429 Too Many Requests`.

<Alert severity="info">
Data store rate limits for the [Open Cloud v1](/reference/cloud/datastores-api/v1) and [Open Cloud v2](/cloud/reference/DataStore) APIs are identical.
</Alert>

## Standard data stores throttling limits

<table>
  <thead>
    <tr>
      <th>Request type</th>
      <th>Method</th>
      <th>Throttle limits</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Write</td>
      <td>
        <ul>
          <li>Create Data Store Entry</li>
          <li>Delete Data Store Entry</li>
          <li>Update Data Store Entry</li>
          <li>Increment Data Store Entry</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>10 MB/minute/universe write throughput</li>
          <li>300 requests/minute/universe</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Read</td>
      <td>
        <ul>
          <li>List Data Stores</li>
          <li>List Data Store Entries</li>
          <li>Get Data Store Entry</li>
          <li>List Data Store Entry Revisions</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>20 MB/minute/universe read throughput</li>
          <li>300 requests/minute/universe</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Delete</td>
      <td>
        <ul>
          <li>Delete Data Store</li>
          <li>Undelete Data Store</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>300 requests/minute/universe</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

## Ordered data stores throttling limits

<table>
  <thead>
    <tr>
      <th>Request type</th>
      <th>Method</th>
      <th>Throttle limits</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Write</td>
      <td>
        <ul>
          <li>Create Ordered Data Store Entry</li>
          <li>Delete Ordered Data Store Entry</li>
          <li>Update Ordered Data Store Entry</li>
          <li>Increment Ordered Data Store Entry</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>300 requests/minute/universe</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Read</td>
      <td>
        <ul>
          <li>List Ordered Data Store Entries</li>
          <li>Get Ordered Data Store Entry</li>
        </ul>
      </td>
      <td>
        <ul>
          <li>300 requests/minute/universe</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

## Source

- Original documentation: https://create.roblox.com/docs/cloud/guides/data-stores/throttling
- GitHub source: https://github.com/Roblox/creator-docs/blob/main/content/en-us/cloud/guides/data-stores/throttling.md
- Captured: 2026-04-16
