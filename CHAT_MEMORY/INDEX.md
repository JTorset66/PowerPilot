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

- 2026-05-17 13:34:51 +02:00 : [installer build 2026-05-17 13-34-51](logs/2026-05-17_13-34-51-installer-build-2026-05-17-13-34-51.md)
- 2026-05-17 13:31:19 +02:00 : [installer build 2026-05-17 13-31-19](logs/2026-05-17_13-31-19-installer-build-2026-05-17-13-31-19.md)
- 2026-05-17 12:25:58 +02:00 : [installer build 2026-05-17 12-25-58](logs/2026-05-17_12-25-58-installer-build-2026-05-17-12-25-58.md)
- 2026-05-17 12:20:57 +02:00 : [installer build 2026-05-17 12-20-57](logs/2026-05-17_12-20-57-installer-build-2026-05-17-12-20-57.md)
- 2026-05-17 12:17:21 +02:00 : [installer build 2026-05-17 12-17-21](logs/2026-05-17_12-17-21-installer-build-2026-05-17-12-17-21.md)
- 2026-05-17 12:10:21 +02:00 : [installer build 2026-05-17 12-10-21](logs/2026-05-17_12-10-21-installer-build-2026-05-17-12-10-21.md)
- 2026-05-13 12:51:40 +02:00 : [installer build 2026-05-13 12-51-40](logs/2026-05-13_12-51-40-installer-build-2026-05-13-12-51-40.md)
- 2026-05-13 12:46:34 +02:00 : [installer build 2026-05-13 12-46-34](logs/2026-05-13_12-46-34-installer-build-2026-05-13-12-46-34.md)
- 2026-05-13 12:41:24 +02:00 : [installer build 2026-05-13 12-41-24](logs/2026-05-13_12-41-24-installer-build-2026-05-13-12-41-24.md)
- 2026-05-13 12:39:07 +02:00 : [installer build 2026-05-13 12-39-07](logs/2026-05-13_12-39-07-installer-build-2026-05-13-12-39-07.md)
- 2026-05-13 12:37:07 +02:00 : [installer build 2026-05-13 12-37-07](logs/2026-05-13_12-37-07-installer-build-2026-05-13-12-37-07.md)
- 2026-05-13 12:32:34 +02:00 : [installer build 2026-05-13 12-32-34](logs/2026-05-13_12-32-34-installer-build-2026-05-13-12-32-34.md)
- 2026-05-13 12:25:09 +02:00 : [installer build 2026-05-13 12-25-09](logs/2026-05-13_12-25-09-installer-build-2026-05-13-12-25-09.md)
- 2026-05-13 12:06:58 +02:00 : [installer build 2026-05-13 12-06-57](logs/2026-05-13_12-06-58-installer-build-2026-05-13-12-06-57.md)
- 2026-05-11 16:50:17 +02:00 : [installer build 2026-05-11 16-50-16](logs/2026-05-11_16-50-17-installer-build-2026-05-11-16-50-16.md)
- 2026-05-11 16:26:27 +02:00 : [installer build 2026-05-11 16-26-27](logs/2026-05-11_16-26-27-installer-build-2026-05-11-16-26-27.md)
- 2026-05-11 16:06:01 +02:00 : [installer build 2026-05-11 16-06-01](logs/2026-05-11_16-06-01-installer-build-2026-05-11-16-06-01.md)
- 2026-05-11 15:55:38 +02:00 : [installer build 2026-05-11 15-55-38](logs/2026-05-11_15-55-38-installer-build-2026-05-11-15-55-38.md)
- 2026-05-11 15:44:58 +02:00 : [installer build 2026-05-11 15-44-58](logs/2026-05-11_15-44-58-installer-build-2026-05-11-15-44-58.md)
- 2026-05-11 15:39:05 +02:00 : [installer build 2026-05-11 15-39-05](logs/2026-05-11_15-39-05-installer-build-2026-05-11-15-39-05.md)
- 2026-05-11 15:33:02 +02:00 : [installer build 2026-05-11 15-33-02](logs/2026-05-11_15-33-02-installer-build-2026-05-11-15-33-02.md)
- 2026-05-11 14:39:28 +02:00 : [installer build 2026-05-11 14-39-28](logs/2026-05-11_14-39-28-installer-build-2026-05-11-14-39-28.md)
- 2026-05-11 14:27:42 +02:00 : [installer build 2026-05-11 14-27-41](logs/2026-05-11_14-27-42-installer-build-2026-05-11-14-27-41.md)
- 2026-05-11 14:15:03 +02:00 : [installer build 2026-05-11 14-15-03](logs/2026-05-11_14-15-03-installer-build-2026-05-11-14-15-03.md)
- 2026-05-11 14:08:00 +02:00 : [installer build 2026-05-11 14-08-00](logs/2026-05-11_14-08-00-installer-build-2026-05-11-14-08-00.md)
- 2026-05-11 14:06:26 +02:00 : [installer build 2026-05-11 14-06-26](logs/2026-05-11_14-06-26-installer-build-2026-05-11-14-06-26.md)
- 2026-05-11 13:42:15 +02:00 : [installer build 2026-05-11 13-42-15](logs/2026-05-11_13-42-15-installer-build-2026-05-11-13-42-15.md)
- 2026-05-11 13:30:40 +02:00 : [installer build 2026-05-11 13-30-40](logs/2026-05-11_13-30-40-installer-build-2026-05-11-13-30-40.md)
- 2026-05-11 13:25:59 +02:00 : [installer build 2026-05-11 13-25-59](logs/2026-05-11_13-25-59-installer-build-2026-05-11-13-25-59.md)
- 2026-05-11 13:21:41 +02:00 : [installer build 2026-05-11 13-21-41](logs/2026-05-11_13-21-41-installer-build-2026-05-11-13-21-41.md)
