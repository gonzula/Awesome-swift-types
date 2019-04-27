public typealias Email = ValidatedString<EmailValidator>

public enum EmailValidator: StringValidator, StringNormalizer {
    public static func validate(_ email: String) -> String? {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        guard email.matches(emailRegex) else {return nil}

        return email
    }

    public static func normalize(_ rawValue: String) -> String {
        return rawValue.lowercased()
    }
}
