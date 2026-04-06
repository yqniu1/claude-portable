# Start My Day — Morning Briefing Procedure

Deliver the user's morning briefing. Be a concise, factual aggregator — not an advisor.
Surface what's there. Do not recommend actions or editorialize. The user decides what to do.

---

## Step 0: Read Config & Determine Cutoff

**Config** is in the project instructions (the `My Config` block). Read:
- `Name` → used in greeting
- `Timezone` → used for all time displays and window calculations
- `Sources` → which integrations to attempt (anything not listed is silently skipped)
- `Slack workspace` → for Slack link construction
- `Jira site` → for Jira link construction

**Cutoff**: Ask the user: *"When did you last run your morning briefing? (e.g. 'yesterday 5pm', '8am', or I'll default to last 24h)"*
If the user says "just go" or doesn't answer, default to **24 hours ago**.

---

## Step 1: Gmail

**Source ID**: `gmail`
**Skip if**: `gmail` not in sources

**Availability check**: Call `gmail_get_profile`. If it fails, note `📭 Gmail — not connected` and continue.

**Procedure**:
1. `gmail_get_profile` → capture `emailAddress` as account label
2. `gmail_search_messages`:
   - Query: `after:{YYYY/MM/DD} in:inbox -category:promotions -category:social`
   - Use the date portion of cutoff, converted to user's timezone
   - `maxResults`: 30
3. For each message, use `gmail_read_message` to extract:
   - Sender (first name + domain, e.g. "Sarah · acme.com")
   - Subject
   - One neutral sentence describing the content
   - Link: `https://mail.google.com/mail/u/0/#inbox/{message_id}`
4. Classify:
   - **Action** — requires reply, approval, or decision
   - **FYI** — informational, no response expected
   - **Skip** — automated notifications, receipts, newsletters → omit
5. Keep max 8 Action, max 5 FYI. If more: "…and N more."

---

## Step 2: Google Calendar

**Source ID**: `google_calendar`
**Skip if**: `google_calendar` not in sources

**Availability check**: Call `gcal_list_events` with a narrow window. If it fails, note `📭 Google Calendar — not connected` and continue.

**Procedure**:
1. `gcal_list_events` for two windows (in user's timezone):
   - **Today**: `timeMin` = start of today, `timeMax` = end of today
   - **Next 3 days**: `timeMin` = start of tomorrow, `timeMax` = end of day+3
2. For each event show:
   - Time in user's timezone (12h format, e.g. "2:30 PM") or "All day"
   - Title
   - Attendees: first names; if > 3 people → "you + N others"
   - Zoom/Meet link if present in location or conferenceData
   - Calendar link: `htmlLink` from event
3. Skip working-location markers (eventType: "workingLocation")

---

## Step 3: Slack

**Source ID**: `slack`
**Skip if**: `slack` not in sources

**Availability check**: Call `slack_search_public_and_private` with a minimal query. If it fails, note `📭 Slack — not connected` and continue.

**Procedure**:
1. `slack_search_public_and_private`:
   - Query: `to:me after:{cutoff as YYYY-MM-DD}`
   - `sort`: `timestamp`, `sort_dir`: `desc`
   - `limit`: 20
2. For each result extract:
   - Sender name
   - Channel name (or "DM" if direct message)
   - One neutral sentence describing the message
   - Link: `https://{workspace}.slack.com/archives/{channel_id}/p{message_ts_without_dot}`
3. Classify: **Action** / **FYI** / **Skip** (same rules as Gmail)
4. Keep max 8 Action, max 5 FYI. If more: "…and N more."
5. Merge into unified Action / FYI lists with prefix "Slack"

---

## Step 4: Jira

**Source ID**: `jira`
**Skip if**: `jira` not in sources

**Availability check**: Call `searchJiraIssuesUsingJql` with a minimal query. If it fails, note `📭 Jira — not connected` and continue.

**Procedure**:
1. `searchJiraIssuesUsingJql`:
   - JQL: `assignee = currentUser() AND updated >= "{cutoff as YYYY-MM-DD}" ORDER BY updated DESC`
   - `maxResults`: 15
2. For each ticket extract:
   - Issue key (e.g. `PD-123`)
   - Summary (title)
   - Status and priority
   - Project name
   - Link: `https://{jira_site}/browse/{issue_key}`
3. Group:
   - **Needs attention** — status changed to you, or high/highest priority
   - **In progress** — status = In Progress or equivalent
   - **Recently updated** — other tickets with activity since cutoff
4. Show max 10 total. If more: "…and N more."

---

## Step 5: Write the Briefing

Output directly in chat. No files. No preamble. Start with the header line.

```
**☀️ Good morning, {name}** · {Day, Date in timezone} · Last briefing: {cutoff as relative time}
{If any sources failed: 📭 Not connected: {list} ← omit if all succeeded}

---

### 📅 Today · {calendar account}
{events or "Nothing scheduled."}
{Omit section entirely if google_calendar not in sources}

### 🔮 Next 3 Days
{upcoming events}
{Omit if empty or google_calendar not in sources}

---

### 📬 Action Required ({N} items)
{account label} · **{Subject}** · {Sender} · {one neutral sentence} · [Open →]({link})
{Omit section entirely if no email/slack sources in config}

### 📋 FYI ({N} items)
{account label} · **{Subject}** · {Sender} · {one neutral sentence} · [Open →]({link})

---

### 🎫 Jira ({N} tickets)
{Omit section entirely if jira not in sources}

**Needs attention**
{priority icon} · [{issue_key}]({link}) · **{Summary}** · {Status} · {Project}

**In progress**
{priority icon} · [{issue_key}]({link}) · **{Summary}** · {Status} · {Project}

**Recently updated**
{priority icon} · [{issue_key}]({link}) · **{Summary}** · {Status} · {Project}
```

**Tone rules:**
- Factual, neutral — no "you should", no "consider", no "it's worth noting"
- One sentence per item
- If a section has sources configured but nothing to show: "Nothing new."
- No closing summary paragraph

---

## Tool Reference — Claude Desktop MCP Integrations

All available tools on Claude Desktop, organized by integration. The procedure above
references tools by short name — Claude Desktop resolves them from connected MCP servers.

### Gmail
| Tool | Purpose |
|------|---------|
| `gmail_get_profile` | Get authenticated user's email address |
| `gmail_search_messages` | Search emails with Gmail query syntax |
| `gmail_read_message` | Read a single email message |
| `gmail_read_thread` | Read an entire email thread |
| `gmail_create_draft` | Create an email draft |
| `gmail_list_drafts` | List email drafts |
| `gmail_list_labels` | List Gmail labels |

### Google Calendar
| Tool | Purpose |
|------|---------|
| `gcal_list_events` | List events in a time range |
| `gcal_list_calendars` | List available calendars |
| `gcal_get_event` | Get details of a specific event |
| `gcal_create_event` | Create a new calendar event |
| `gcal_update_event` | Update an existing event |
| `gcal_delete_event` | Delete an event |
| `gcal_find_meeting_times` | Find times when attendees are available |
| `gcal_find_my_free_time` | Find the user's free time slots |
| `gcal_respond_to_event` | RSVP to an event |

### Slack
| Tool | Purpose |
|------|---------|
| `slack_search_public_and_private` | Search all messages (public + private) |
| `slack_search_public` | Search public channels only |
| `slack_read_channel` | Read recent messages in a channel |
| `slack_read_thread` | Read a specific thread |
| `slack_read_user_profile` | Get user profile info |
| `slack_search_channels` | Search for channels by name |
| `slack_search_users` | Search for users |
| `slack_send_message` | Send a message to a channel or DM |
| `slack_send_message_draft` | Preview a message before sending |
| `slack_schedule_message` | Schedule a message for later |
| `slack_create_canvas` | Create a Slack canvas |
| `slack_read_canvas` | Read a Slack canvas |
| `slack_update_canvas` | Update a Slack canvas |

### Atlassian (Jira + Confluence)
| Tool | Purpose |
|------|---------|
| `searchJiraIssuesUsingJql` | Search Jira issues with JQL |
| `getJiraIssue` | Get full issue details |
| `createJiraIssue` | Create a new issue |
| `editJiraIssue` | Update issue fields |
| `transitionJiraIssue` | Change issue status |
| `addCommentToJiraIssue` | Add a comment to an issue |
| `addWorklogToJiraIssue` | Log work on an issue |
| `getTransitionsForJiraIssue` | Get available status transitions |
| `getJiraIssueRemoteIssueLinks` | Get remote links on an issue |
| `getJiraIssueTypeMetaWithFields` | Get issue type field metadata |
| `getJiraProjectIssueTypesMetadata` | Get project issue types |
| `getVisibleJiraProjects` | List accessible projects |
| `getIssueLinkTypes` | Get available issue link types |
| `createIssueLink` | Link two issues together |
| `lookupJiraAccountId` | Look up a user's Atlassian account ID |
| `atlassianUserInfo` | Get current user info |
| `getAccessibleAtlassianResources` | List accessible Atlassian sites |
| `fetchAtlassian` | Raw Atlassian API fetch |
| `searchAtlassian` | Broad search across Atlassian |
| `searchConfluenceUsingCql` | Search Confluence with CQL |
| `getConfluencePage` | Read a Confluence page |
| `getConfluenceSpaces` | List Confluence spaces |
| `getPagesInConfluenceSpace` | List pages in a space |
| `getConfluencePageDescendants` | Get child pages |
| `getConfluencePageFooterComments` | Get footer comments |
| `getConfluencePageInlineComments` | Get inline comments |
| `getConfluenceCommentChildren` | Get comment replies |
| `createConfluencePage` | Create a new page |
| `updateConfluencePage` | Update an existing page |
| `createConfluenceFooterComment` | Add a footer comment |
| `createConfluenceInlineComment` | Add an inline comment |

### Figma (bonus — not used in briefings)
| Tool | Purpose |
|------|---------|
| `get_design_context` | Get design code + screenshot from Figma |
| `get_screenshot` | Get a screenshot of a Figma node |
| `get_metadata` | Get file/node metadata |
| `get_figjam` | Read FigJam boards |
| `generate_diagram` | Create a FigJam diagram |
| `search_design_system` | Search design system components |

---

## Extensibility — Adding New Sources

To add a new integration (e.g. GitHub PRs, Google Drive):

1. Add the source ID to the `Sources` line in the project instructions config
2. Add a new step section in this document between Step 4 and Step 5
3. Follow this pattern:

```
## Step N: {Source Name}
**Source ID**: {id}
**Skip if**: `{id}` not in sources
**Availability check**: Call {first tool}. If fails, note 📭 and continue.
**Procedure**: ...
**Classification**: Action / FYI / Skip
**Output**: Merge into unified lists with account prefix
```

4. Update the Tool Reference section with the new integration's tools
