/// Implements the Ratcliff/Obershelp pattern matching algorithm,
/// equivalent to Python's `difflib.SequenceMatcher`.
public struct SequenceMatcher: Sendable {

    public struct MatchingBlock: Sendable, Equatable {
        /// Start index in the first sequence.
        public let i: Int
        /// Start index in the second sequence.
        public let j: Int
        /// Length of the matching block.
        public let size: Int
    }

    private let a: [Character]
    private let b: [Character]
    /// Map from each character in `b` to its sorted list of indices.
    private let b2j: [Character: [Int]]

    public init(_ s1: String, _ s2: String) {
        self.a = Array(s1)
        self.b = Array(s2)

        var map: [Character: [Int]] = [:]
        for (index, char) in self.b.enumerated() {
            map[char, default: []].append(index)
        }
        self.b2j = map
    }

    /// Returns all non-overlapping matching blocks as `(i, j, size)` triples,
    /// sorted by position, with a sentinel `(a.count, b.count, 0)` at the end.
    public func matchingBlocks() -> [MatchingBlock] {
        var blocks: [MatchingBlock] = []
        findMatchingBlocks(aLo: 0, aHi: a.count, bLo: 0, bHi: b.count, into: &blocks)
        blocks.sort { ($0.i, $0.j) < ($1.i, $1.j) }

        // Collapse adjacent blocks
        var collapsed: [MatchingBlock] = []
        var ci = 0, cj = 0, cSize = 0

        for block in blocks {
            if ci + cSize == block.i && cj + cSize == block.j {
                cSize += block.size
            } else {
                if cSize > 0 {
                    collapsed.append(MatchingBlock(i: ci, j: cj, size: cSize))
                }
                ci = block.i
                cj = block.j
                cSize = block.size
            }
        }
        if cSize > 0 {
            collapsed.append(MatchingBlock(i: ci, j: cj, size: cSize))
        }

        // Sentinel
        collapsed.append(MatchingBlock(i: a.count, j: b.count, size: 0))
        return collapsed
    }

    /// Returns the similarity ratio in `[0.0, 1.0]`.
    /// Formula: `2.0 * matchingCharacters / totalCharacters`.
    public func ratio() -> Double {
        let total = a.count + b.count
        guard total > 0 else { return 0.0 }

        let matches = matchingBlocks().reduce(0) { $0 + $1.size }
        return 2.0 * Double(matches) / Double(total)
    }

    // MARK: - Private

    /// Finds the longest matching block in `a[aLo..<aHi]` vs `b[bLo..<bHi]`.
    private func findLongestMatch(aLo: Int, aHi: Int, bLo: Int, bHi: Int) -> MatchingBlock {
        var bestI = aLo, bestJ = bLo, bestSize = 0

        // j2len maps `j` to the length of the longest match ending at `a[i-1]` and `b[j-1]`.
        var j2len: [Int: Int] = [:]

        for i in aLo..<aHi {
            var newJ2Len: [Int: Int] = [:]
            if let indices = b2j[a[i]] {
                for j in indices {
                    guard j >= bLo && j < bHi else { continue }
                    let k = (j2len[j - 1] ?? 0) + 1
                    newJ2Len[j] = k
                    if k > bestSize {
                        bestI = i - k + 1
                        bestJ = j - k + 1
                        bestSize = k
                    }
                }
            }
            j2len = newJ2Len
        }

        return MatchingBlock(i: bestI, j: bestJ, size: bestSize)
    }

    /// Recursively finds all matching blocks and appends them to `blocks`.
    private func findMatchingBlocks(
        aLo: Int, aHi: Int, bLo: Int, bHi: Int,
        into blocks: inout [MatchingBlock]
    ) {
        let match = findLongestMatch(aLo: aLo, aHi: aHi, bLo: bLo, bHi: bHi)
        guard match.size > 0 else { return }

        if aLo < match.i && bLo < match.j {
            findMatchingBlocks(aLo: aLo, aHi: match.i, bLo: bLo, bHi: match.j, into: &blocks)
        }
        blocks.append(match)
        if match.i + match.size < aHi && match.j + match.size < bHi {
            findMatchingBlocks(
                aLo: match.i + match.size, aHi: aHi,
                bLo: match.j + match.size, bHi: bHi,
                into: &blocks
            )
        }
    }
}
