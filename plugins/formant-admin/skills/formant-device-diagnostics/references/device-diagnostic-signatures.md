# Device Diagnostic Signatures

Use this file only when deeper log-triage guidance is needed. Keep the main skill focused on workflow first.

| Signal | Interpretation | Strength |
| --- | --- | --- |
| `Calling AuthApi. Connection error` | The agent failed to reach the auth API during token refresh or auth-related work. This strongly suggests a broader device-to-cloud connectivity issue, but does not isolate DNS vs routing vs firewalling by itself. | `likely` |
| `Calling DeviceApi:DeviceControllerGetUpdatedConfiguration. Connection error` | The agent failed to poll the cloud for updated configuration. This directly proves config polling failure and usually belongs to the same connectivity failure class as auth errors. | `confirmed` for config polling failure; `likely` for broader connectivity |
| `Calling EventTriggerApi. Connection error` | The agent failed while synchronizing event-trigger state from the cloud. Relevant when stream-trigger behavior is missing and connectivity issues are suspected. | `confirmed` for trigger sync failure; `likely` for broader connectivity |
| `error getting default route interface: no default route found` | The machine does not currently have a default IPv4 route. This is direct evidence of a local routing problem. | `confirmed` |
| `listening for ROS Bridge gRPC on: ...` | The ROS bridge Unix socket listener started successfully. This proves only that part of the local agent stack initialized. Do not infer that cloud upload, config sync, or a specific multi-agent architecture is healthy. | `confirmed` for ROS bridge startup only |

Interpretation rules:
- Repetition matters. One transient connection error is weaker evidence than repeated failures over a window.
- Absence matters less than presence. Missing log lines do not prove the absence of a behavior unless log upload and ingestion are both known-good.
- Do not claim a specific host remediation from cloud-visible evidence alone unless the log line directly proves that condition.
