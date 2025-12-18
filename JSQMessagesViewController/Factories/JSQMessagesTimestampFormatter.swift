import UIKit

/// An instance of `JSQMessagesTimestampFormatter` is a singleton object that provides an efficient means
/// for creating attributed and non-attributed string representations of `NSDate` objects.
/// It is intended to be used as the method by which you display timestamps in a `JSQMessagesCollectionView`.
@objc public class JSQMessagesTimestampFormatter: NSObject {

    /**
     *  Returns the shared timestamp formatter object.
     */
    @objc public static let sharedFormatter = JSQMessagesTimestampFormatter()

    /**
     *  Returns the cached date formatter object used by the `JSQMessagesTimestampFormatter` shared instance.
     */
    @objc public let dateFormatter: DateFormatter

    /**
     *  The text attributes to apply to the day, month, and year components of the string representation of a given date.
     *  The default value is a dictionary containing attributes that specify centered, light gray text and `UIFontTextStyleBody` font.
     */
    @objc public var dateTextAttributes: [NSAttributedString.Key: Any]

    /**
     *  The text attributes to apply to the minute and hour componenents of the string representation of a given date.
     *  The default value is a dictionary containing attributes that specify centered, light gray text and `UIFontTextStyleBody` font.
     */
    @objc public var timeTextAttributes: [NSAttributedString.Key: Any]

    @objc private override init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.locale = Locale.current
        self.dateFormatter.doesRelativeDateFormatting = true

        let color = UIColor.lightGray
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineHeightMultiple = 0.8

        self.dateTextAttributes = [.paragraphStyle: paragraphStyle]
        self.timeTextAttributes = [.foregroundColor: color, .paragraphStyle: paragraphStyle]

        super.init()
    }

    /**
     *  Returns a string representation of the given date formatted in the current locale using `NSDateFormatterMediumStyle` for the date style
     *  and `NSDateFormatterShortStyle` for the time style. It uses relative date formatting where possible.
     *
     *  - parameter date: The date to format.
     *
     *  - returns: A formatted string representation of date.
     */
    @objc public func timestamp(for date: Date?) -> String? {
        guard let date = date else { return nil }

        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .short
        return self.dateFormatter.string(from: date)
    }

    /**
     *  Returns an attributed string representation of the given date formatted as described in `timestampForDate:`.
     *  It applies the attributes in `dateTextAttributes` and `timeTextAttributes`, respectively.
     *
     *  - parameter date: The date to format.
     *
     *  - returns: A formatted, attributed string representation of date.
     */
    @objc public func attributedTimestamp(for date: Date?) -> NSAttributedString? {
        guard let date = date else { return nil }

        guard let relativeDate = self.relativeDate(for: date),
            let time = self.time(for: date)
        else { return nil }

        let timestamp = NSMutableAttributedString(
            string: relativeDate, attributes: self.dateTextAttributes)
        timestamp.append(NSAttributedString(string: " "))
        timestamp.append(NSAttributedString(string: time, attributes: self.timeTextAttributes))

        return NSAttributedString(attributedString: timestamp)
    }

    /**
     *  Returns a string representation of *only* the minute and hour components of the given date formatted in the current locale styled using `NSDateFormatterShortStyle`.
     *
     *  - parameter date: The date to format.
     *
     *  - returns: A formatted string representation of the minute and hour components of date.
     */
    @objc public func time(for date: Date?) -> String? {
        guard let date = date else { return nil }

        self.dateFormatter.dateStyle = .none
        self.dateFormatter.timeStyle = .short
        return self.dateFormatter.string(from: date)
    }

    /**
     *  Returns a string representation of *only* the day, month, and year components of the given date formatted in the current locale styled using `NSDateFormatterMediumStyle`.
     *
     *  - parameter date: The date to format.
     *
     *  - returns: A formatted string representation of the day, month, and year components of date.
     */
    @objc public func relativeDate(for date: Date?) -> String? {
        guard let date = date else { return nil }

        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .none
        return self.dateFormatter.string(from: date)
    }
}
