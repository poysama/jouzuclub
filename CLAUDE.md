# CLAUDE.md

This file provides instructions for AI assistants working on this repository.

## Project Overview

This is a Japanese grammar learning site built with Jekyll and the Just the Docs theme. It serves as a condensed reference guide (crib sheet) based on Tae Kim's Guide to Japanese Grammar.

## Repository Structure

```
docs/
├── basic-grammar/       # Foundational grammar (10 files)
├── essential-grammar/   # Intermediate concepts (14 files)
├── special-expressions/ # Advanced patterns (12 files)
└── advanced-topics/     # Formal/literary Japanese (5 files)
```

Each section has an `index.md` file that serves as the section landing page.

## Content Standards

### Vocabulary Format

Each grammar page should have a `## Vocabulary` section at the top using this numbered list format:

```markdown
## Vocabulary

1. 食べる 【た・べる】 (ru-verb) – to eat
2. 行く 【い・く】 (u-verb) – to go
3. する (irregular) – to do
4. 好き 【す・き】 (na-adj) – like
5. 高い 【たか・い】 (i-adj) – expensive
6. 学生 【がく・せい】 – student
```

Rules:
- Kanji followed by hiragana reading in 【】brackets
- Use ・ (middle dot) to separate syllables in the reading
- Include part of speech in parentheses for verbs and adjectives
- Use en-dash (–) before the English meaning
- Pure hiragana/katakana words don't need readings in brackets
- Loanwords (katakana) don't need readings

### Part of Speech Labels

- `(u-verb)` – Godan verbs (う-verbs)
- `(ru-verb)` – Ichidan verbs (る-verbs)
- `(irregular)` – する and 来る
- `(i-adj)` – い-adjectives
- `(na-adj)` – な-adjectives
- No label needed for nouns

### Example Sentences

- Use code blocks with `text` language for Japanese examples
- Format: `Japanese sentence。 - English translation.`
- No romaji - assume readers know hiragana and katakana
- Include 2-3 examples per grammar point

```markdown
```text
日本語を勉強する。 - I study Japanese.
映画を見た。 - I watched a movie.
```
```

### Notes and Admonitions

Use blockquote format for important notes:

```markdown
> **Note: Title of the note**
>
> Explanation text here with **bold** for emphasis.
>
> ```text
> Example sentences if needed.
> ```
```

### Page Front Matter

```yaml
---
layout: default
title: Page Title
parent: Section Name
nav_order: 1
---
```

## File Naming

- Use lowercase with hyphens: `te-form.md`, `causative-passive.md`
- Keep names concise but descriptive

## When Adding New Content

1. Add vocabulary section at the top with all words used in examples
2. Include hiragana readings for all kanji
3. Provide 2-3 example sentences per grammar point
4. Use the standard formatting described above
5. Update CHANGELOG.md with the changes

## Common Tasks

### Adding a new grammar page

1. Create the markdown file in the appropriate `docs/` subdirectory
2. Add front matter with correct parent and nav_order
3. Add vocabulary section following the format above
4. Write grammar explanations with example sentences
5. Update CHANGELOG.md

### Updating vocabulary format

When converting old table format to new list format:
- Old: `| Word | Meaning |` table rows
- New: `1. 漢字 【かな】 (part) – meaning`

## Build and Preview

```bash
bundle exec jekyll serve
```

Site will be available at `http://localhost:4000`
