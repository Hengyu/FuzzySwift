import Foundation

/// Core fuzzy string matching scoring functions.
/// All functions return an integer score from 0 to 100.
public enum Fuzz {

    // MARK: - Basic

    /// Full string similarity using the Ratcliff/Obershelp algorithm.
    public static func ratio(_ s1: String, _ s2: String) -> Int {
        return Int(round(SequenceMatcher(s1, s2).ratio() * 100))
    }

    /// Best partial (substring) match. Slides the shorter string across the
    /// longer one and returns the best score found.
    public static func partialRatio(_ s1: String, _ s2: String) -> Int {
        let (shorter, longer) = s1.count <= s2.count ? (s1, s2) : (s2, s1)

        let shortChars = Array(shorter)
        let longChars = Array(longer)

        guard !shortChars.isEmpty else { return 0 }
        guard shortChars.count != longChars.count else {
            return ratio(s1, s2)
        }

        var bestScore = 0
        let windowSize = shortChars.count

        for i in 0...(longChars.count - windowSize) {
            let substring = String(longChars[i..<(i + windowSize)])
            let score = SequenceMatcher(shorter, substring).ratio()
            let intScore = Int(round(score * 100))
            if intScore > bestScore {
                bestScore = intScore
            }
            if bestScore == 100 { break }
        }

        return bestScore
    }

    // MARK: - Token-Based

    /// Tokenizes both strings, sorts tokens alphabetically, then computes `ratio`.
    public static func tokenSortRatio(_ s1: String, _ s2: String) -> Int {
        let sorted1 = tokenSort(s1)
        let sorted2 = tokenSort(s2)
        return ratio(sorted1, sorted2)
    }

    /// Tokenizes both strings, sorts tokens alphabetically, then computes `partialRatio`.
    public static func partialTokenSortRatio(_ s1: String, _ s2: String) -> Int {
        let sorted1 = tokenSort(s1)
        let sorted2 = tokenSort(s2)
        return partialRatio(sorted1, sorted2)
    }

    /// Tokenizes both strings, computes intersection and remainders, then
    /// returns the maximum `ratio` among three candidate comparisons.
    public static func tokenSetRatio(_ s1: String, _ s2: String) -> Int {
        return tokenSetScore(s1, s2, partialMatch: false)
    }

    /// Tokenizes both strings, computes intersection and remainders, then
    /// returns the maximum `partialRatio` among three candidate comparisons.
    public static func partialTokenSetRatio(_ s1: String, _ s2: String) -> Int {
        return tokenSetScore(s1, s2, partialMatch: true)
    }

    /// Weighted ratio that intelligently selects the best algorithm based on
    /// the length ratio between the two strings.
    public static func weightedRatio(_ s1: String, _ s2: String) -> Int {
        let p1 = StringProcessing.fullProcess(s1)
        let p2 = StringProcessing.fullProcess(s2)

        guard !p1.isEmpty && !p2.isEmpty else { return 0 }

        let base = ratio(p1, p2)
        let lenRatio = Double(max(p1.count, p2.count)) / Double(max(min(p1.count, p2.count), 1))

        var best = base

        // Try partial ratios for significantly different lengths
        if lenRatio >= 1.5 {
            let partial = partialRatio(p1, p2)
            let scale: Double = lenRatio >= 8.0 ? 0.6 : 0.9
            best = max(best, Int(round(Double(partial) * scale)))
        }

        // Token-based comparisons
        let tokenSort = tokenSortRatio(p1, p2)
        let tokenSet = tokenSetRatio(p1, p2)

        if lenRatio < 1.5 {
            best = max(best, tokenSort, tokenSet)
        } else if lenRatio < 8.0 {
            let partialTokenSort = partialTokenSortRatio(p1, p2)
            let partialTokenSet = partialTokenSetRatio(p1, p2)
            best = max(
                best,
                Int(round(Double(tokenSort) * 0.95)),
                Int(round(Double(tokenSet) * 0.95)),
                Int(round(Double(partialTokenSort) * 0.95)),
                Int(round(Double(partialTokenSet) * 0.95))
            )
        } else {
            let partialTokenSort = partialTokenSortRatio(p1, p2)
            let partialTokenSet = partialTokenSetRatio(p1, p2)
            best = max(
                best,
                Int(round(Double(tokenSort) * 0.95)),
                Int(round(Double(tokenSet) * 0.95)),
                Int(round(Double(partialTokenSort) * 0.95)),
                Int(round(Double(partialTokenSet) * 0.95))
            )
        }

        return best
    }

    // MARK: - Private Helpers

    private static func tokenSort(_ string: String) -> String {
        let processed = StringProcessing.fullProcess(string)
        let tokens = processed.split(separator: " ").sorted()
        return tokens.joined(separator: " ")
    }

    private static func tokenSetScore(_ s1: String, _ s2: String, partialMatch: Bool) -> Int {
        let p1 = StringProcessing.fullProcess(s1)
        let p2 = StringProcessing.fullProcess(s2)

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
