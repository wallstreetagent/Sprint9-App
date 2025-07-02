import UIKit

final class ImagesListViewController: UIViewController {
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"

    @IBOutlet private var tableView: UITableView!

    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )

        imagesListService.fetchPhotosNextPage()
    }

    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        guard oldCount != newCount else { return }

        photos = imagesListService.photos

        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
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

            let photo = photos[indexPath.row]
            let url = URL(string: photo.largeImageURL)
            let imageData = url.flatMap { try? Data(contentsOf: $0) }
            let image = imageData.flatMap { UIImage(data: $0) }
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
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
        return imageListCell
    }
}

// MARK: - Cell Config
extension ImagesListViewController {
   
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let url = URL(string: photo.thumbImageURL)

        // 🔄 Индикатор загрузки
        cell.cellImage.kf.indicatorType = .activity

        // 🪧 Заглушка (замени "placeholder" на название своей картинки-заглушки из Assets)
        let placeholder = UIImage(named: "placeholder")

        // ⬇️ Загрузка изображения с Kingfisher
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

        // 📅 Отображение даты
        let dateText = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        cell.dateLabel.text = dateText

        // ❤️ Кнопка лайка
        let likeImage = photo.isLiked
            ? UIImage(named: "like_button_on")
            : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }

}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
           if indexPath.row == photos.count - 1 {
               imagesListService.fetchPhotosNextPage()
           }
       }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
