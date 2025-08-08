//
//  ImagesListViewController.swift
//  Image Feed
//
//  Created by Yanye Velikanova on 8/6/25.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView!
    
    var presenter: ImagesListPresenterProtocol?

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    func configure(_ presenter: ImagesListPresenterProtocol) {
        print("⚙️ ImagesListViewController configure() called")
        self.presenter = presenter
        self.presenter!.view = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if presenter == nil {
                let newPresenter = ImagesListPresenter()
                configure(newPresenter)
            }
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        presenter?.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            if let photo = presenter?.photo(at: indexPath.row),
               let url = URL(string: photo.largeImageURL),
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                viewController.image = image
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photoCount() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell,
            let photo = presenter?.photo(at: indexPath.row)
        else {
            return UITableViewCell()
        }

        configCell(for: cell, with: indexPath, photo: photo)
        cell.delegate = self
        return cell
    }
}

// MARK: - Cell Config
private extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, photo: Photo) {
        print("🔗 image URL:", photo.thumbImageURL)
        let url = URL(string: photo.thumbImageURL)
        let placeholder = UIImage(named: "placeholder")
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: placeholder, options: [.transition(.fade(0.3))]) { [weak self] result in
            if case .success = result {
                self?.tableView.performBatchUpdates {
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }

        cell.dateLabel.text = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        cell.setIsLiked(photo.isLiked)
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (presenter?.photoCount() ?? 0) - 1 {
            presenter?.viewDidLoad() // можно сделать отдельный метод fetchNextPage()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.photo(at: indexPath.row) else { return 0 }
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - insets.left - insets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + insets.top + insets.bottom
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath.row)
    }
}

// MARK: - ImagesListViewControllerProtocol
extension ImagesListViewController: ImagesListViewControllerProtocol {
    func updateTableAnimated(oldCount: Int, newCount: Int) {
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        tableView.performBatchUpdates {
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
        present(alert, animated: true)
    }
}
