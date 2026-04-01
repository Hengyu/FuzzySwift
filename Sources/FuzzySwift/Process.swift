/// Batch fuzzy matching operations for searching and deduplicating strings.
public enum FuzzyProcess {

    /// A single match result from an extraction operation.
    public struct Match: Sendable {
        /// The matched string.
        public let string: String
        /// The similarity score (0-100).
        public let score: Int
        /// The index of the matched string in the original choices array.
        public let index: Int
    }

    /// Returns the single best match above `cutoff`, or `nil` if none qualifies.
    public static func extractOne(
        query: String,
        choices: [String],
        scorer: (String, String) -> Int = Fuzz.weightedRatio,
        cutoff: Int = 0
    ) -> Match? {
        var best: Match?
        for (index, choice) in choices.enumerated() {
            let score = scorer(query, choice)
            if score > cutoff, score > (best?.score ?? -1) {
                best = Match(string: choice, score: score, index: index)
            }
        }
        return best
    }

    /// Returns the top `limit` matches, sorted by score descending.
    public static func extract(
        query: String,
        choices: [String],
        scorer: (String, String) -> Int = Fuzz.weightedRatio,
        limit: Int = 5
    ) -> [Match] {
        return extractBests(query: query, choices: choices, scorer: scorer, cutoff: 0, limit: limit)
    }

    /// Returns all matches above `cutoff`, sorted by score descending, up to `limit`.
    public static func extractBests(
        query: String,
        choices: [String],
        scorer: (String, String) -> Int = Fuzz.weightedRatio,
        cutoff: Int = 0,
        limit: Int = 5
    ) -> [Match] {
        var matches: [Match] = []
        for (index, choice) in choices.enumerated() {
            let score = scorer(query, choice)
            if score > cutoff {
                matches.append(Match(string: choice, score: score, index: index))
            }
        }
        matches.sort { $0.score > $1.score }
        if matches.count > limit {
            matches = Array(matches.prefix(limit))
        }
        return matches
    }

    /// Removes near-duplicate strings using fuzzy matching.
    /// Groups similar strings (above `threshold`) and keeps the longest from each group.
    public static func dedupe(
        _ items: [String],
        threshold: Int = 70,
        scorer: (String, String) -> Int = Fuzz.tokenSetRatio
    ) -> [String] {
        guard !items.isEmpty else { return [] }

        let count = items.count
        // Union-Find
        var parent = Array(0..<count)

        func find(_ x: Int) -> Int {
            var x = x
            while parent[x] != x {
                parent[x] = parent[parent[x]]
                x = parent[x]
            }
            return x
        }

        func union(_ x: Int, _ y: Int) {
            let rx = find(x), ry = find(y)
            if rx != ry { parent[rx] = ry }
        }

        for i in 0..<count {
            for j in (i + 1)..<count {
                if scorer(items[i], items[j]) >= threshold {
                    union(i, j)
                }
            }
        }

        // Group by root, keep the longest string in each group
        var groups: [Int: Int] = [:] // root -> index of longest
        for i in 0..<count {
            let root = find(i)
            if let existing = groups[root] {
                if items[i].count > items[existing].count {
                    groups[root] = i
                }
            } else {
                groups[root] = i
            }
        }

        // Return in original order
        return groups.values.sorted().map { items[$0] }
    }
}
