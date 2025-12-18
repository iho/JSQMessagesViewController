import UIKit

/// A `JSQMessagesCollectionViewFlowLayoutInvalidationContext` object specifies properties for
/// determining whether to recompute the size of items or their position in the layout.
/// The flow layout object creates instances of this class when it needs to invalidate its contents
/// in response to changes. You can also create instances when invalidating the flow layout manually.
@objc
public class JSQMessagesCollectionViewFlowLayoutInvalidationContext:
    UICollectionViewFlowLayoutInvalidationContext
{

    /**
     *  A boolean indicating whether to empty the messages layout information cache for items and views in the layout.
     *  The default value is `false`.
     */
    @objc public var invalidateFlowLayoutMessagesCache: Bool = false

    /**
     *  Creates and returns a new `JSQMessagesCollectionViewFlowLayoutInvalidationContext` object.
     *
     *  - Discussion: When you need to invalidate the `JSQMessagesCollectionViewFlowLayout` object for your
     *  `JSQMessagesViewController` subclass, you should use this method to instantiate a new invalidation
     *  context and pass this object to `invalidateLayoutWithContext:`.
     *
     *  - returns: An initialized invalidation context object.
     */
    @objc public static func context() -> JSQMessagesCollectionViewFlowLayoutInvalidationContext {
        let context = JSQMessagesCollectionViewFlowLayoutInvalidationContext()
        context.invalidateFlowLayoutDelegateMetrics = true
        context.invalidateFlowLayoutAttributes = true
        return context
    }

    public override var description: String {
        return
            "<\(type(of: self)): invalidateFlowLayoutDelegateMetrics=\(invalidateFlowLayoutDelegateMetrics), invalidateFlowLayoutAttributes=\(invalidateFlowLayoutAttributes), invalidateDataSourceCounts=\(invalidateDataSourceCounts), invalidateFlowLayoutMessagesCache=\(invalidateFlowLayoutMessagesCache)>"
    }
}
