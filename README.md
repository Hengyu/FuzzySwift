# FuzzySwift

A Swift port of [thefuzz](https://github.com/seatgeek/thefuzz) (formerly fuzzywuzzy), the popular Python fuzzy string matching library by SeatGeek.

FuzzySwift uses the Ratcliff/Obershelp pattern matching algorithm to compute similarity scores between strings, returning values from 0 to 100.

## Requirements

- Swift 6.0+
- iOS 13+ / macOS 10.15+ / tvOS 13+ / watchOS 6+ / visionOS 1+

## Installation

Add FuzzySwift to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/aspect-build/FuzzySwift.git", from: "1.0.0"),
]
```

Then add it as a dependency to your target:

```swift
.target(name: "YourTarget", dependencies: ["FuzzySwift"]),
```

## Usage

### Basic Scoring

```swift
import FuzzySwift

// Full string similarity
Fuzz.ratio("new york mets", "new york mets") // 100
Fuzz.ratio("new york mets", "new york meats") // 96

// Substring matching
Fuzz.partialRatio("yankees", "new york yankees") // 100

// Order-independent matching
Fuzz.tokenSortRatio("fuzzy wuzzy was a bear", "wuzzy fuzzy was a bear") // 100

// Handles duplicates and subsets
Fuzz.tokenSetRatio("fuzzy was a bear", "fuzzy fuzzy was a bear") // 100

// Intelligent weighted scoring (picks the best algorithm automatically)
Fuzz.weightedRatio("new york mets", "new york mets") // 100
```

### Batch Processing

```swift
let choices = ["Atlanta Falcons", "New York Jets", "New York Giants", "Dallas Cowboys"]

// Best single match
let best = FuzzyProcess.extractOne(query: "new york jets", choices: choices)
// Match(string: "New York Jets", score: 100, index: 1)

// Top N matches
let top = FuzzyProcess.extract(query: "new york", choices: choices, limit: 2)

// All matches above a threshold
let good = FuzzyProcess.extractBests(query: "new york", choices: choices, cutoff: 70, limit: 10)

// Remove near-duplicate strings
let deduped = FuzzyProcess.dedupe(["New York Mets", "new york mets", "NY Mets"], threshold: 70)
```

## API Reference

### Fuzz

| Function | Description |
|---|---|
| `ratio(_:_:)` | Full string similarity |
| `partialRatio(_:_:)` | Best substring match |
| `tokenSortRatio(_:_:)` | Sort tokens, then compare |
| `tokenSetRatio(_:_:)` | Set-based token comparison |
| `partialTokenSortRatio(_:_:)` | Sort tokens, then partial match |
| `partialTokenSetRatio(_:_:)` | Set-based tokens, then partial match |
| `weightedRatio(_:_:)` | Automatically picks the best algorithm |

### FuzzyProcess

| Function | Description |
|---|---|
| `extractOne(query:choices:scorer:cutoff:)` | Single best match |
| `extract(query:choices:scorer:limit:)` | Top N matches |
| `extractBests(query:choices:scorer:cutoff:limit:)` | All matches above cutoff |
| `dedupe(_:threshold:scorer:)` | Remove near-duplicates |

## Acknowledgements

This library is a Swift port of [thefuzz](https://github.com/seatgeek/thefuzz) by [SeatGeek](https://seatgeek.com), which implements fuzzy string matching based on the Ratcliff/Obershelp algorithm (equivalent to Python's `difflib.SequenceMatcher`).

## License

FuzzySwift is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
