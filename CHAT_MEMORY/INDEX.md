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

- 2026-05-03 03:33:18 +02:00 : [installer build 2026-05-03 03-33-18](logs/2026-05-03_03-33-18-installer-build-2026-05-03-03-33-18.md)
- 2026-05-03 03:29:24 +02:00 : [installer build 2026-05-03 03-29-24](logs/2026-05-03_03-29-24-installer-build-2026-05-03-03-29-24.md)
- 2026-05-03 03:28:20 +02:00 : [installer build 2026-05-03 03-28-20](logs/2026-05-03_03-28-20-installer-build-2026-05-03-03-28-20.md)
- 2026-05-03 03:22:02 +02:00 : [installer build 2026-05-03 03-22-02](logs/2026-05-03_03-22-02-installer-build-2026-05-03-03-22-02.md)
- 2026-05-03 03:19:11 +02:00 : [installer build 2026-05-03 03-19-11](logs/2026-05-03_03-19-11-installer-build-2026-05-03-03-19-11.md)
- 2026-05-03 03:14:17 +02:00 : [installer build 2026-05-03 03-14-17](logs/2026-05-03_03-14-17-installer-build-2026-05-03-03-14-17.md)
- 2026-05-03 03:13:50 +02:00 : [installer build 2026-05-03 03-13-49](logs/2026-05-03_03-13-50-installer-build-2026-05-03-03-13-49.md)
- 2026-05-03 03:07:49 +02:00 : [installer build 2026-05-03 03-07-48](logs/2026-05-03_03-07-49-installer-build-2026-05-03-03-07-48.md)
- 2026-05-03 03:05:47 +02:00 : [installer build 2026-05-03 03-05-47](logs/2026-05-03_03-05-47-installer-build-2026-05-03-03-05-47.md)
- 2026-05-03 03:03:36 +02:00 : [installer build 2026-05-03 03-03-36](logs/2026-05-03_03-03-36-installer-build-2026-05-03-03-03-36.md)
- 2026-05-03 03:02:21 +02:00 : [installer build 2026-05-03 03-02-21](logs/2026-05-03_03-02-21-installer-build-2026-05-03-03-02-21.md)
- 2026-05-03 03:01:07 +02:00 : [installer build 2026-05-03 03-01-07](logs/2026-05-03_03-01-07-installer-build-2026-05-03-03-01-07.md)
- 2026-05-03 02:59:45 +02:00 : [installer build 2026-05-03 02-59-45](logs/2026-05-03_02-59-45-installer-build-2026-05-03-02-59-45.md)
- 2026-05-03 02:57:24 +02:00 : [installer build 2026-05-03 02-57-24](logs/2026-05-03_02-57-24-installer-build-2026-05-03-02-57-24.md)
- 2026-05-03 02:56:40 +02:00 : [installer build 2026-05-03 02-56-39](logs/2026-05-03_02-56-39-installer-build-2026-05-03-02-56-39.md)
- 2026-05-03 02:50:56 +02:00 : [installer build 2026-05-03 02-50-56](logs/2026-05-03_02-50-56-installer-build-2026-05-03-02-50-56.md)
- 2026-05-03 02:44:40 +02:00 : [installer build 2026-05-03 02-44-40](logs/2026-05-03_02-44-40-installer-build-2026-05-03-02-44-40.md)
- 2026-05-03 02:37:24 +02:00 : [installer build 2026-05-03 02-37-24](logs/2026-05-03_02-37-24-installer-build-2026-05-03-02-37-24.md)
- 2026-05-03 02:34:34 +02:00 : [installer build 2026-05-03 02-34-34](logs/2026-05-03_02-34-34-installer-build-2026-05-03-02-34-34.md)
- 2026-05-03 02:33:54 +02:00 : [installer build 2026-05-03 02-33-54](logs/2026-05-03_02-33-54-installer-build-2026-05-03-02-33-54.md)
- 2026-05-03 02:29:26 +02:00 : [installer build 2026-05-03 02-29-26](logs/2026-05-03_02-29-26-installer-build-2026-05-03-02-29-26.md)
- 2026-05-03 02:27:40 +02:00 : [installer build 2026-05-03 02-27-40](logs/2026-05-03_02-27-40-installer-build-2026-05-03-02-27-40.md)
- 2026-05-03 02:25:20 +02:00 : [installer build 2026-05-03 02-25-20](logs/2026-05-03_02-25-20-installer-build-2026-05-03-02-25-20.md)
- 2026-05-03 02:22:08 +02:00 : [installer build 2026-05-03 02-22-08](logs/2026-05-03_02-22-08-installer-build-2026-05-03-02-22-08.md)
- 2026-05-03 02:19:01 +02:00 : [installer build 2026-05-03 02-19-01](logs/2026-05-03_02-19-01-installer-build-2026-05-03-02-19-01.md)
- 2026-05-03 02:16:23 +02:00 : [installer build 2026-05-03 02-16-23](logs/2026-05-03_02-16-23-installer-build-2026-05-03-02-16-23.md)
- 2026-05-03 02:15:51 +02:00 : [installer build 2026-05-03 02-15-50](logs/2026-05-03_02-15-51-installer-build-2026-05-03-02-15-50.md)
- 2026-05-03 02:05:21 +02:00 : [installer build 2026-05-03 02-05-21](logs/2026-05-03_02-05-21-installer-build-2026-05-03-02-05-21.md)
- 2026-05-03 02:02:59 +02:00 : [installer build 2026-05-03 02-02-59](logs/2026-05-03_02-02-59-installer-build-2026-05-03-02-02-59.md)
- 2026-05-03 02:02:29 +02:00 : [installer build 2026-05-03 02-02-29](logs/2026-05-03_02-02-29-installer-build-2026-05-03-02-02-29.md)
