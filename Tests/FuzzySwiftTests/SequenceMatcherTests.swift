import Testing
@testable import FuzzySwift

@Suite("SequenceMatcher Tests")
struct SequenceMatcherTests {

    @Test("Identical strings have ratio 1.0")
    func identicalStrings() {
        let matcher = SequenceMatcher("abcde", "abcde")
        #expect(matcher.ratio() == 1.0)
    }

    @Test("Empty strings have ratio 0.0")
    func emptyStrings() {
        #expect(SequenceMatcher("", "").ratio() == 0.0)
    }

    @Test("One empty string has ratio 0.0")
    func oneEmpty() {
        #expect(SequenceMatcher("abc", "").ratio() == 0.0)
        #expect(SequenceMatcher("", "abc").ratio() == 0.0)
    }

    @Test("Completely different strings have ratio 0.0")
    func completelyDifferent() {
        #expect(SequenceMatcher("abc", "xyz").ratio() == 0.0)
    }

    @Test("Known ratio values")
    func knownRatios() {
        // "abc" vs "abc" = 1.0
        #expect(SequenceMatcher("abc", "abc").ratio() == 1.0)

        // "abcd" vs "efgh" = 0.0
        #expect(SequenceMatcher("abcd", "efgh").ratio() == 0.0)

        // "ab" vs "ba" = 0.5 (1 match out of 4 total chars -> 2*1/4)
        let r = SequenceMatcher("ab", "ba").ratio()
        #expect(r >= 0.49 && r <= 0.51)
    }

    @Test("Matching blocks for simple case")
    func matchingBlocks() {
        let matcher = SequenceMatcher("abxcd", "abcd")
        let blocks = matcher.matchingBlocks()

        // Should find "ab" at (0,0,2) and "cd" at (3,2,2), plus sentinel (5,4,0)
        #expect(blocks.count == 3)
        #expect(blocks[0] == SequenceMatcher.MatchingBlock(i: 0, j: 0, size: 2))
        #expect(blocks[1] == SequenceMatcher.MatchingBlock(i: 3, j: 2, size: 2))
        #expect(blocks.last == SequenceMatcher.MatchingBlock(i: 5, j: 4, size: 0))
    }

    @Test("Matching blocks sentinel always present")
    func matchingBlocksSentinel() {
        let blocks = SequenceMatcher("abc", "xyz").matchingBlocks()
        #expect(blocks.count == 1)
        #expect(blocks[0] == SequenceMatcher.MatchingBlock(i: 3, j: 3, size: 0))
    }

    @Test("Single character match")
    func singleChar() {
        let r = SequenceMatcher("a", "a").ratio()
        #expect(r == 1.0)
    }
}
