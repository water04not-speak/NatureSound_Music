# Security Policy

## Reporting Security Issues

Please report security or privacy issues privately to the current repository maintainer before opening a public issue. If this repository does not list a dedicated security contact, use GitHub's private vulnerability reporting feature if available, or contact the maintainer through the repository profile.

When reporting, include:

- A clear description of the issue.
- Steps to reproduce or affected files.
- Potential impact.
- Whether the issue involves permissions, local files, account data, media resources, or network requests.

## Sensitive Data Rules

Do not commit:

- Real usernames, passwords, phone numbers, email addresses, test accounts, tokens, API keys, cloud service URLs, or private endpoints.
- HarmonyOS signing certificates, `.p12`, `.csr`, keystores, private keys, or local signing configuration.
- Copyright-protected full audio files, complete commercial lyrics, commercial album covers, singer images, or unlicensed third-party media.
- `local_music.private.json` or other local resource files used only for private testing.

## Supported Scope

This project is an open source learning and engineering reference project. Security fixes for permission minimization, private data handling, local resource loading, and dependency hygiene are welcome.
