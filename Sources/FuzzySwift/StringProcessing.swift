public enum StringProcessing {

    /// Preprocesses a string for fuzzy matching: lowercases, removes non-alphanumeric
    /// characters (except spaces), collapses whitespace, and trims.
    public static func fullProcess(_ string: String) -> String {
        let lowered = string.lowercased()
        var result: [Character] = []
        var lastWasSpace = false

        for char in lowered {
            if char.isLetter || char.isNumber {
                result.append(char)
                lastWasSpace = false
            } else if char.isWhitespace {
                if !lastWasSpace && !result.isEmpty {
                    result.append(" ")
                    lastWasSpace = true
                }
            }
        }

        // Trim trailing space
        if result.last == " " {
            result.removeLast()
        }

        return String(result)
    }
}
