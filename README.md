# Awesome-swift-types
A list of awesome value types in Swift, for a more type safe code

For motivation check and some explanation on why this might be useful, check: [Bringing runtime errors to compile time (in Swift with Types)](https://medium.com/@gonzula/bringing-runtime-errors-to-compile-time-in-swift-with-types-74f8c87bd13d)

This repo contains some cool types. Some of them are a specialization from the `generic` type [`ValidatedString`](https://github.com/gonzula/Awesome-swift-types/blob/master/ValidatedString.swift).

### Some usage examples of ValidatedString:

Let's assume your model contains an `User` with a username and a [SSN](https://en.wikipedia.org/wiki/Social_Security_number):

```Swift
struct User {
    let username: String
    let ssn: String
}
```

That's not type safe, so let's do better with `ValidatedString<Validator>`

With very little code you create very safe data types with a lot of cool features

```Swift
// First, let's create a username validator
typealias Username = ValidatedString<UsernameValidator>
enum UsernameValidator: StringValidator {
    /// Accepts any username with length between 3 and 10 inclusive
    static func validate(_ string: String) -> String? {
        let username = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (3...10).contains(username.count) else {return nil}
        return username
    }
}

// and a SSN validator
typealias SSN = ValidatedString<SSNValidator>
enum SSNValidator: StringValidator {
    /// Accepts ssn with or without the dash, but it always stores without the dashes
    static func validate(_ string: String) -> String? {
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = #"\d{3}-?\d{2}-?\d{4}"#
        guard NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: string) else {return nil}
        return string.replacingOccurrences(of: "-", with: "")
    }
}
```

And change our model to use those new types

```Swift
struct User {
    let username: Username
    let ssn: SSN
}
```

## The features you get for free

### Convertible from string literals:

```Swift
let usernames: [Username] = [
    "Gonzula",
    "jgcmarins"
]
let ssn: SSN = "078-05-1120"

let user = User(username: "gonzula", ssn: "078051120")
```

### Or init from expressions, resulting in a optional

```Swift
let userInput = "Gonzula"
let optionalUsername1 = Username(userInput)  //  Optional("Gonzula")

let invalidUserInput = "InvalidUserInputBucauseItsVeryBig"
let optionalUsername2 = Username(invalidUserInput)  // nil
```

### LosslessStringConvertible/CustomStringConvertible

```Swift
let username: Username = "Gonzula"

let convertedToString = String(username)  // Gonzula
print("The username is \(username)")  // The username is Gonzula
```

### Codable support

```Swift
extension User: Codable {}

let json = """
{
    "username": "Gonzula",
    "ssn": "078051120"
}
""".data(using: .utf8)!

let decoder = JSONDecoder()
let decodedUser = try! decoder.decode(User.self, from: json)

let encoder = JSONEncoder()
let encodedJson = try! encoder.encode(decodedUser)
String(data: encodedJson, encoding: .utf8)!  // {"ssn":"078051120","username":"Gonzula"}
```

### Custom hashables and comparisons
Useful for case insensitive comparison, but still preserving input's original case

```Swift
extension UsernameValidator: StringNormalizer, StringComparator{
    static func normalize(_ rawValue: String) -> String {
        return rawValue.lowercased()
    }

    static func areInIncreasingOrder(_ lhs: String, _ rhs: String) -> Bool {
        return normalize(lhs).localizedCaseInsensitiveCompare(normalize(rhs)) == .orderedAscending
    }
}

let scores: [Username: Int] = ["Foo": 10, "Bar": 5]
scores["FOO"]  // 10
scores["bar"]  // 5
let players: [Username] = ["Foo", "bar"].sorted()  // [bar, Foo]
// while a simple string sorting will result in a different order
let stringPlayers: [String] = ["Foo", "bar"].sorted()  // [Foo, bar]
```

### Custom computed properties, useful for human printable formats

```Swift
extension SSN {
    var formatted: String {
        let digits = Array(rawValue)
        // Don't have to worry about out of range index because the data was already validated
        let groups = [digits[0..<3], digits[3..<5], digits[5..<9]]
        let formatted = groups.joined(separator: "-")
        return String(formatted)
    }
}

let ssnNumber = "078051120"
SSN(ssnNumber)?.formatted  // 078-05-1120
```
