//
//  ViewController.swift
//  ImageFeed
//
//  Created by Dmitry Kirdin on 24.09.2023.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: Public properties
    static var urlLargeImage: URL?
    
    // MARK: - Private Properties
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    private let alertPresenter = AlertPresenter()
    private let imagesListService = ImagesListService.shared
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let dateFormatter = DateFormatter()
    
    
    // MARK: - - IB Actions
    
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter.delegate = self
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesListService.fetchPhotosNextPage() { _ in
        }
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] notification in
                self?.updateTableViewAnimated(notification: notification)
            }
        
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as? SingleImageViewController
            let indexPath = sender as? IndexPath
            ImagesListViewController.urlLargeImage = URL(string: photos[indexPath!.row].largeImageURL)
            let image = UIImage(named: "stub_placeholder")
            viewController?.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func getLargeImageURL() -> URL {
        return ImagesListViewController.urlLargeImage!
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIndentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: "stub_placeholder") else {
            return
        }
        cell.cellImage.image = image
        
        //MARK: Функционал загрузки картинки из 12-го спринта
        if photos.count > 0 {
            let cellImageKf = cell.cellImage
            cellImageKf?.kf.indicatorType = .activity
            cellImageKf?.kf.setImage(
                with: URL(string: photos[indexPath.row].thumbImageURL),
                placeholder: UIImage(named: "stub_placeholder")) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    case .failure:
                        assertionFailure("Invalid downloading thumbImage")
                    }
                }
        }
        
        if let date = photos[indexPath.row].createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = "дата публикации не известна"
        }
        
        
        let isLiked = photos[indexPath.row].isLiked
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: "stub_placeholder") else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth: Double
        let imageHeight: Double
        if photos.count >= indexPath.row + 1 {
            imageWidth = photos[indexPath.row].size.width
            imageHeight = photos[indexPath.row].size.height
        } else {
            imageWidth = image.size.width
            imageHeight = image.size.height
        }
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath) {
            if indexPath.row + 1 == imagesListService.photos.count {
                imagesListService.fetchPhotosNextPage() { _ in
                }
                imagesListServiceObserver = NotificationCenter.default.addObserver(
                    forName: ImagesListService.didChangeNotification,
                    object: nil,
                    queue: .main) { [weak self] notification in
                        self?.updateTableViewAnimated(notification: notification)
                    }
            }
    }
    
    private func updateTableViewAnimated(notification: Notification) {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath=tableView.indexPath(for: cell) else { return }
        let photo = imagesListService.photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.showLikeAlert(error: error)
            }
        }
    }
    
    private func showLikeAlert(error: Error) {
        alertPresenter.showAlert(
            title: "Что-то пошло не так:",
            message: "Не удалось поставить like/dislike, \(error.localizedDescription)") { [weak self] in
                guard let self = self else { return }
            }
    }
}
