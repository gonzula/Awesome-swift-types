import Foundation

public protocol StringValidator {
    /// Returns a sanitized string if the input is valid or nil otherwise
    static func validate(_ string: String) -> String?
}

public protocol StringNormalizer {
    /// Returns a normalized version of `rawValue`
    static func normalize(_ rawValue: String) -> String
}

public protocol StringComparator {
    static func areInIncreasingOrder(_ lhs: String, _ rhs: String) -> Bool
}

public struct ValidatedString<Validator: StringValidator> {

    public let rawValue: String

    var normalized: String {
        if let normalizer = Validator.self as? StringNormalizer.Type {
            return normalizer.normalize(rawValue)
        } else {
            return rawValue
        }
    }

    public init?(_ rawValue: String) {
        guard let validated = Validator.validate(rawValue) else {return nil}
        self.rawValue = validated
    }
}

extension ValidatedString: CustomStringConvertible,
                           CustomDebugStringConvertible,
                           LosslessStringConvertible {
    public var description: String {return rawValue}
    public var debugDescription: String {return #"<ValidatedString<\#(Validator.self)>, "\#(rawValue)">"#}
}

extension ValidatedString: Hashable {
    public static func == (lhs: ValidatedString<Validator>, rhs: ValidatedString<Validator>) -> Bool {
        return  lhs.normalized == rhs.normalized
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(normalized)
    }
}

extension ValidatedString: Comparable where Validator: StringComparator {
    public static func < (lhs: ValidatedString<Validator>, rhs: ValidatedString<Validator>) -> Bool {
        return Validator.areInIncreasingOrder(lhs.rawValue, rhs.rawValue)
    }
}

extension ValidatedString: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public init(stringLiteral value: StringLiteralType) {
        guard let validated = ValidatedString.init(value) else {
            fatalError(#"Invalid string literal "\#(value)" for validator \#(Validator.self)"#)
        }
        self = validated
    }
}

extension ValidatedString: Codable {
    enum Error: Swift.Error {
        case validation
    }

    public init(from decoder: Decoder) throws {
        let decoded = try decoder.singleValueContainer().decode(String.self)
        guard let validated = ValidatedString<Validator>(decoded) else {throw Error.validation}
        self = validated
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
