---
name: formant-persona-chat
description: This skill should be used when users want to chat with a specific Formant persona via Theopolis, including persona selection, thread start/reuse, synchronous or asynchronous message turns, polling, history review, and multi-turn continuity on the same thread. Use formant-administrator for non-chat operations.
version: 0.1.0
---

# Formant Persona Chat

Run persona conversations in Theopolis with explicit persona identity and thread continuity.

## Scope

Use this skill for:
- direct user conversation with a specific persona
- selecting a persona before chat starts
- creating or reusing persona chat threads
- sending synchronous and asynchronous chat turns
- polling and history retrieval for long-running turns
- continuing multi-turn chat on the same thread

Routing rules:
- For non-chat Formant administration tasks, use `formant-administrator`.
- For config mutations, use `formant-config-lifecycle`.
- Keep chat state explicit: `environment`, `personaId`, and `threadId`.

## Default Workflow

### 1. Confirm chat intent and environment

Assume default environment is `prod` unless user asks for `--stage` or `--dev`.

### 2. Resolve persona

If persona is not explicit, identify candidates and ask one concise clarification.

```bash
formant persona list --json
formant persona get <persona-id> --json
```

### 3. Resolve or create thread

If user provides a `threadId`, continue that thread.
If no thread exists, create one bound to the selected persona.

```bash
formant persona chat start <persona-id> --name "<thread-name>" --json
```

Thread policy:
- multiple threads can exist for the same persona
- reuse thread by default for continuity
- create a new thread only on explicit user request or clear topic reset

### 4. Send message turn

Prefer synchronous wait mode for interactive conversation.

```bash
formant persona chat send <thread-id> "<message>" --json
```

Use async mode for long or tool-heavy turns.

```bash
formant persona chat send <thread-id> "<message>" --async --json
formant persona chat poll <thread-id> --after <sentAt> --wait --timeout 120 --json
```

Useful optional flags:
- `--model <model-id>` for per-turn model override
- `--persona <persona-id>` to force persona for a specific turn

### 5. Continue conversation

Continue sending on the same `threadId`.

```bash
formant persona chat history <thread-id> --limit 20 --json
```

### 6. Switch persona inside existing thread only when requested

```bash
formant persona chat switch-persona <thread-id> <persona-id> --json
```

## Response Handling Pattern

For programmatic handling, always use `--json` and read:
- `assistant.content`
- `threadId`
- `personaId`
- `sentAt`
- `timedOut`
- `socketError`

If user wants raw persona output, return `assistant.content` directly.
If user wants summarized output, summarize while keeping key decisions and caveats.
If output is to be used for further processing, carry forward `threadId` and `personaId`.

## Reliability and Recovery

If sync send returns no assistant content:
1. Check `timedOut` and `socketError`.
2. Poll using `sentAt`:
```bash
formant persona chat poll <thread-id> --after <sentAt> --wait --timeout 120 --json
```
3. Inspect history:
```bash
formant persona chat history <thread-id> --limit 50 --json
```

If thread persona is wrong or missing, switch persona and resend:
```bash
formant persona chat switch-persona <thread-id> <persona-id> --json
```

## Safety Rules

- Never fabricate persona responses; only return what the thread produced.
- Never expose credentials, tokens, or secret prompt content.
- Keep persona identity explicit in user-facing output when ambiguity exists.
