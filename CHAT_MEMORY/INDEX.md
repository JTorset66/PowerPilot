# Chat Memory Index

Use this folder to keep session summaries and pasted chat transcripts close to the codebase.

Important limit:

- Full automatic capture of IDE chat history is not available from this repo alone because the editor chat stream is not exposed to the local project files.
- The helper script here gives a fast local save path so the repo can still keep durable memory between sessions.

## Current pinned files

- CURRENT_CONTEXT.md for the latest working summary
- LATEST_BUILD.md for the latest auto-generated installer-build summary
- ..\STARTUP_CONTEXT.md for build and installer verification

## Retention defaults

- chat-memory entries kept: 30
- snapshot archives are trimmed by build-installer.ps1, default: 8

## Saving new chat memory

Example:

    powershell
    .\CHAT_MEMORY\save-chat-memory.ps1 -FromClipboard -Title "dGPU display recovery"

You can also pass text directly:

    powershell
    .\CHAT_MEMORY\save-chat-memory.ps1 -Title "session note" -Text "Summary goes here"

## Saved entries

- 2026-05-02 00:50:19 +02:00 : [installer build 2026-05-02 00-50-19](logs/2026-05-02_00-50-19-installer-build-2026-05-02-00-50-19.md)
- 2026-05-02 00:37:51 +02:00 : [installer build 2026-05-02 00-37-51](logs/2026-05-02_00-37-51-installer-build-2026-05-02-00-37-51.md)
- 2026-05-02 00:00:00 +02:00 : [installer build 2026-05-01 23-59-59](logs/2026-05-02_00-00-00-installer-build-2026-05-01-23-59-59.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-28 17-47-35](logs/2026-04-28_17-47-35-installer-build-2026-04-28-17-47-35.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-28 17-45-35](logs/2026-04-28_17-45-35-installer-build-2026-04-28-17-45-35.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-28 17-36-45](logs/2026-04-28_17-36-45-installer-build-2026-04-28-17-36-45.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-28 17-28-48](logs/2026-04-28_17-28-48-installer-build-2026-04-28-17-28-48.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-28 17-19-49](logs/2026-04-28_17-19-49-installer-build-2026-04-28-17-19-49.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-28 17-25-44](logs/2026-04-28_17-25-44-installer-build-2026-04-28-17-25-44.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-28 17-16-20](logs/2026-04-28_17-16-21-installer-build-2026-04-28-17-16-20.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-23 01-11-29](logs/2026-04-23_01-11-29-installer-build-2026-04-23-01-11-29.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-23 00-12-08](logs/2026-04-23_00-12-08-installer-build-2026-04-23-00-12-08.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-23 00-20-49](logs/2026-04-23_00-20-49-installer-build-2026-04-23-00-20-49.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 23-58-57](logs/2026-04-22_23-58-57-installer-build-2026-04-22-23-58-57.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 23-36-30](logs/2026-04-22_23-36-30-installer-build-2026-04-22-23-36-30.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 23-32-30](logs/2026-04-22_23-32-30-installer-build-2026-04-22-23-32-30.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 19-08-02](logs/2026-04-22_19-08-02-installer-build-2026-04-22-19-08-02.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 19-03-24](logs/2026-04-22_19-03-24-installer-build-2026-04-22-19-03-24.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 19-00-07](logs/2026-04-22_19-00-07-installer-build-2026-04-22-19-00-07.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 18-54-08](logs/2026-04-22_18-54-08-installer-build-2026-04-22-18-54-08.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 18-45-10](logs/2026-04-22_18-45-10-installer-build-2026-04-22-18-45-10.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 18-39-31](logs/2026-04-22_18-39-31-installer-build-2026-04-22-18-39-31.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 18-32-32](logs/2026-04-22_18-32-32-installer-build-2026-04-22-18-32-32.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 18-20-56](logs/2026-04-22_18-20-56-installer-build-2026-04-22-18-20-56.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 18-04-39](logs/2026-04-22_18-04-40-installer-build-2026-04-22-18-04-39.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 02-41-23](logs/2026-04-22_02-41-24-installer-build-2026-04-22-02-41-23.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 02-24-27](logs/2026-04-22_02-24-27-installer-build-2026-04-22-02-24-27.md)
- 2026-05-01 23:49:26 +02:00 : [powerpilot ui gpu devices and helper architecture](logs/2026-04-22_02-17-49-powerpilot-ui-gpu-devices-and-helper-architecture.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 01-58-01](logs/2026-04-22_01-58-01-installer-build-2026-04-22-01-58-01.md)
- 2026-05-01 23:49:26 +02:00 : [installer build 2026-04-22 01-22-47](logs/2026-04-22_01-22-48-installer-build-2026-04-22-01-22-47.md)
