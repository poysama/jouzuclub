# Jouzu Club - Japanese Grammar Guide

A comprehensive Japanese grammar learning website built with [Jekyll](https://jekyllrb.com/) and the [Just the Docs](https://just-the-docs.com/) theme.

## About

Jouzu Club is a complete guide to Japanese grammar, from basics to advanced topics. The site is designed for sequential learning, starting with foundational concepts and progressing through increasingly complex material.

**Prerequisites**: Learners should be familiar with hiragana (ひらがな) and katakana (カタカナ) before starting this guide.

## Features

- **Structured Grammar Sections**: Basic Grammar, Essential Grammar, Special Expressions, and Advanced Topics
- **Conjugation Reference**: Quick-reference tables for all major verb and adjective conjugations
- **Mock JLPT Exam**: Practice questions across multiple skill areas:
  - Grammar (20 questions)
  - Vocabulary (10 kanji reading questions)
  - Reading (5 comprehension passages)
  - Listening (placeholder for future audio content)
- **Sequential Learning Path**: Content designed to be read in order for optimal understanding

## Setup

1.  **Install Ruby and Bundler**: Ensure you have a Ruby development environment installed.
2.  **Install Dependencies**:
    ```bash
    bundle install
    ```
3.  **Run Locally**:
    ```bash
    bundle exec jekyll serve
    ```
    The site will be available at `http://localhost:4000/jouzuclub/`.

## Deployment

This site is configured for GitHub Pages deployment.

1.  Push the repository to GitHub.
2.  Go to Settings > Pages.
3.  Select the branch (e.g., `main`) and folder (usually `/ (root)`).
4.  Your site will be live at `https://<username>.github.io/jouzuclub/`.

## Structure

- `_config.yml`: Site configuration (baseurl: `/jouzuclub`)
- `index.md`: Homepage with prerequisites and introduction
- `docs/`: Contains the markdown source files organized by section:
  - `basic-grammar/`: Foundational concepts (particles, conjugations, etc.)
  - `essential-grammar/`: Intermediate grammar (polite forms, giving/receiving, etc.)
  - `special-expressions/`: Advanced patterns (causative, passive, honorifics, etc.)
  - `advanced-topics/`: Formal and literary expressions
  - `mock-exam/`: JLPT-style practice questions

## Content Credits

This guide is based on and references [Tae Kim's Guide to Japanese](http://www.guidetojapanese.org/learn/). Additional practice materials sourced from:
- [The Japanese Page - JLPT N5 Reading](https://www.thejapanesepage.com/jlpt-n5-reading-bento/)
- [JapaneseTest4You - JLPT N5 Grammar Exercise 4](https://japanesetest4you.com/japanese-language-proficiency-test-jlpt-n5-grammar-exercise-4/)
