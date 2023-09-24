import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    // MARK: - IB Outlets
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    // MARK: - Public Properties
    static let reuseIndentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?     
    
    // MARK: - IB Actions
    @IBAction private func likeButtonClicked() {
        delegate?.imagesListCellDidTapLike(self)
    }
    
    // MARK: - Public Methods
    func setIsLiked(_ status: Bool) {
        let likeImage = status ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        
        likeButton.setImage(likeImage, for: .normal)
    }
    
    // MARK: - Override methods 12 sprint
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}
