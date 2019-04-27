typealias BRLicensePlate = ValidatedString<BRLicensePlateValidator>
enum BRLicensePlateValidator: StringValidator {
    static func validate(_ string: String) -> String? {
        let plate = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard plate.matches(#"[a-zA-Z]{3}[- ]?\d{4}"#) else {return nil}
        return plate
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .uppercased()
    }
}

extension BRLicensePlate {
    var formatted: String {
        let chars = Array(rawValue)
        let groups = [chars[0..<3], chars[3..<7]]
        let formatted = groups.joined(separator: "-")
        return String(formatted)
    }
}
