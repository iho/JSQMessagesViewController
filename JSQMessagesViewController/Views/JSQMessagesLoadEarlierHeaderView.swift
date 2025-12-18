import UIKit

public let kJSQMessagesLoadEarlierHeaderViewHeight: CGFloat = 32.0

@objc public protocol JSQMessagesLoadEarlierHeaderViewDelegate: NSObjectProtocol {
    func headerView(
        _ headerView: JSQMessagesLoadEarlierHeaderView, didPressLoadButton sender: UIButton)
}

@objc(JSQMessagesLoadEarlierHeaderView)
public class JSQMessagesLoadEarlierHeaderView: UICollectionReusableView {

    @IBOutlet public weak var delegate: JSQMessagesLoadEarlierHeaderViewDelegate?
    @IBOutlet public weak var loadButton: UIButton!

    // MARK: - Class methods

    public class func nib() -> UINib {
        return UINib(nibName: NSStringFromClass(self), bundle: Bundle(for: self))
    }

    public class func headerReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }

    // MARK: - Initialization

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.loadButton.setTitle("", for: .normal)
        self.loadButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
    }

    deinit {
        delegate = nil
    }

    public override var backgroundColor: UIColor? {
        didSet {
            loadButton?.backgroundColor = backgroundColor
        }
    }

    // MARK: - Actions

    @IBAction func loadButtonPressed(_ sender: UIButton) {
        delegate?.headerView(self, didPressLoadButton: sender)
    }
}
