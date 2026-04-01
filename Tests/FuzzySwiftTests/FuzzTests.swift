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

    @Test("Ratio with Unicode strings")
    func ratioUnicode() {
        #expect(Fuzz.ratio("café", "café") == 100)
        #expect(Fuzz.ratio("日本語", "日本語") == 100)
        #expect(Fuzz.ratio("café", "cafe") > 70)
    }

    @Test("Ratio with emoji")
    func ratioEmoji() {
        #expect(Fuzz.ratio("hello 👋", "hello 👋") == 100)
        #expect(Fuzz.ratio("👋👋👋", "👋👋") > 50)
    }

    @Test("Ratio with repeated characters")
    func ratioRepeated() {
        let a = String(repeating: "a", count: 100)
        let b = String(repeating: "a", count: 100)
        #expect(Fuzz.ratio(a, b) == 100)

        let c = String(repeating: "a", count: 50) + String(repeating: "b", count: 50)
        #expect(Fuzz.ratio(a, c) > 40)
        #expect(Fuzz.ratio(a, c) < 60)
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

    @Test("Partial ratio with Unicode substring")
    func partialRatioUnicode() {
        #expect(Fuzz.partialRatio("café", "le café noir") == 100)
    }

    @Test("Partial ratio argument order does not matter")
    func partialRatioSymmetric() {
        let a = Fuzz.partialRatio("yankees", "new york yankees")
        let b = Fuzz.partialRatio("new york yankees", "yankees")
        #expect(a == b)
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

    @Test("Partial token sort with reordered substrings scores high")
    func partialTokenSort() {
        let score = Fuzz.partialTokenSortRatio("mets york new", "the new york mets")
        #expect(score >= 60)
    }

    @Test("Partial token sort identical scores 100")
    func partialTokenSortIdentical() {
        #expect(Fuzz.partialTokenSortRatio("hello world", "hello world") == 100)
    }

    // MARK: - partialTokenSetRatio

    @Test("Partial token set with overlapping content scores high")
    func partialTokenSet() {
        let score = Fuzz.partialTokenSetRatio("new york mets", "new york mets vs braves")
        #expect(score >= 80)
    }

    @Test("Partial token set identical scores 100")
    func partialTokenSetIdentical() {
        #expect(Fuzz.partialTokenSetRatio("hello world", "hello world") == 100)
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

    @Test("Weighted ratio with very different lengths applies partial scaling")
    func weightedRatioVeryDifferentLengths() {
        // Short query against long string triggers lenRatio >= 8 path
        let score = Fuzz.weightedRatio("ab", "ab cd ef gh ij kl mn op qr")
        #expect(score > 0)
        #expect(score < 100)
    }

    @Test("Weighted ratio with similar lengths uses token-based scoring")
    func weightedRatioSimilarLengths() {
        // Same tokens reordered, similar length — should use tokenSort/tokenSet
        let score = Fuzz.weightedRatio("great new york mets", "new york mets great")
        #expect(score >= 95)
    }
}
