---
name: formant-task-summary-analytics
description: This skill should be used when users ask to analyze, design, or operationalize task summary reporting in Formant, including task-summary event quality checks, analytics SQL patterns, KPI rollups, and report schema governance.
version: 0.1.0
---

# Formant Task Summary Analytics

Design and analyze task summary reporting workflows using Formant events and analytics.

## Scope

Use this skill for:
- task-summary analytics design
- KPI query patterns and summary rollups
- task summary data-quality checks
- report schema consistency guidance
- cross-checking task summaries against related events

Routing rules:
- For generic analytics workflows not centered on task summaries, use `formant-administrator`.
- For event trigger/alert logic, use `formant-event-automation`.
- For direct configuration document mutations, use `formant-config-lifecycle`.

## Guidance Stance

Treat this as a practical default lens, not a rulebook.

- Teams differ on what constitutes a “task.”
- Favor stable, queryable reporting structure over one-off payload flexibility.

## Default Workflow

### 1. Clarify analysis questions

Define what decisions this analysis should support, for example:
- throughput and completion trend
- duration and latency behavior
- failure and retry patterns
- per-device or per-mission comparisons

### 2. Inspect available data surfaces

```bash
formant event list --type task-summary --limit 200 --json
formant analytics tables --json
```

Start by inspecting the task summary table shape directly:

```bash
formant analytics query --sql "SELECT * FROM query_task_summary LIMIT 20" --json
```

### 3. Build canonical KPI queries

Use simple, auditable SQL first, then iterate.

```bash
# Daily task counts
formant analytics query --sql "
SELECT DATE_TRUNC('day', time) AS day, COUNT(*) AS task_count
FROM query_task_summary
WHERE time > '2026-01-01'
GROUP BY day
ORDER BY day
" --json

# Duration distribution by day
formant analytics query --sql "
SELECT DATE_TRUNC('day', time) AS day,
       AVG(duration_ms) AS avg_duration_ms,
       MAX(duration_ms) AS max_duration_ms,
       MIN(duration_ms) AS min_duration_ms
FROM query_task_summary
WHERE time > '2026-01-01'
GROUP BY day
ORDER BY day
" --json
```

### 4. Run data quality checks

Minimum checks:
- missing/invalid timing data
- duplicate task IDs for same format
- deleted rows leaking into dashboards
- unexpected null report fields

```bash
# Duplicate task IDs by format
formant analytics query --sql "
SELECT task_id, task_summary_format_id, COUNT(*) AS c
FROM query_task_summary
WHERE deleted_at IS NULL
GROUP BY task_id, task_summary_format_id
HAVING COUNT(*) > 1
" --json

# Timing sanity check
formant analytics query --sql "
SELECT task_id, time, end_time, duration_ms
FROM query_task_summary
WHERE end_time < time OR duration_ms < 0
LIMIT 100
" --json
```

### 5. Govern report shape for long-term usability

Practical defaults:
- use stable keys and consistent units
- avoid frequently changing report key names
- preserve backward compatibility when evolving format
- explicitly version schema assumptions in analysis notebooks/queries

### 6. Publish query set and ownership

For each KPI, record:
- SQL query text
- owner and expected refresh cadence
- alert thresholds (if any)
- known caveats and exclusions

## Practical Defaults

- Start with a narrow time window before scaling query range.
- Prefer trend and distribution views over single-point snapshots.
- Keep KPI definitions versioned and reviewable.

## References

- Task summaries: https://docs.formant.io/docs/task-summaries
- Create a task summary: https://docs.formant.io/docs/create-a-task-summary
- Query events in analytics: https://docs.formant.io/docs/query-events-in-analytics
