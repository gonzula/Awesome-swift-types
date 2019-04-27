import Foundation

public extension StringProtocol {
    /// Returns a string containing only the digits (0 - 9)
    var filteringDigits: String {
        return String(self).components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }

    /// Returns true if self matches the regex
    func matches(_ regex: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
}
