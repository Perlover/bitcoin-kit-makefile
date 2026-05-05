---
name: english-commit-messages
description: "Enforce English-only git commit messages in this project. Use when drafting, writing, editing, or reviewing any commit message - including the subject line, body, and footers (Co-Authored-By, Signed-off-by, etc.) - and when running `git commit`, `git commit --amend`, `git rebase -i` reword steps, or preparing a commit message in any other way. Applies regardless of the language used in the surrounding conversation."
---

# English Commit Messages

## Important

Every git commit message in this repository MUST be written in English. This is a hard project rule. It applies to:

- the subject line
- the body
- footers (`Co-Authored-By`, `Signed-off-by`, issue references, etc.)
- amended and reworded commits (`git commit --amend`, interactive rebase reword)

The language used in the conversation has no effect on the language of the commit message. If the change is described in another language, translate the intent into a clear English commit message before calling `git commit`. Do not include non-English text anywhere in the commit message, not even as a parenthetical or translation.

## Instructions

1. Write the subject in English using the imperative mood: "Add", "Fix", "Update", "Remove", "Refactor" - not "Added", "Fixes", or a noun phrase.
2. Keep the subject under ~70 characters; put details in the body.
3. If a body is needed, separate it from the subject with a blank line and write it in English. Wrap at ~72 characters per line.
4. Footers stay in English too. Issue/PR references (`Fixes #123`, `Refs PROJ-42`) are fine as-is.
5. Before invoking `git commit`, re-read the message and confirm every line is English. If any non-English fragment slipped in, rewrite it.
6. When amending or rewording, apply the same rule to the rewritten message.

## Examples

Subject only:

```
Fix lnd-update failing when stale pid file exists but process is not running
```

Subject + body:

```
Update LND to v0.20.1-beta

Bumps LND_ACTUAL_COMMIT to the v0.20.1-beta release commit and refreshes
CHANGES.txt accordingly. No changes to build flags or dependencies.
```
