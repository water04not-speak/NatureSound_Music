# Contributing to NatureSound Music

NatureSound Music is a HarmonyOS / ArkTS / ArkUI learning project and engineering reference for music playback, lyric synchronization, local data storage, and non-heritage music content organization. Contributions should keep the project reusable, legally clean, and approachable for new developers.

## Development Environment

- DevEco Studio with HarmonyOS SDK 5.0.5 or a compatible SDK.
- HarmonyOS emulator or device for runtime verification.
- Run the `entry` module from the project root.
- Use your own local debug signing configuration. Do not commit signing certificates or local IDE configuration.

## Branch Naming

Use short, descriptive branch names:

- `feature/<topic>` for new functionality.
- `fix/<topic>` for bug fixes.
- `docs/<topic>` for documentation.
- `chore/<topic>` for maintenance work.

## Commit Messages

Prefer concise commit messages that describe the user-visible change:

- `docs: add open source contribution guide`
- `fix: stabilize lyric progress calculation`
- `test: add lrc parser cases`

## Issues

When opening an issue, include:

- What you expected to happen.
- What actually happened.
- Reproduction steps.
- DevEco Studio, HarmonyOS SDK, device or emulator information.
- Screenshots, logs, or short screen recordings when helpful.
- Whether the issue involves media resources, privacy, permissions, or local files.

## Pull Requests

Before opening a PR:

- Keep the change focused and avoid unrelated refactors.
- Explain the motivation and affected modules.
- Add or update tests when changing parser, playback state, repository, or utility logic.
- Update documentation when behavior, permissions, setup, or resource boundaries change.
- Run the app locally when the change affects UI or playback.

## Code Style

- Follow the existing ArkTS / ArkUI style in nearby files.
- Keep pages, models, utilities, and resources in their existing directories.
- Prefer small, readable functions and clear names.
- Avoid adding new dependencies unless they clearly reduce maintenance cost.

## Resource Copyright Requirements

Do not submit PRs containing:

- Copyright-protected full audio files.
- Complete commercial lyrics.
- Commercial album covers, singer photos, or brand assets without explicit redistribution rights.
- API keys, real accounts, passwords, private URLs, signing certificates, or local private resource files.

Demo resources should be original, licensed for redistribution, or clearly marked placeholders. If a PR adds media or screenshots, include the source and license information.
