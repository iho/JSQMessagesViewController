import UIKit

public let kJSQMessagesCollectionViewCellLabelHeightDefault: CGFloat = 20.0
public let kJSQMessagesCollectionViewAvatarSizeDefault: CGFloat = 30.0

/// The `JSQMessagesCollectionViewFlowLayout` is a concrete layout object that inherits
/// from `UICollectionViewFlowLayout` and organizes message items in a vertical list.
/// Each `JSQMessagesCollectionViewCell` in the layout can display messages of arbitrary sizes and avatar images,
/// as well as metadata such as a timestamp and sender.
/// You can easily customize the layout via its properties or its delegate methods
/// defined in `JSQMessagesCollectionViewDelegateFlowLayout`.
@objc public class JSQMessagesCollectionViewFlowLayout: UICollectionViewFlowLayout {

    /**
     *  The collection view object currently using this layout object.
     */
    // NOTE: This property is dynamic in ObjC implementation, mirroring the superclass property but with specific type.
    // In Swift, we cast self.collectionView to JSQMessagesCollectionView where needed.
    // However, to maintain API compatibility, we can add a computed property if needed, but standard collectionView is usually sufficient.
    @objc public var messagesCollectionView: JSQMessagesCollectionView? {
        return self.collectionView as? JSQMessagesCollectionView
    }

    /**
     *  The object that the layout uses to calculate bubble sizes.
     *  The default value is an instance of `JSQMessagesBubblesSizeCalculator`.
     */
    @objc public var bubbleSizeCalculator: JSQMessagesBubbleSizeCalculating

    /**
     *  Specifies whether or not the layout should enable spring behavior dynamics for its items using `UIDynamics`.
     *
     *  - Discussion: The default value is `NO`, which disables "springy" or "bouncy" items in the layout.
     *  Set to `YES` if you want items to have spring behavior dynamics. You *must* set this property from `viewDidAppear:`
     *  in your `JSQMessagesViewController` subclass.
     */
    @objc public var springinessEnabled: Bool = false {
        didSet {
            if oldValue == springinessEnabled { return }

            if !springinessEnabled {
                dynamicAnimator.removeAllBehaviors()
                visibleIndexPaths.removeAllObjects()
            }
            invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext.context())
        }
    }

    /**
     *  Specifies the degree of resistence for the "springiness" of items in the layout.
     *  This property has no effect if `springinessEnabled` is set to `NO`.
     *
     *  - Discussion: The default value is `1000`. Increasing this value increases the resistance, that is, items become less "bouncy".
     *  Decrease this value in order to make items more "bouncy".
     */
    @objc public var springResistanceFactor: UInt = 1000

    /**
     *  Returns the width of items in the layout.
     */
    @objc public var itemWidth: CGFloat {
        guard let collectionView = self.collectionView else { return 0.0 }
        return collectionView.frame.width - self.sectionInset.left - self.sectionInset.right
    }

    /**
     *  The font used to display the body a text message in the message bubble of each
     *  `JSQMessagesCollectionViewCell` in the collectionView.
     *
     *  - Discussion: The default value is the preferred system font for `UIFontTextStyleBody`. This value must not be `nil`.
     */
    @objc public var messageBubbleFont: UIFont = .preferredFont(forTextStyle: .body) {
        didSet {
            if oldValue == messageBubbleFont { return }
            invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext.context())
        }
    }

    /**
     *  The horizontal spacing used to lay out the `messageBubbleContainerView` frame within each `JSQMessagesCollectionViewCell`.
     */
    @objc public var messageBubbleLeftRightMargin: CGFloat = 40.0 {
        didSet {
            messageBubbleLeftRightMargin = ceil(messageBubbleLeftRightMargin)
            invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext.context())
        }
    }

    /**
     *  The inset of the frame of the text view within the `messageBubbleContainerView` of each `JSQMessagesCollectionViewCell`.
     */
    @objc public var messageBubbleTextViewFrameInsets: UIEdgeInsets = UIEdgeInsets(
        top: 0.0, left: 0.0, bottom: 0.0, right: 6.0)
    {
        didSet {
            if oldValue == messageBubbleTextViewFrameInsets { return }
            invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext.context())
        }
    }

    /**
     *  The inset of the text container's layout area within the text view's content area in each `JSQMessagesCollectionViewCell`.
     */
    @objc public var messageBubbleTextViewTextContainerInsets: UIEdgeInsets = UIEdgeInsets(
        top: 7.0, left: 14.0, bottom: 7.0, right: 14.0)
    {
        didSet {
            if oldValue == messageBubbleTextViewTextContainerInsets { return }
            invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext.context())
        }
    }

    /**
     *  The size of the avatar image view for incoming messages.
     */
    @objc public var incomingAvatarViewSize: CGSize = CGSize(
        width: kJSQMessagesCollectionViewAvatarSizeDefault,
        height: kJSQMessagesCollectionViewAvatarSizeDefault)
    {
        didSet {
            if oldValue == incomingAvatarViewSize { return }
            invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext.context())
        }
    }

    /**
     *  The size of the avatar image view for outgoing messages.
     */
    @objc public var outgoingAvatarViewSize: CGSize = CGSize(
        width: kJSQMessagesCollectionViewAvatarSizeDefault,
        height: kJSQMessagesCollectionViewAvatarSizeDefault)
    {
        didSet {
            if oldValue == outgoingAvatarViewSize { return }
            invalidateLayout(with: JSQMessagesCollectionViewFlowLayoutInvalidationContext.context())
        }
    }

    /**
     *  The maximum number of items that the layout should keep in its cache of layout information.
     */
    @objc public var cacheLimit: UInt = 200

    private lazy var dynamicAnimator: UIDynamicAnimator = {
        return UIDynamicAnimator(collectionViewLayout: self)
    }()

    private lazy var visibleIndexPaths: NSMutableSet = {
        return NSMutableSet()
    }()

    private var latestDelta: CGFloat = 0.0

    @objc public override init() {
        self.bubbleSizeCalculator = JSQMessagesBubblesSizeCalculator()
        super.init()
        self.jsq_configureFlowLayout()
    }

    @objc public required init?(coder aDecoder: NSCoder) {
        self.bubbleSizeCalculator = JSQMessagesBubblesSizeCalculator()
        super.init(coder: aDecoder)
        self.jsq_configureFlowLayout()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func jsq_configureFlowLayout() {
        self.scrollDirection = .vertical
        self.sectionInset = UIEdgeInsets(top: 10.0, left: 4.0, bottom: 10.0, right: 4.0)
        self.minimumLineSpacing = 4.0

        self.messageBubbleFont = .preferredFont(forTextStyle: .body)

        if UIDevice.current.userInterfaceIdiom == .pad {
            self.messageBubbleLeftRightMargin = 240.0
        } else {
            self.messageBubbleLeftRightMargin = 50.0
        }

        self.messageBubbleTextViewFrameInsets = UIEdgeInsets(
            top: 0.0, left: 0.0, bottom: 0.0, right: 6.0)
        self.messageBubbleTextViewTextContainerInsets = UIEdgeInsets(
            top: 7.0, left: 14.0, bottom: 7.0, right: 14.0)

        let defaultAvatarSize = CGSize(
            width: kJSQMessagesCollectionViewAvatarSizeDefault,
            height: kJSQMessagesCollectionViewAvatarSizeDefault)
        self.incomingAvatarViewSize = defaultAvatarSize
        self.outgoingAvatarViewSize = defaultAvatarSize

        self.springinessEnabled = true
        self.springResistanceFactor = 1400

        NotificationCenter.default.addObserver(
            self, selector: #selector(jsq_didReceiveApplicationMemoryWarningNotification(_:)),
            name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(jsq_didReceiveDeviceOrientationDidChangeNotification(_:)),
            name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc public override class var layoutAttributesClass: AnyClass {
        return JSQMessagesCollectionViewLayoutAttributes.self
    }

    @objc public override class var invalidationContextClass: AnyClass {
        return JSQMessagesCollectionViewFlowLayoutInvalidationContext.self
    }

    @objc private func jsq_didReceiveApplicationMemoryWarningNotification(
        _ notification: Notification
    ) {
        self.jsq_resetLayout()
    }

    @objc private func jsq_didReceiveDeviceOrientationDidChangeNotification(
        _ notification: Notification
    ) {
        self.jsq_resetLayout()
        self.invalidateLayout(
            with: JSQMessagesCollectionViewFlowLayoutInvalidationContext.context())
    }

    // MARK: - Collection view flow layout

    @objc public override func invalidateLayout(
        with context: UICollectionViewLayoutInvalidationContext
    ) {
        guard let context = context as? JSQMessagesCollectionViewFlowLayoutInvalidationContext
        else {
            super.invalidateLayout(with: context)
            return
        }

        if context.invalidateDataSourceCounts {
            context.invalidateFlowLayoutAttributes = true
            context.invalidateFlowLayoutDelegateMetrics = true
        }

        if context.invalidateFlowLayoutAttributes || context.invalidateFlowLayoutDelegateMetrics {
            self.jsq_resetDynamicAnimator()
        }

        if context.invalidateFlowLayoutMessagesCache {
            self.jsq_resetLayout()
        }

        super.invalidateLayout(with: context)
    }

    @objc public override func prepare() {
        super.prepare()

        if self.springinessEnabled {
            let padding: CGFloat = -100.0
            let visibleRect = self.collectionView?.bounds.insetBy(dx: padding, dy: padding) ?? .zero

            let visibleItems = super.layoutAttributesForElements(in: visibleRect) ?? []
            let visibleItemsIndexPaths = Set(visibleItems.map { $0.indexPath })

            self.jsq_removeNoLongerVisibleBehaviorsFromVisibleItemsIndexPaths(
                visibleItemsIndexPaths)
            self.jsq_addNewlyVisibleBehaviorsFromVisibleItems(visibleItems)
        }
    }

    @objc public override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]?
    {
        let attributesInRect =
            super.layoutAttributesForElements(in: rect)?.map {
                $0.copy() as! UICollectionViewLayoutAttributes
            } ?? []

        var finalAttributes = attributesInRect

        if self.springinessEnabled {
            var attributesInRectCopy = attributesInRect
            let dynamicAttributes =
                self.dynamicAnimator.items(in: rect) as? [UICollectionViewLayoutAttributes] ?? []

            for eachItem in attributesInRect {
                for eachDynamicItem in dynamicAttributes {
                    if eachItem.indexPath == eachDynamicItem.indexPath
                        && eachItem.representedElementCategory
                            == eachDynamicItem.representedElementCategory
                    {
                        if let index = attributesInRectCopy.firstIndex(of: eachItem) {
                            attributesInRectCopy.remove(at: index)
                            attributesInRectCopy.append(eachDynamicItem)
                        }
                    }
                }
            }
            finalAttributes = attributesInRectCopy
        }

        for attributesItem in finalAttributes {
            if attributesItem.representedElementCategory == .cell {
                self.jsq_configureMessageCellLayoutAttributes(
                    attributesItem as! JSQMessagesCollectionViewLayoutAttributes)
            } else {
                attributesItem.zIndex = -1
            }
        }

        return finalAttributes
    }

    @objc public override func layoutAttributesForItem(at indexPath: IndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        let customAttributes =
            super.layoutAttributesForItem(at: indexPath)?.copy()
            as! JSQMessagesCollectionViewLayoutAttributes

        if customAttributes.representedElementCategory == .cell {
            self.jsq_configureMessageCellLayoutAttributes(customAttributes)
        }

        return customAttributes
    }

    @objc public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if self.springinessEnabled {
            let scrollView = self.collectionView!
            let delta = newBounds.origin.y - scrollView.bounds.origin.y

            self.latestDelta = delta - 4.0

            let touchLocation =
                self.collectionView?.panGestureRecognizer.location(in: self.collectionView) ?? .zero

            for behavior in self.dynamicAnimator.behaviors {
                if let springBehavior = behavior as? UIAttachmentBehavior {
                    self.jsq_adjustSpringBehavior(springBehavior, forTouchLocation: touchLocation)
                    self.dynamicAnimator.updateItem(usingCurrentState: springBehavior.items.first!)
                }
            }
        }

        let oldBounds = self.collectionView?.bounds ?? .zero
        if newBounds.width != oldBounds.width {
            return true
        }

        return false
    }

    @objc public override func prepare(
        forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]
    ) {
        super.prepare(forCollectionViewUpdates: updateItems)

        for updateItem in updateItems {
            if updateItem.updateAction == .insert {
                if self.springinessEnabled
                    && self.dynamicAnimator.layoutAttributesForCell(
                        at: updateItem.indexPathAfterUpdate!) != nil
                {
                    continue
                }

                let collectionViewHeight = self.collectionView?.bounds.height ?? 0.0

                let attributes = JSQMessagesCollectionViewLayoutAttributes(
                    forCellWith: updateItem.indexPathAfterUpdate!)

                if attributes.representedElementCategory == .cell {
                    self.jsq_configureMessageCellLayoutAttributes(attributes)
                }

                attributes.frame = CGRect(
                    x: 0.0,
                    y: collectionViewHeight + attributes.frame.height,
                    width: attributes.frame.width,
                    height: attributes.frame.height)

                if self.springinessEnabled {
                    if let springBehavior = self.jsq_springBehaviorWithLayoutAttributesItem(
                        attributes)
                    {
                        self.dynamicAnimator.addBehavior(springBehavior)
                    }
                }
            }
        }
    }

    // MARK: - Invalidation utilities

    @objc private func jsq_resetLayout() {
        self.bubbleSizeCalculator.prepareForResettingLayout(self)
        self.jsq_resetDynamicAnimator()
    }

    @objc private func jsq_resetDynamicAnimator() {
        if self.springinessEnabled {
            self.dynamicAnimator.removeAllBehaviors()
            self.visibleIndexPaths.removeAllObjects()
        }
    }

    // MARK: - Message cell layout utilities

    @objc public func messageBubbleSizeForItem(at indexPath: IndexPath) -> CGSize {
        guard
            let dataSource = self.collectionView?.dataSource as? JSQMessagesCollectionViewDataSource
        else { return .zero }

        let messageItem = dataSource.collectionView(
            self.collectionView as! JSQMessagesCollectionView, messageDataForItemAt: indexPath)

        return self.bubbleSizeCalculator.messageBubbleSize(
            for: messageItem, at: indexPath, with: self)
    }

    @objc public func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let messageBubbleSize = self.messageBubbleSizeForItem(at: indexPath)
        let attributes =
            self.layoutAttributesForItem(at: indexPath)
            as! JSQMessagesCollectionViewLayoutAttributes

        var finalHeight = messageBubbleSize.height
        finalHeight += attributes.cellTopLabelHeight
        finalHeight += attributes.messageBubbleTopLabelHeight
        finalHeight += attributes.cellBottomLabelHeight

        return CGSize(width: self.itemWidth, height: ceil(finalHeight))
    }

    @objc private func jsq_configureMessageCellLayoutAttributes(
        _ layoutAttributes: JSQMessagesCollectionViewLayoutAttributes
    ) {
        let indexPath = layoutAttributes.indexPath

        let messageBubbleSize = self.messageBubbleSizeForItem(at: indexPath)

        layoutAttributes.messageBubbleContainerViewWidth = messageBubbleSize.width
        layoutAttributes.textViewFrameInsets = self.messageBubbleTextViewFrameInsets
        layoutAttributes.textViewTextContainerInsets = self.messageBubbleTextViewTextContainerInsets
        layoutAttributes.messageBubbleFont = self.messageBubbleFont
        layoutAttributes.incomingAvatarViewSize = self.incomingAvatarViewSize
        layoutAttributes.outgoingAvatarViewSize = self.outgoingAvatarViewSize

        if let delegate = self.collectionView?.delegate
            as? JSQMessagesCollectionViewDelegateFlowLayout
        {
            layoutAttributes.cellTopLabelHeight =
                delegate.collectionView?(
                    self.collectionView as! JSQMessagesCollectionView, layout: self,
                    heightForCellTopLabelAt: indexPath) ?? 0.0
            layoutAttributes.messageBubbleTopLabelHeight =
                delegate.collectionView?(
                    self.collectionView as! JSQMessagesCollectionView, layout: self,
                    heightForMessageBubbleTopLabelAt: indexPath)
                ?? 0.0
            layoutAttributes.cellBottomLabelHeight =
                delegate.collectionView?(
                    self.collectionView as! JSQMessagesCollectionView, layout: self,
                    heightForCellBottomLabelAt: indexPath)
                ?? 0.0
        }
    }

    // MARK: - Spring behavior utilities

    @objc private func jsq_springBehaviorWithLayoutAttributesItem(
        _ item: UICollectionViewLayoutAttributes
    ) -> UIAttachmentBehavior? {
        if item.frame.size == .zero {
            return nil
        }

        let springBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: item.center)
        springBehavior.length = 1.0
        springBehavior.damping = 1.0
        springBehavior.frequency = 1.0
        return springBehavior
    }

    @objc private func jsq_addNewlyVisibleBehaviorsFromVisibleItems(
        _ visibleItems: [UICollectionViewLayoutAttributes]
    ) {
        let newlyVisibleItems = visibleItems.filter {
            !self.visibleIndexPaths.contains($0.indexPath)
        }

        let touchLocation =
            self.collectionView?.panGestureRecognizer.location(in: self.collectionView) ?? .zero

        for item in newlyVisibleItems {
            if let springBehavior = self.jsq_springBehaviorWithLayoutAttributesItem(item) {
                self.jsq_adjustSpringBehavior(springBehavior, forTouchLocation: touchLocation)
                self.dynamicAnimator.addBehavior(springBehavior)
                self.visibleIndexPaths.add(item.indexPath)
            }
        }
    }

    @objc private func jsq_removeNoLongerVisibleBehaviorsFromVisibleItemsIndexPaths(
        _ visibleItemsIndexPaths: Set<IndexPath>
    ) {
        let behaviors = self.dynamicAnimator.behaviors

        let behaviorsToRemove = behaviors.filter { behavior in
            if let springBehavior = behavior as? UIAttachmentBehavior,
                let item = springBehavior.items.first as? UICollectionViewLayoutAttributes
            {
                return !visibleItemsIndexPaths.contains(item.indexPath)
            }
            return false
        }

        for behavior in behaviorsToRemove {
            if let springBehavior = behavior as? UIAttachmentBehavior,
                let item = springBehavior.items.first as? UICollectionViewLayoutAttributes
            {
                self.dynamicAnimator.removeBehavior(behavior)
                self.visibleIndexPaths.remove(item.indexPath)
            }
        }
    }

    @objc private func jsq_adjustSpringBehavior(
        _ springBehavior: UIAttachmentBehavior, forTouchLocation touchLocation: CGPoint
    ) {
        guard let item = springBehavior.items.first as? UICollectionViewLayoutAttributes else {
            return
        }
        var center = item.center

        if touchLocation != .zero {
            let distanceFromTouch = abs(touchLocation.y - springBehavior.anchorPoint.y)
            let scrollResistance = distanceFromTouch / CGFloat(self.springResistanceFactor)

            if self.latestDelta < 0.0 {
                center.y += max(self.latestDelta, self.latestDelta * scrollResistance)
            } else {
                center.y += min(self.latestDelta, self.latestDelta * scrollResistance)
            }
            item.center = center
        }
    }
}
