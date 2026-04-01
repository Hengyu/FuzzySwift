import Testing
@testable import FuzzySwift

@Suite("StringProcessing Tests")
struct StringProcessingTests {

    @Test("Lowercases input")
    func lowercasing() {
        #expect(StringProcessing.fullProcess("HELLO WORLD") == "hello world")
    }

    @Test("Strips punctuation")
    func stripsPunctuation() {
        #expect(StringProcessing.fullProcess("hello, world!") == "hello world")
        #expect(StringProcessing.fullProcess("test@#$%string") == "teststring")
    }

    @Test("Collapses whitespace")
    func collapsesWhitespace() {
        #expect(StringProcessing.fullProcess("hello   world") == "hello world")
        #expect(StringProcessing.fullProcess("  hello  world  ") == "hello world")
    }

    @Test("Trims whitespace")
    func trimsWhitespace() {
        #expect(StringProcessing.fullProcess("  hello  ") == "hello")
    }

    @Test("Empty string")
    func emptyString() {
        #expect(StringProcessing.fullProcess("") == "")
    }

    @Test("Only punctuation produces empty string")
    func onlyPunctuation() {
        #expect(StringProcessing.fullProcess("!@#$%") == "")
    }

    @Test("Preserves Unicode letters")
    func unicodeLetters() {
        #expect(StringProcessing.fullProcess("café") == "café")
        #expect(StringProcessing.fullProcess("日本語") == "日本語")
    }

    @Test("Numbers are preserved")
    func numbers() {
        #expect(StringProcessing.fullProcess("test123") == "test123")
        #expect(StringProcessing.fullProcess("1 2 3") == "1 2 3")
    }

    @Test("Tabs and newlines treated as whitespace")
    func tabsAndNewlines() {
        #expect(StringProcessing.fullProcess("hello\tworld\nfoo") == "hello world foo")
    }
}
