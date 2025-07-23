import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    weak var delegate: ImagesListCellDelegate?

    override func prepareForReuse() {
            super.prepareForReuse()
            cellImage.kf.cancelDownloadTask()
            cellImage.image = UIImage(named: "placeholder")
        }

        @IBAction private func likeButtonTapped(_ sender: UIButton) {
            delegate?.imageListCellDidTapLike(self)
        }

        func setIsLiked(_ isLiked: Bool) {
            let image = isLiked
                ? UIImage(named: "like_button_on")
                : UIImage(named: "like_button_off")
            likeButton.setImage(image, for: .normal)
        }
    }
