import UIKit

extension Bundle {

    /**
     *  - Returns: The bundle for JSQMessagesViewController.
     */
    @objc public static func jsq_messages() -> Bundle? {
        // Return the bundle where JSQMessagesViewController class is located.
        // Since we are rewriting, and JSQMessagesViewController might be Swift or ObjC depending on the phase,
        // we assume the main class is reachable.
        // Assuming JSQMessagesViewController is the class name.
        return Bundle(for: JSQMessagesViewController.self)
    }

    /**
     *  - Returns: The bundle for assets in JSQMessagesViewController.
     */
    @objc public static func jsq_messagesAsset() -> Bundle? {
        guard let bundle = Bundle.jsq_messages(),
            let bundleResourcePath = bundle.resourcePath
        else { return nil }

        let assetPath = (bundleResourcePath as NSString).appendingPathComponent(
            "JSQMessagesAssets.bundle")
        return Bundle(path: assetPath)
    }

    /**
     *  Returns a localized version of the string designated by the specified key and residing in the JSQMessages table.
     *
     *  - parameter key: The key for a string in the JSQMessages table.
     *
     *  - returns: A localized version of the string designated by key in the JSQMessages table.
     */
    @objc public static func jsq_localizedString(forKey key: String) -> String {
        return NSLocalizedString(
            key, tableName: "Chat X.509", bundle: Bundle.jsq_messagesAsset() ?? Bundle.main,
            comment: "")
    }

}
