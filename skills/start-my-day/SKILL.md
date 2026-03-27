---
name: start-my-day
description: >
  Morning briefing skill. Triggers when the user says "start my day", "start-my-day",
  "morning briefing", "what do I have today", "catch me up", or any similar phrase
  signaling they want a summary of what's waiting for them. Fetches unread emails
  since the last run across all connected inboxes, calendar events, and delivers
  a concise in-chat briefing with inline links. Always use this skill for morning
  catchup requests, even if the user just says "what's going on" or "what did I miss".
  Designed to grow: new integrations (Slack, Jira, Linear, GitHub) slot in as modules
  without changing the core structure.
---

# Start My Day

Deliver the user's morning briefing. Be a concise, factual aggregator — not an advisor.
Surface what's there. Do not recommend actions or editorialize. The user decides what to do.

---

## Step 0a: Read config file

**Config file path** (in priority order):
1. The value of the `START_MY_DAY_CONFIG_FILE` env var, if set
2. `~/.claude/.start-my-day-config.json` (default — works on Windows, Mac, and Linux)

**Expected shape:**
```json
{
  "name": "Peter",
  "timezone": "America/New_York",
  "sources": ["gmail", "outlook", "google_calendar", "outlook_calendar"]
}
```

**Valid source IDs:** `gmail`, `outlook`, `google_calendar`, `outlook_calendar`

**If the file exists**, load `name`, `timezone`, and `sources`. These govern the rest of the skill:
- `name` → used in the briefing greeting
- `timezone` → used for all "today / tomorrow / next 3 days" window calculations and for displaying times
- `sources` → the authoritative list of integrations to attempt on this machine; anything not listed is silently skipped (no probe, no note)

**If the file is missing**, ask the user:
1. "What should I call you in the morning briefing?"
2. "What's your timezone? (e.g. America/New_York, America/Chicago, America/Los_Angeles, Europe/London)"
3. "Which sources are connected on this machine?" — offer: Gmail, Outlook, Google Calendar, Outlook Calendar

Write the answers to the config file, then continue. Confirm: *"Config saved to {path}. You can edit it anytime to change sources or timezone."*

---

## Step 0b: Read state file

**State file path** (in priority order):
1. The value of the `START_MY_DAY_STATE_FILE` env var, if set
2. `~/.claude/.start-my-day-state.json` (default)

**Expected shape:**
```json
{"last_run": "2026-03-27T13:41:19Z"}
```

- File exists → use `last_run` as the cutoff timestamp (always stored in UTC).
- File missing or unreadable → use **24 hours ago** as the cutoff; note "First run — showing last 24h" in briefing.

Store the current UTC timestamp in memory now — write it back in Step 6.

---

## Step 1: Gmail

**Source ID**: `gmail`

**Skip condition**: If `gmail` is not in `config.sources`, skip this step entirely. No probe, no note in briefing.

**Availability check**: If `gmail` is in `config.sources`, attempt `gmail_get_profile`. If the tool is unavailable or returns an error, skip this step and add `📭 Gmail — not connected` to the briefing's skipped-sources line. Do not abort the skill.

**MCP tools**: `gmail_get_profile`, `gmail_search_messages`, `gmail_read_message`

1. Call `gmail_get_profile` → capture the `emailAddress` field. This is the account label shown per item.

2. Search for messages:
   - Query: `after:{YYYY/MM/DD} in:inbox -category:promotions -category:social`
   - Use the date portion of the cutoff timestamp, converted to the user's timezone.
   - `maxResults`: 30

3. For each message, read enough to extract:
   - Sender (first name + domain, e.g. "Sarah · acme.com")
   - Subject
   - One neutral sentence describing what the message is about — no opinion, no recommendation
   - Gmail link: `https://mail.google.com/mail/u/0/#inbox/{message_id}`

4. Classify each message:
   - **Action** — requires a reply, approval, or decision
   - **FYI** — informational, no response expected
   - **Skip** — automated notifications, receipts, newsletters → omit entirely

5. Show max 8 Action, max 5 FYI. If more exist: "…and N more."

---

## Step 2: Outlook

**Source ID**: `outlook`

**Skip condition**: If `outlook` is not in `config.sources`, skip this step entirely. No probe, no note in briefing.

**Availability check**: If `outlook` is in `config.sources`, attempt `list_emails` with `limit: 1`. If the tool is unavailable or returns an error, skip this step and add `📭 Outlook — not connected` to the briefing's skipped-sources line. Do not abort the skill.

**MCP tools**: `mcp__outlook__list_emails`, `mcp__outlook__read_email`

> This MCP does not support date-range filtering. Fetch the most recent 50 emails and filter client-side against the cutoff timestamp.

1. Call `list_emails` with `limit: 50`.

2. Filter: keep only messages where `receivedDateTime` ≥ cutoff (compare in UTC).

3. To identify the account: inspect the `toRecipients` field on any message — use the email address found there as the account label. If unavailable, label it "Outlook".

4. For each message within the cutoff window, read enough to extract:
   - Sender (first name + domain)
   - Subject
   - One neutral sentence describing what the message is about
   - Outlook link: use `webLink` from the message if present; otherwise omit link

5. Same classification rules as Gmail: **Action** / **FYI** / **Skip**.

6. Merge with Gmail results into unified Action and FYI lists. Prefix each item with its account label.

---

## Step 3: Google Calendar

**Source ID**: `google_calendar`

**Skip condition**: If `google_calendar` is not in `config.sources`, skip this step entirely. No probe, no note in briefing.

**Availability check**: If `google_calendar` is in `config.sources`, attempt `gcal_list_events` with a narrow time window. If the tool is unavailable or returns an error, skip this step and add `📭 Google Calendar — not connected` to the briefing's skipped-sources line. Do not abort the skill.

**MCP tools**: `gcal_list_events`

1. Identify the calendar account: the `summary` field returned by `gcal_list_events` contains the calendar's email address. Show it in the section header.

2. Fetch two windows, expressed in `config.timezone`:
   - **Today**: `timeMin` = start of today, `timeMax` = end of today
   - **Next 3 days**: `timeMin` = start of tomorrow, `timeMax` = end of day+3
   - Use `condenseEventDetails: false` to get attendee list

3. For each event show:
   - Time in `config.timezone` (12h format, e.g. "2:30pm") or "All day"
   - Title
   - Attendees: first names only; if > 3 people use "you + N others"
   - Zoom/Meet link if present in location or description (extract cleanly, no raw URLs)
   - Calendar link: use `htmlLink` from the event

4. Skip working-location markers (eventType: "workingLocation").

---

## Step 4: Outlook Calendar

**Source ID**: `outlook_calendar`

**Skip condition**: If `outlook_calendar` is not in `config.sources`, skip this step entirely. No probe, no note in briefing.

**Availability check**: If `outlook_calendar` is in `config.sources`, attempt `list_calendar_events` with a narrow date range. If the tool is unavailable or returns an error, skip this step and add `📭 Outlook Calendar — not connected` to the briefing's skipped-sources line. Do not abort the skill.

**MCP tools**: `mcp__outlook__list_calendar_events`

1. Fetch events in `config.timezone`: `start_date` = now, `end_date` = 3 days from now.

2. Account label: infer from organizer email in events, or label "Outlook Calendar".

3. Same display format as Step 3 — times in `config.timezone`.

4. **Dedup**: if an event appears in both Google Calendar and Outlook Calendar (same title and approximate time), show it once and note "(in both calendars)".

---

## Step 5: Write the briefing

Output directly in chat. No files. No preamble. Start with the header line.

```
**☀️ Good morning, {config.name}** · {Day, Date in config.timezone} · Last run: {relative time, e.g. "yesterday 5pm" or "8h ago"}
{If any configured sources failed their availability check: 📭 Not connected: Gmail · Outlook Calendar  ← omit line entirely if all active sources succeeded}

---

### 📅 Today  ·  {calendar account, or omit subtitle if no calendar source available}
{events or "Nothing scheduled." — omit section entirely if no calendar sources are in config.sources}

### 🔮 Next 3 Days
{upcoming events — omit section entirely if empty or no calendar sources in config}

---

### 📬 Action Required  ({N} items)
{account label} · **{Subject}** · {Sender} · {one neutral sentence} · [Open →]({link})
{If no email sources in config.sources: omit this section entirely}

### 📋 FYI  ({N} items)
{account label} · **{Subject}** · {Sender} · {one neutral sentence} · [Open →]({link})
```

**Tone rules:**
- Descriptions are factual and neutral. No "you should", no "consider", no "it's worth noting".
- One sentence per item — no more.
- If a section has sources configured but nothing to show, write the section header and "Nothing new."
- Do not add a closing summary paragraph.

---

## Step 6: Update state file

Write the current UTC timestamp to the state file path from Step 0b:

```json
{"last_run": "2026-03-27T13:41:19Z"}
```

Use the actual current time.

**If the write succeeds**: Confirm in one line: *"State updated — next run will show items since {time in config.timezone}."*

**If the write fails** (permission error, read-only filesystem, remote environment): Note in one line: *"State not persisted this run — next run will default to last 24h."* Do not abort or re-attempt.

---

## Extensibility — adding modules

Each new integration is a self-contained numbered step (insert between Steps 4 and 5).
Register it by adding its source ID to `config.sources` in `~/.claude/.start-my-day-config.json`.

The pattern for every new step:

```
## Step N: {Source name}
**Source ID**: {id to add to config.sources}
**Skip condition**: If `{id}` is not in `config.sources`, skip silently.
**Availability check**: Attempt {first tool call}. If unavailable or error, skip and add `📭 {Source name} — not connected` to the briefing's skipped-sources line.
**MCP tools**: {list the exact tool names}
**Account identification**: {how to surface the account label}
**Cutoff handling**: {does this MCP support date filtering, or must you filter client-side?}
**Timezone**: {does this source need timezone-aware window calculations?}
**Classification**: Action / FYI / Skip — same rules as Gmail unless noted
**Output**: merge into the unified Action/FYI lists with account prefix
```

**Modules to add when MCPs are connected:**
- `slack` — Slack DMs & @mentions → Slack MCP, same cutoff window
- `jira` — assigned tickets with status changes → Atlassian Rovo MCP
- `github` — PRs awaiting your review → GitHub MCP
- `google_drive` — files shared with you since cutoff → Google Drive MCP
