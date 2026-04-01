# CLAUDE.md

## Project

FuzzySwift is a Swift port of [thefuzz](https://github.com/seatgeek/thefuzz), a fuzzy string matching library using the Ratcliff/Obershelp algorithm. All scores are integers from 0 to 100.

## Build & Test

```bash
swift build
swift test
```

## Structure

- `Sources/FuzzySwift/SequenceMatcher.swift` — Core Ratcliff/Obershelp algorithm
- `Sources/FuzzySwift/StringProcessing.swift` — String preprocessing (lowercase, strip punctuation, collapse whitespace)
- `Sources/FuzzySwift/Fuzz.swift` — Scoring functions (ratio, partialRatio, tokenSortRatio, tokenSetRatio, weightedRatio)
- `Sources/FuzzySwift/Process.swift` — Batch operations (extractOne, extract, extractBests, dedupe)
- `Tests/FuzzySwiftTests/` — Tests for each source file

## Conventions

- Swift 6.0 with strict concurrency
- No external dependencies
- Caseless enums (`Fuzz`, `FuzzyProcess`, `StringProcessing`) as namespaces
- All public types are `Sendable`
- Tests use Swift Testing framework (`import Testing`, `@Test`, `#expect`)
