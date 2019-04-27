import Foundation

public typealias CPF = ValidatedString<CPFValidator>

public enum CPFValidator: StringValidator {
    public static func validate(_ string: String) -> String? {
        let digits = string.filteringDigits
        guard digits.count == 11 else {return nil}
        guard CPFValidator.isValid(digits) else {return nil}

        return digits
    }

    private static func isValid(_ cpf: String) -> Bool {
        let numbers = cpf.compactMap({ Int(String($0)) })
        guard numbers.count == 11 && Set(numbers).count != 1 else { return false }
        let dv1 = calculateDigit(numbers.prefix(9))
        let dv2 = calculateDigit(numbers.prefix(10))
        return dv1 == numbers[9] && dv2 == numbers[10]
    }

    static func calculateDigit<T: Collection>(_ digits: T) -> Int where T.Element == Int {
        var number = digits.count + 2
        let digit = 11 - digits.reduce(into: 0) {
            number -= 1
            $0 += $1 * number
            } % 11
        return digit > 9 ? 0 : digit
    }
}

public extension CPF {
    /// Creates a random valid CPF
    static func random() -> CPF {
        let digits = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        var chosenDigits = (0..<9).compactMap { _ in digits.randomElement() }
        let dv1 = CPFValidator.calculateDigit(chosenDigits)
        chosenDigits.append(dv1)
        let dv2 = CPFValidator.calculateDigit(chosenDigits)
        chosenDigits.append(dv2)

        return CPF(chosenDigits.map(String.init).joined())!
    }

    /// Returns the a string in the format: xxx-xxx-xxx.xx
    var formatted: String {
        let fmt = try? NSRegularExpression(pattern: #"(\d{3})(\d{3})(\d{3})(\d{2})"#, options: .caseInsensitive)
        let str = NSMutableString(string: rawValue)
        fmt?.replaceMatches(
            in: str,
            options: [],
            range: NSRange(location: 0, length: str.length),
            withTemplate: "$1.$2.$3-$4")
        return str as String
    }
}
