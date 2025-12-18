import Foundation

extension String {

    /**
     *  Returns a copy of the receiver with all leading and trailing whitespace removed.
     *
     *  - returns: A copy of the receiver with all leading and trailing whitespace removed.
     */
    public func jsq_stringByTrimingWhitespace() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
