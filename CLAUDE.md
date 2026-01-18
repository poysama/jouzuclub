# CLAUDE.md

This file provides instructions for AI assistants working on this repository.

## Project Overview

This is **Jouzu Club**, a Japanese grammar learning site built with Jekyll and the Just the Docs theme. It serves as a comprehensive guide to Japanese grammar, from basic to advanced topics. The site includes grammar explanations, a conjugation reference, and JLPT-style practice questions.

**Important**: The site was rebranded from "Nihongo Banzai" to "Jouzu Club" with repository references updated from `nihongobanzai` to `jouzuclub` in configuration.

## Repository Structure

```
docs/
├── basic-grammar/          # Foundational grammar (11 files)
│   ├── index.md
│   ├── state-of-being.md
│   ├── particles.md
│   ├── adjectives.md
│   ├── verb-basics.md
│   ├── negative-verbs.md
│   ├── past-tense.md
│   ├── te-form.md          # Enhanced with advanced usages
│   ├── relative-clauses.md
│   ├── sentence-particles.md
│   ├── compound-sentences.md
│   ├── transitive-intransitive.md
│   └── conjugation-reference.md  # New: comprehensive conjugation tables
├── essential-grammar/      # Intermediate concepts (14 files)
│   ├── polite-form.md
│   ├── numbers-counting.md    # Enhanced with 13 counter types
│   ├── giving-receiving.md    # Enhanced with comprehensive explanations
│   └── ... (other files)
├── special-expressions/    # Advanced patterns (12 files)
├── advanced-topics/        # Formal/literary Japanese (5 files)
└── mock-exam/             # JLPT-style practice (new section)
    ├── index.md           # Overview of all exam categories
    ├── grammar.md         # 20 particle/grammar questions
    ├── vocabulary.md      # 10 kanji reading questions
    ├── reading.md         # 5 reading comprehension passages
    └── listening.md       # Placeholder for future audio content
```

Each section has an `index.md` file that serves as the section landing page.

## Site Configuration

- **Title**: Jouzu Club - Japanese Grammar Guide
- **Baseurl**: `/jouzuclub` (critical for GitHub Pages links)
- **Repository**: `poysama/jouzuclub`
- **Theme**: just-the-docs with dark color scheme
- **Navigation**: Mock JLPT Exam section set to `nav_order: 99` (appears at bottom)

## Mock Exam Section Details

### Structure
The mock exam is organized into separate category pages, each with its own file:

1. **Grammar** (`grammar.md`, nav_order: 1)
   - 20 JLPT N5-N4 level questions
   - Tests particles and basic grammar structures
   - All text in hiragana with minimal kanji
   - Questions 1-10: Original content
   - Questions 11-20: Sourced from [JapaneseTest4You](https://japanesetest4you.com/japanese-language-proficiency-test-jlpt-n5-grammar-exercise-4/)

2. **Vocabulary** (`vocabulary.md`, nav_order: 2)
   - 10 kanji reading questions
   - Tests kun'yomi readings in context
   - Kanji enclosed in Japanese brackets: 「前」
   - Answer choices test ONLY the kanji stem (not okurigana)
   - Format: Real sentences with one kanji highlighted

3. **Reading** (`reading.md`, nav_order: 3)
   - 5 reading comprehension passages
   - Longer paragraph format (3-4 paragraphs each)
   - N5-N4 level vocabulary
   - Question 1 sourced from [The Japanese Page](https://www.thejapanesepage.com/jlpt-n5-reading-bento/)
   - Questions 2-5: Custom created

4. **Listening** (`listening.md`, nav_order: 4)
   - Placeholder page for future audio content
   - Contains description and suggestions for practice

### Mock Exam Answer Format
All questions use collapsible details blocks:

```markdown
<details markdown="block">
<summary>Show Answer</summary>

**Correct Answer: b) answer**

**Explanation:** Full explanation of why this is correct.

**Why others are incorrect:**
- Option a: Explanation
- Option c: Explanation
- Option d: Explanation

</details>
```

**Important**: Use `markdown="block"` attribute to ensure markdown renders properly inside details tags.

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

### JLPT Practice Questions Format

For N5-N4 level questions:
- Use mostly hiragana with basic kanji (木、水、本、etc.)
- Keep vocabulary simple and common
- Answer choices should be similar enough to be challenging but not misleading
- For vocabulary questions testing kanji: only test the kanji reading stem, not full words with okurigana

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

For mock exam pages, use `parent: Mock JLPT Exam` and appropriate nav_order.

## File Naming

- Use lowercase with hyphens: `te-form.md`, `causative-passive.md`
- Keep names concise but descriptive

## Enhanced Pages

The following pages have been significantly enhanced:

1. **conjugation-reference.md**: Comprehensive tables with 13+ conjugation types and step-by-step transformation guides
2. **te-form.md**: Added advanced usages section (7 additional uses beyond basics)
3. **giving-receiving.md**: Complete rewrite with perspective explanations and comparison tables
4. **numbers-counting.md**: Expanded with 13 counter types and detailed examples

## When Adding New Content

1. Add vocabulary section at the top with all words used in examples
2. Include hiragana readings for all kanji
3. Provide 2-3 example sentences per grammar point
4. Use the standard formatting described above
5. For mock exam questions:
   - Use `<details markdown="block">` for answer sections
   - Keep N5-N4 level vocabulary
   - Include full explanations for correct and incorrect answers
6. Update CHANGELOG.md with the changes

## Common Tasks

### Adding a new grammar page

1. Create the markdown file in the appropriate `docs/` subdirectory
2. Add front matter with correct parent and nav_order
3. Add vocabulary section following the format above
4. Write grammar explanations with example sentences
5. Update CHANGELOG.md

### Adding mock exam questions

1. Keep questions at N5-N4 level
2. Use hiragana-heavy text with minimal kanji
3. For vocabulary questions: enclose kanji in 「」brackets
4. Test only kanji stems in answer choices (not okurigana)
5. Use `<details markdown="block">` for expandable answers
6. Include source attribution if using external content

### Updating vocabulary format

When converting old table format to new list format:
- Old: `| Word | Meaning |` table rows
- New: `1. 漢字 【かな】 (part) – meaning`

## Build and Preview

```bash
bundle exec jekyll serve
```

Site will be available at `http://localhost:4000/jouzuclub/`

## External Content Credits

When using content from external sources, add attribution:
- Footer references on the page
- Link to original source
- Examples: The Japanese Page, JapaneseTest4You

## Important Reminders

- Always use correct baseurl (`/jouzuclub`) in all internal links: `{{ site.baseurl }}/docs/...`
- Mock exam nav_order: Grammar(1), Vocabulary(2), Reading(3), Listening(4)
- Kanji in vocabulary questions: use 「」not bold or other brackets
- All collapsible sections need `markdown="block"` attribute
