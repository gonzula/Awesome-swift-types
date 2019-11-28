/// Non Empty Trimmed String
public typealias NETString = ValidatedString<NETStringValidator>

public enum NETStringValidator: StringValidator, StringComparator {
    public static func validate(_ string: String) -> String? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {return nil}

        return trimmed
    }

    public static func areInIncreasingOrder(_ lhs: String, _ rhs: String) -> Bool {
        return lhs < rhs
    }
}
