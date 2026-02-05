---
name: send-slack
description: Send a Slack message to a channel. Use when the user says "send slack", "slack message", "notify on slack", "post to slack", or wants to send a message to a Slack channel.
disable-model-invocation: false
---

# Send Slack Message

Send a message to a Slack channel using the Slack API via `curl`.

## When to use

- User asks to send a Slack message
- User says "send-slack", "post to slack", "notify on slack", or similar
- Another skill or workflow needs to notify a channel (e.g., after a long-running task completes)

## Prerequisites

The following environment variables must be set (typically in `~/.bashrc`):

- `SLACK_BOT_OATH_TOKEN` — Bot User OAuth Token (starts with `xoxb-`)
- `SLACK_TEAM_ID` — Slack workspace/team ID (starts with `T`)

The bot must be invited to the target channel in Slack (`/invite @BotName`).

## Steps

1. **Determine the channel and message.** If the user didn't specify:
   - Ask which channel to post to (default: `#llm-devs`)
   - Ask what the message should say

2. **Send the message** using `curl`:

```bash
source ~/.bashrc
curl -s -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer $SLACK_BOT_OATH_TOKEN" \
  -H "Content-type: application/json; charset=utf-8" \
  -d "$(python3 -c "import json; print(json.dumps({'channel': '#CHANNEL_NAME', 'text': 'YOUR MESSAGE HERE'}))")" \
  | python3 -m json.tool
```

**Note:** Use the `python3 -c json.dumps(...)` pattern to safely escape message text that may contain special characters, quotes, or newlines.

3. **Check the response.** Verify `"ok": true` in the JSON response. Common errors:
   - `channel_not_found` — Bot hasn't been invited to the channel, or channel name is wrong
   - `not_in_channel` — Bot needs to be invited with `/invite @BotName`
   - `invalid_auth` — Token is wrong or expired
   - `missing_scope` — Bot needs additional OAuth scopes (at minimum: `chat:write`)

4. **Report to user.** Confirm the message was sent, or relay the error.

## Defaults

- **Default channel:** `#llm-devs`
- If the user just says "send slack" without specifying a channel, use `#llm-devs`

## Examples

Simple message:
```bash
source ~/.bashrc
curl -s -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer $SLACK_BOT_OATH_TOKEN" \
  -H "Content-type: application/json; charset=utf-8" \
  -d '{"channel":"#llm-devs","text":"Hello from Cursor!"}' \
  | python3 -m json.tool
```

Message with special characters (use python3 for escaping):
```bash
source ~/.bashrc
curl -s -X POST https://slack.com/api/chat.postMessage \
  -H "Authorization: Bearer $SLACK_BOT_OATH_TOKEN" \
  -H "Content-type: application/json; charset=utf-8" \
  -d "$(python3 -c "import json; print(json.dumps({'channel': '#llm-devs', 'text': 'Build finished!\nResult: success\nTime: 3m 42s'}))")" \
  | python3 -m json.tool
```
