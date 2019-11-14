import Foundation

typealias AppVersion = ValidatedString<AppVersionValidator>

enum AppVersionValidator: StringValidator, StringComparator {
    static func validate(_ string: String) -> String? {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        var charset = CharacterSet.decimalDigits
        charset.insert(".")
        let filtered = string.components(separatedBy: charset.inverted).joined()
        guard filtered == string else {return nil}

        return filtered
    }

    static func areInIncreasingOrder(_ lhs: String, _ rhs: String) -> Bool {
        let leftComponents = lhs.components(separatedBy: ".")
        let rightComponents = rhs.components(separatedBy: ".")

        for (leftSubversion, rightSubversion) in zip(leftComponents, rightComponents) {
            if leftSubversion != rightSubversion {
                return Int(leftSubversion)! < Int(rightSubversion)!
            }
        }

        return leftComponents.count < rightComponents.count
    }
}

extension AppVersion {
    static var current: AppVersion {
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        return AppVersion(currentVersion)!
    }
}
