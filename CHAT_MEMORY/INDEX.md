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

- 2026-05-11 02:30:31 +02:00 : [installer build 2026-05-11 02-30-31](logs/2026-05-11_02-30-31-installer-build-2026-05-11-02-30-31.md)
- 2026-05-11 02:23:13 +02:00 : [installer build 2026-05-11 02-23-13](logs/2026-05-11_02-23-13-installer-build-2026-05-11-02-23-13.md)
- 2026-05-11 02:20:20 +02:00 : [installer build 2026-05-11 02-20-20](logs/2026-05-11_02-20-20-installer-build-2026-05-11-02-20-20.md)
- 2026-05-11 02:15:23 +02:00 : [installer build 2026-05-11 02-15-23](logs/2026-05-11_02-15-23-installer-build-2026-05-11-02-15-23.md)
- 2026-05-11 02:12:51 +02:00 : [installer build 2026-05-11 02-12-51](logs/2026-05-11_02-12-51-installer-build-2026-05-11-02-12-51.md)
- 2026-05-11 02:11:18 +02:00 : [installer build 2026-05-11 02-11-18](logs/2026-05-11_02-11-18-installer-build-2026-05-11-02-11-18.md)
- 2026-05-11 02:00:46 +02:00 : [installer build 2026-05-11 02-00-46](logs/2026-05-11_02-00-46-installer-build-2026-05-11-02-00-46.md)
- 2026-05-11 01:56:31 +02:00 : [installer build 2026-05-11 01-56-31](logs/2026-05-11_01-56-31-installer-build-2026-05-11-01-56-31.md)
- 2026-05-11 01:54:00 +02:00 : [installer build 2026-05-11 01-54-00](logs/2026-05-11_01-54-00-installer-build-2026-05-11-01-54-00.md)
- 2026-05-11 01:50:52 +02:00 : [installer build 2026-05-11 01-50-52](logs/2026-05-11_01-50-52-installer-build-2026-05-11-01-50-52.md)
- 2026-05-11 01:47:55 +02:00 : [installer build 2026-05-11 01-47-55](logs/2026-05-11_01-47-55-installer-build-2026-05-11-01-47-55.md)
- 2026-05-11 01:44:13 +02:00 : [installer build 2026-05-11 01-44-13](logs/2026-05-11_01-44-13-installer-build-2026-05-11-01-44-13.md)
- 2026-05-11 01:38:37 +02:00 : [installer build 2026-05-11 01-38-37](logs/2026-05-11_01-38-37-installer-build-2026-05-11-01-38-37.md)
- 2026-05-11 01:33:40 +02:00 : [installer build 2026-05-11 01-33-40](logs/2026-05-11_01-33-40-installer-build-2026-05-11-01-33-40.md)
- 2026-05-11 01:25:30 +02:00 : [installer build 2026-05-11 01-25-30](logs/2026-05-11_01-25-30-installer-build-2026-05-11-01-25-30.md)
- 2026-05-11 00:59:24 +02:00 : [installer build 2026-05-11 00-59-23](logs/2026-05-11_00-59-24-installer-build-2026-05-11-00-59-23.md)
- 2026-05-07 23:11:17 +02:00 : [installer build 2026-05-07 23-11-17](logs/2026-05-07_23-11-17-installer-build-2026-05-07-23-11-17.md)
- 2026-05-07 23:05:05 +02:00 : [installer build 2026-05-07 23-05-05](logs/2026-05-07_23-05-05-installer-build-2026-05-07-23-05-05.md)
- 2026-05-07 21:52:43 +02:00 : [installer build 2026-05-07 21-52-43](logs/2026-05-07_21-52-43-installer-build-2026-05-07-21-52-43.md)
- 2026-05-07 21:48:28 +02:00 : [installer build 2026-05-07 21-48-28](logs/2026-05-07_21-48-28-installer-build-2026-05-07-21-48-28.md)
- 2026-05-07 21:32:53 +02:00 : [installer build 2026-05-07 21-32-53](logs/2026-05-07_21-32-53-installer-build-2026-05-07-21-32-53.md)
- 2026-05-07 21:21:35 +02:00 : [installer build 2026-05-07 21-21-35](logs/2026-05-07_21-21-35-installer-build-2026-05-07-21-21-35.md)
- 2026-05-07 21:16:41 +02:00 : [installer build 2026-05-07 21-16-41](logs/2026-05-07_21-16-41-installer-build-2026-05-07-21-16-41.md)
- 2026-05-07 21:12:08 +02:00 : [installer build 2026-05-07 21-12-08](logs/2026-05-07_21-12-08-installer-build-2026-05-07-21-12-08.md)
- 2026-05-07 21:10:34 +02:00 : [installer build 2026-05-07 21-10-34](logs/2026-05-07_21-10-34-installer-build-2026-05-07-21-10-34.md)
- 2026-05-07 21:05:12 +02:00 : [installer build 2026-05-07 21-05-12](logs/2026-05-07_21-05-12-installer-build-2026-05-07-21-05-12.md)
- 2026-05-07 20:52:55 +02:00 : [installer build 2026-05-07 20-52-55](logs/2026-05-07_20-52-55-installer-build-2026-05-07-20-52-55.md)
- 2026-05-07 20:49:08 +02:00 : [installer build 2026-05-07 20-49-08](logs/2026-05-07_20-49-08-installer-build-2026-05-07-20-49-08.md)
- 2026-05-07 20:45:01 +02:00 : [installer build 2026-05-07 20-45-01](logs/2026-05-07_20-45-01-installer-build-2026-05-07-20-45-01.md)
- 2026-05-07 20:35:00 +02:00 : [installer build 2026-05-07 20-35-00](logs/2026-05-07_20-35-00-installer-build-2026-05-07-20-35-00.md)
