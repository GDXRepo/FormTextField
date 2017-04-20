import Foundation
import Validation

public struct DecimalInputValidator: InputValidatable {
    public var validation: Validation?

    public init(validation: Validation? = nil) {
        self.validation = validation
    }

    public func validateReplacementString(_ replacementString: String?, fullString: String?, inRange range: NSRange?) -> Bool {
        var valid = true
        if let validation = self.validation {
            let evaluatedString = self.composedString(replacementString, fullString: fullString, inRange: range)
            valid = validation.validateString(evaluatedString, complete: false)
        }

        if valid {
            let composedString = self.composedString(replacementString, fullString: fullString, inRange: range)
            if composedString.characters.count > 0 {
                let stringSet = CharacterSet(charactersIn: composedString)
                var floatSet = CharacterSet.decimalDigits
                floatSet.insert(charactersIn: ".,")
                let hasValidElements = floatSet.superSetOf(other: stringSet)
                if hasValidElements {
                    let firstElementSet = CharacterSet(charactersIn: String(composedString.characters.first!))
                    let integerSet = CharacterSet.decimalDigits
                    let firstCharacterIsNumber = integerSet.isSuperset(of: firstElementSet)
                    if firstCharacterIsNumber {
                        if replacementString == nil {
                            let lastElementSet = CharacterSet(charactersIn: String(composedString.characters.last!))
                            let lastCharacterIsInvalid = !integerSet.isSuperset(of: lastElementSet)
                            if lastCharacterIsInvalid {
                                valid = false
                            }
                        }

                        if valid {
                            let elementsSeparatedByDot = composedString.components(separatedBy: ".")
                            let elementsSeparatedByComma = composedString.components(separatedBy: ",")
                            if elementsSeparatedByDot.count >= 2 && elementsSeparatedByComma.count >= 2 {
                                valid = false
                            } else if elementsSeparatedByDot.count > 2 || elementsSeparatedByComma.count > 2 {
                                valid = false
                            }
                        }
                    } else {
                        valid = false
                    }
                } else {
                    valid = false
                }
            }
        }

        return valid
    }
}

extension CharacterSet {
    // Workaround for crash in Swift:
    // https://github.com/apple/swift/pull/4162
    func superSetOf(other: CharacterSet) -> Bool {
        return CFCharacterSetIsSupersetOfSet(self as CFCharacterSet, (other as NSCharacterSet).copy() as! CFCharacterSet)
    }
}