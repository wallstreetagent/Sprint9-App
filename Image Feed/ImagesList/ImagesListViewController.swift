
// ImagesListViewController

import Foundation
import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"

    @IBOutlet var tableView: UITableView!

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

     var presenter: ImagesListPresenterProtocol!

    func configure(_ presenter: ImagesListPresenterProtocol) {
        print("✅ configure called!")
        self.presenter = presenter
        presenter.view = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        presenter.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Failed to cast segue.destination or sender")
                return
            }

            let photo = presenter.photo(at: indexPath.row)
            let url = URL(string: photo.largeImageURL)
            let imageData = url.flatMap { try? Data(contentsOf: $0) }
            let image = imageData.flatMap { UIImage(data: $0) }
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.photoCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
}

// MARK: - Cell Config
extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = presenter.photo(at: indexPath.row)
        let url = URL(string: photo.thumbImageURL)

        cell.cellImage.kf.indicatorType = .activity
        let placeholder = UIImage(named: "placeholder")

        cell.cellImage.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.3))]
        ) { [weak self] result in
            if case .success = result {
                self?.tableView.beginUpdates()
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                self?.tableView.endUpdates()
            }
        }

        let dateText = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        cell.dateLabel.text = dateText
        cell.setIsLiked(photo.isLiked)
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == presenter.photoCount() - 1 {
            presenter.viewDidLoad() // можно сделать отдельный метод `fetchNextPage()`
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photo(at: indexPath.row)
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.didTapLike(at: indexPath.row)
    }
}

// MARK: - ImagesListViewControllerProtocol
extension ImagesListViewController: ImagesListViewControllerProtocol {
    func updateTableAnimated(oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func reloadRow(at index: Int) {
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    func showLikeError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось поставить лайк. Попробуйте позже.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
