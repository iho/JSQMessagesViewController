import UIKit

@objc(JSQMessagesCollectionViewCellOutgoing)
public class JSQMessagesCollectionViewCellOutgoing: JSQMessagesCollectionViewCell {

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.messageBubbleTopLabel.textAlignment = .right
        self.cellBottomLabel.textAlignment = .right
    }

}
