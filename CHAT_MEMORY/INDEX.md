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

- 2026-04-23 01:11:29 +08:00 : [installer build 2026-04-23 01-11-29](logs/2026-04-23_01-11-29-installer-build-2026-04-23-01-11-29.md)
- 2026-04-23 00:20:49 +08:00 : [installer build 2026-04-23 00-20-49](logs/2026-04-23_00-20-49-installer-build-2026-04-23-00-20-49.md)
- 2026-04-23 00:12:08 +08:00 : [installer build 2026-04-23 00-12-08](logs/2026-04-23_00-12-08-installer-build-2026-04-23-00-12-08.md)
- 2026-04-22 23:58:57 +08:00 : [installer build 2026-04-22 23-58-57](logs/2026-04-22_23-58-57-installer-build-2026-04-22-23-58-57.md)
- 2026-04-22 23:36:30 +08:00 : [installer build 2026-04-22 23-36-30](logs/2026-04-22_23-36-30-installer-build-2026-04-22-23-36-30.md)
- 2026-04-22 23:32:30 +08:00 : [installer build 2026-04-22 23-32-30](logs/2026-04-22_23-32-30-installer-build-2026-04-22-23-32-30.md)
- 2026-04-22 19:08:02 +08:00 : [installer build 2026-04-22 19-08-02](logs/2026-04-22_19-08-02-installer-build-2026-04-22-19-08-02.md)
- 2026-04-22 19:03:24 +08:00 : [installer build 2026-04-22 19-03-24](logs/2026-04-22_19-03-24-installer-build-2026-04-22-19-03-24.md)
- 2026-04-22 19:00:07 +08:00 : [installer build 2026-04-22 19-00-07](logs/2026-04-22_19-00-07-installer-build-2026-04-22-19-00-07.md)
- 2026-04-22 18:54:08 +08:00 : [installer build 2026-04-22 18-54-08](logs/2026-04-22_18-54-08-installer-build-2026-04-22-18-54-08.md)
- 2026-04-22 18:45:10 +08:00 : [installer build 2026-04-22 18-45-10](logs/2026-04-22_18-45-10-installer-build-2026-04-22-18-45-10.md)
- 2026-04-22 18:39:31 +08:00 : [installer build 2026-04-22 18-39-31](logs/2026-04-22_18-39-31-installer-build-2026-04-22-18-39-31.md)
- 2026-04-22 18:32:32 +08:00 : [installer build 2026-04-22 18-32-32](logs/2026-04-22_18-32-32-installer-build-2026-04-22-18-32-32.md)
- 2026-04-22 18:20:56 +08:00 : [installer build 2026-04-22 18-20-56](logs/2026-04-22_18-20-56-installer-build-2026-04-22-18-20-56.md)
- 2026-04-22 18:04:40 +08:00 : [installer build 2026-04-22 18-04-39](logs/2026-04-22_18-04-40-installer-build-2026-04-22-18-04-39.md)
- 2026-04-22 02:41:24 +08:00 : [installer build 2026-04-22 02-41-23](logs/2026-04-22_02-41-24-installer-build-2026-04-22-02-41-23.md)
- 2026-04-22 02:24:27 +08:00 : [installer build 2026-04-22 02-24-27](logs/2026-04-22_02-24-27-installer-build-2026-04-22-02-24-27.md)
- 2026-04-22 02:17:50 +08:00 : [powerpilot ui gpu devices and helper architecture](logs/2026-04-22_02-17-49-powerpilot-ui-gpu-devices-and-helper-architecture.md)
- 2026-04-22 01:58:01 +08:00 : [installer build 2026-04-22 01-58-01](logs/2026-04-22_01-58-01-installer-build-2026-04-22-01-58-01.md)
- 2026-04-22 01:22:48 +08:00 : [installer build 2026-04-22 01-22-47](logs/2026-04-22_01-22-48-installer-build-2026-04-22-01-22-47.md)
- 2026-04-20 00:17:13 +08:00 : [installer build 2026-04-20 00-17-13](logs/2026-04-20_00-17-13-installer-build-2026-04-20-00-17-13.md)
- 2026-04-20 00:03:58 +08:00 : [installer build 2026-04-20 00-03-58](logs/2026-04-20_00-03-58-installer-build-2026-04-20-00-03-58.md)
- 2026-04-19 23:56:17 +08:00 : [installer build 2026-04-19 23-56-17](logs/2026-04-19_23-56-17-installer-build-2026-04-19-23-56-17.md)
- 2026-04-19 23:50:42 +08:00 : [installer build 2026-04-19 23-50-42](logs/2026-04-19_23-50-42-installer-build-2026-04-19-23-50-42.md)
- 2026-04-19 23:44:31 +08:00 : [installer build 2026-04-19 23-44-31](logs/2026-04-19_23-44-31-installer-build-2026-04-19-23-44-31.md)
- 2026-04-19 23:38:43 +08:00 : [installer build 2026-04-19 23-38-43](logs/2026-04-19_23-38-43-installer-build-2026-04-19-23-38-43.md)
- 2026-04-19 23:01:43 +08:00 : [installer build 2026-04-19 23-01-43](logs/2026-04-19_23-01-43-installer-build-2026-04-19-23-01-43.md)
- 2026-04-19 19:34:06 +08:00 : [installer build 2026-04-19 19-34-06](logs/2026-04-19_19-34-06-installer-build-2026-04-19-19-34-06.md)
- 2026-04-19 19:26:19 +08:00 : [installer build 2026-04-19 19-26-19](logs/2026-04-19_19-26-19-installer-build-2026-04-19-19-26-19.md)
- 2026-04-19 19:14:28 +08:00 : [installer build 2026-04-19 19-14-27](logs/2026-04-19_19-14-28-installer-build-2026-04-19-19-14-27.md)
