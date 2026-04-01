import Testing
@testable import FuzzySwift

@Suite("FuzzyProcess Tests")
struct ProcessTests {

    let choices = [
        "Atlanta Falcons",
        "New York Jets",
        "New York Giants",
        "Dallas Cowboys",
    ]

    // MARK: - extractOne

    @Test("extractOne returns best match")
    func extractOneBest() {
        let result = FuzzyProcess.extractOne(query: "new york jets", choices: choices)
        #expect(result != nil)
        #expect(result?.string == "New York Jets")
        #expect(result?.score == 100)
    }

    @Test("extractOne returns nil when nothing exceeds cutoff")
    func extractOneNilCutoff() {
        let result = FuzzyProcess.extractOne(
            query: "zzzzzzz",
            choices: choices,
            cutoff: 80
        )
        #expect(result == nil)
    }

    @Test("extractOne with empty choices returns nil")
    func extractOneEmpty() {
        let result = FuzzyProcess.extractOne(query: "test", choices: [])
        #expect(result == nil)
    }

    // MARK: - extract

    @Test("extract returns limited results sorted by score")
    func extractLimited() {
        let results = FuzzyProcess.extract(query: "new york", choices: choices, limit: 2)
        #expect(results.count == 2)
        #expect(results[0].score >= results[1].score)
    }

    @Test("extract returns correct indices")
    func extractIndices() {
        let results = FuzzyProcess.extract(query: "new york jets", choices: choices, limit: 1)
        #expect(results.first?.index == 1)
    }

    // MARK: - extractBests

    @Test("extractBests respects cutoff")
    func extractBestsCutoff() {
        let results = FuzzyProcess.extractBests(
            query: "new york jets",
            choices: choices,
            cutoff: 80,
            limit: 10
        )
        for result in results {
            #expect(result.score > 80)
        }
    }

    @Test("extractBests with limit larger than results returns all matches")
    func extractBestsLargeLimit() {
        let results = FuzzyProcess.extractBests(
            query: "new york",
            choices: choices,
            cutoff: 0,
            limit: 100
        )
        #expect(results.count == choices.count)
    }

    // MARK: - dedupe

    @Test("dedupe removes near-duplicates")
    func dedupeBasic() {
        let items = [
            "New York Mets",
            "new york mets",
            "NY Mets",
            "Dallas Cowboys",
            "dallas cowboys",
        ]
        let result = FuzzyProcess.dedupe(items, threshold: 70)
        #expect(result.count < items.count)
        #expect(result.count >= 1)
    }

    @Test("dedupe with empty array")
    func dedupeEmpty() {
        #expect(FuzzyProcess.dedupe([]).isEmpty)
    }

    @Test("dedupe preserves unique strings")
    func dedupeUnique() {
        let items = ["apple", "banana", "cherry"]
        let result = FuzzyProcess.dedupe(items, threshold: 90)
        #expect(result.count == 3)
    }

    @Test("dedupe keeps longest string from each group")
    func dedupeKeepsLongest() {
        let items = [
            "NY Mets",
            "New York Mets",
        ]
        let result = FuzzyProcess.dedupe(items, threshold: 60)
        #expect(result.count == 1)
        #expect(result[0] == "New York Mets")
    }

    @Test("dedupe preserves original order of kept items")
    func dedupeOrder() {
        let items = [
            "Dallas Cowboys",
            "dallas cowboys football",
            "New York Giants",
        ]
        let result = FuzzyProcess.dedupe(items, threshold: 70)
        // Should keep "dallas cowboys football" (longer) and "New York Giants"
        // Indices of kept items should be in ascending order
        for i in 1..<result.count {
            let idx1 = items.firstIndex(of: result[i - 1])!
            let idx2 = items.firstIndex(of: result[i])!
            #expect(idx1 < idx2)
        }
    }
}
