import UIKit

@objc(JSQMessagesCollectionViewCellIncoming)
public class JSQMessagesCollectionViewCellIncoming: JSQMessagesCollectionViewCell {

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.messageBubbleTopLabel.textAlignment = .left
        self.cellBottomLabel.textAlignment = .left
    }

}
