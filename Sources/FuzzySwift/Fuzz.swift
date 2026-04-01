#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif

/// Core fuzzy string matching scoring functions.
/// All functions return an integer score from 0 to 100.
public enum Fuzz {

    // MARK: - Basic

    /// Full string similarity using the Ratcliff/Obershelp algorithm.
    public static func ratio(_ s1: String, _ s2: String) -> Int {
        Int(round(SequenceMatcher(s1, s2).ratio() * 100))
    }

    /// Best partial (substring) match. Uses matching blocks to identify
    /// candidate alignments, matching the Python thefuzz algorithm.
    public static func partialRatio(_ s1: String, _ s2: String) -> Int {
        let s1Count = s1.count
        let s2Count = s2.count
        let (shorter, longer, shortLen, longLen) = s1Count <= s2Count
            ? (s1, s2, s1Count, s2Count)
            : (s2, s1, s2Count, s1Count)

        guard shortLen > 0 else { return 0 }
        guard shortLen != longLen else {
            return ratio(s1, s2)
        }

        let matcher = SequenceMatcher(shorter, longer)
        let blocks = matcher.matchingBlocks()
        let longChars = Array(longer)

        var bestScore = 0.0
        for block in blocks where block.size > 0 {
            let longStart = max(0, block.j - block.i)
            let longEnd = min(longStart + shortLen, longChars.count)
            let substring = String(longChars[longStart..<longEnd])

            let r = SequenceMatcher(shorter, substring).ratio()
            if r > 0.995 { return 100 }
            if r > bestScore { bestScore = r }
        }

        return bestScore > 0 ? Int(round(bestScore * 100)) : 0
    }

    // MARK: - Token-Based

    /// Tokenizes both strings, sorts tokens alphabetically, then computes `ratio`.
    public static func tokenSortRatio(_ s1: String, _ s2: String) -> Int {
        let p1 = StringProcessing.fullProcess(s1)
        let p2 = StringProcessing.fullProcess(s2)
        return ratio(sortedTokens(p1), sortedTokens(p2))
    }

    /// Tokenizes both strings, sorts tokens alphabetically, then computes `partialRatio`.
    public static func partialTokenSortRatio(_ s1: String, _ s2: String) -> Int {
        let p1 = StringProcessing.fullProcess(s1)
        let p2 = StringProcessing.fullProcess(s2)
        return partialRatio(sortedTokens(p1), sortedTokens(p2))
    }

    /// Tokenizes both strings, computes intersection and remainders, then
    /// returns the maximum `ratio` among three candidate comparisons.
    public static func tokenSetRatio(_ s1: String, _ s2: String) -> Int {
        tokenSetScore(
            StringProcessing.fullProcess(s1),
            StringProcessing.fullProcess(s2),
            partialMatch: false
        )
    }

    /// Tokenizes both strings, computes intersection and remainders, then
    /// returns the maximum `partialRatio` among three candidate comparisons.
    public static func partialTokenSetRatio(_ s1: String, _ s2: String) -> Int {
        tokenSetScore(
            StringProcessing.fullProcess(s1),
            StringProcessing.fullProcess(s2),
            partialMatch: true
        )
    }

    /// Weighted ratio that intelligently selects the best algorithm based on
    /// the length ratio between the two strings. Matches the Python thefuzz WRatio logic.
    public static func weightedRatio(_ s1: String, _ s2: String) -> Int {
        let p1 = StringProcessing.fullProcess(s1)
        let p2 = StringProcessing.fullProcess(s2)

        guard !p1.isEmpty && !p2.isEmpty else { return 0 }

        let base = Double(ratio(p1, p2))
        let p1Count = p1.count
        let p2Count = p2.count
        let lenRatio = Double(max(p1Count, p2Count)) / Double(max(min(p1Count, p2Count), 1))
        let sorted1 = sortedTokens(p1)
        let sorted2 = sortedTokens(p2)

        if lenRatio >= 1.5 {
            let partialScale = lenRatio >= 8.0 ? 0.6 : 0.9
            let partial = Double(partialRatio(p1, p2)) * partialScale
            let ptsor = Double(partialRatio(sorted1, sorted2)) * 0.95 * partialScale
            let ptser = Double(tokenSetScore(p1, p2, partialMatch: true)) * 0.95 * partialScale
            return Int(round(max(base, partial, ptsor, ptser)))
        } else {
            let tsor = Double(ratio(sorted1, sorted2)) * 0.95
            let tser = Double(tokenSetScore(p1, p2, partialMatch: false)) * 0.95
            return Int(round(max(base, tsor, tser)))
        }
    }

    // MARK: - Private Helpers

    private static func sortedTokens(_ processed: String) -> String {
        processed.split(separator: " ").sorted().joined(separator: " ")
    }

    private static func tokenSetScore(_ p1: String, _ p2: String, partialMatch: Bool) -> Int {
        let tokens1 = Set(p1.split(separator: " ").map(String.init))
        let tokens2 = Set(p2.split(separator: " ").map(String.init))

        let intersection = tokens1.intersection(tokens2).sorted()
        let diff1to2 = tokens1.subtracting(tokens2).sorted()
        let diff2to1 = tokens2.subtracting(tokens1).sorted()

        let intersectionStr = intersection.joined(separator: " ")
        let combined1 = (intersection + diff1to2).joined(separator: " ")
        let combined2 = (intersection + diff2to1).joined(separator: " ")

        if partialMatch {
            return max(
                partialRatio(intersectionStr, combined1),
                partialRatio(intersectionStr, combined2),
                partialRatio(combined1, combined2)
            )
        } else {
            return max(
                ratio(intersectionStr, combined1),
                ratio(intersectionStr, combined2),
                ratio(combined1, combined2)
            )
        }
    }
}
