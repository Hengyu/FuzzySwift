import Testing
@testable import FuzzySwift

@Suite("Fuzz Tests")
struct FuzzTests {

    // MARK: - ratio

    @Test("Identical strings score 100")
    func ratioIdentical() {
        #expect(Fuzz.ratio("new york mets", "new york mets") == 100)
    }

    @Test("Empty strings score 0")
    func ratioEmpty() {
        #expect(Fuzz.ratio("", "") == 0)
    }

    @Test("Completely different strings score 0")
    func ratioDifferent() {
        #expect(Fuzz.ratio("abcdef", "ghijkl") == 0)
    }

    @Test("Similar strings have reasonable score")
    func ratioSimilar() {
        let score = Fuzz.ratio("new york mets", "new york meats")
        #expect(score > 80)
        #expect(score < 100)
    }

    // MARK: - partialRatio

    @Test("Substring match scores 100")
    func partialRatioSubstring() {
        #expect(Fuzz.partialRatio("yankees", "new york yankees") == 100)
    }

    @Test("Partial ratio empty string scores 0")
    func partialRatioEmpty() {
        #expect(Fuzz.partialRatio("", "test") == 0)
        #expect(Fuzz.partialRatio("test", "") == 0)
    }

    @Test("Partial ratio identical strings score 100")
    func partialRatioIdentical() {
        #expect(Fuzz.partialRatio("test", "test") == 100)
    }

    // MARK: - tokenSortRatio

    @Test("Reordered words score 100")
    func tokenSortReordered() {
        #expect(Fuzz.tokenSortRatio("fuzzy wuzzy was a bear", "wuzzy fuzzy was a bear") == 100)
    }

    @Test("Token sort with case differences")
    func tokenSortCase() {
        #expect(Fuzz.tokenSortRatio("Fuzzy Wuzzy", "wuzzy fuzzy") == 100)
    }

    // MARK: - tokenSetRatio

    @Test("Duplicate words still score 100")
    func tokenSetDuplicates() {
        #expect(Fuzz.tokenSetRatio("fuzzy was a bear", "fuzzy fuzzy was a bear") == 100)
    }

    @Test("Subset scores high")
    func tokenSetSubset() {
        let score = Fuzz.tokenSetRatio("new york mets", "new york mets vs atlanta braves")
        #expect(score >= 80)
    }

    // MARK: - partialTokenSortRatio

    @Test("Partial token sort with reordered substrings")
    func partialTokenSort() {
        let score = Fuzz.partialTokenSortRatio("mets york new", "the new york mets")
        #expect(score >= 60)
    }

    // MARK: - partialTokenSetRatio

    @Test("Partial token set with overlapping content")
    func partialTokenSet() {
        let score = Fuzz.partialTokenSetRatio("new york mets", "new york mets vs braves")
        #expect(score >= 80)
    }

    // MARK: - weightedRatio

    @Test("Weighted ratio on similar strings")
    func weightedRatioSimilar() {
        let score = Fuzz.weightedRatio("new york mets", "new york mets")
        #expect(score == 100)
    }

    @Test("Weighted ratio on different length strings")
    func weightedRatioDifferentLength() {
        let score = Fuzz.weightedRatio("mets", "new york mets")
        #expect(score > 50)
    }

    @Test("Weighted ratio empty returns 0")
    func weightedRatioEmpty() {
        #expect(Fuzz.weightedRatio("", "test") == 0)
        #expect(Fuzz.weightedRatio("test", "") == 0)
    }
}
