//
//  ViewController.swift
//  ImageFeed
//
//  Created by Dmitry Kirdin on 24.09.2023.
//

import UIKit
import Kingfisher

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol? { get set }
    func showLikeAlert(error: Error)
    //func updateTableViewAnimated(notification: Notification)
    func performBatchUpdates(oldCount: Int, newCount: Int)
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol & TabBarControllerProtocol {
    
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: Public properties
    static var presenterTabBar: ImagesListViewPresenterProtocol?
    var testMode: Bool = false
    var presenter: ImagesListViewPresenterProtocol? = TabBarController.presenterTabBar
    
    
    // MARK: - Private Properties
    private let alertPresenter = AlertPresenter()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let dateFormatter = DateFormatterSingleton.shared
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        
        presenter?.view = self
        
        presenter?.viewDidLoad()
        
        alertPresenter.delegate = self
        
        guard testMode == false else {
            ImagesListService.shared.fetchPhotosNextPage(useMockDataIn: testMode) { _ in
            }
            presenter?.updateTableViewAnimated()
            presenter?.shouldFetchPhotosNextPage(lastRow: 10)
            
            return
        }
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as? SingleImageViewController
            let indexPath = sender as? IndexPath
            presenter?.setLargeImageURL(currentRow: indexPath!.row)
            let image = UIImage(named: "stub_placeholder")
            viewController?.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.getPhotosCount() ?? 0
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
        
        if (presenter?.getPhotosCount() ?? 0) > 0 {
            let cellImageKf = cell.cellImage
            cellImageKf?.kf.indicatorType = .activity
            cellImageKf?.kf.setImage(
                with: presenter?.thumbImageURL(currentRow: indexPath.row),
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
        
        if let date = presenter?.createdAt(currentRow: indexPath.row) {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        guard let isLiked = presenter?.isLiked(currentRow: indexPath.row) else { return }
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
        if presenter?.getPhotosCount() ?? 0 >= indexPath.row + 1 {
            imageWidth = presenter?.imageWidth(currentRow: indexPath.row) ?? 0
            imageHeight = presenter?.imageHeight(currentRow: indexPath.row) ?? 0
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
            presenter?.shouldFetchPhotosNextPage(lastRow: indexPath.row)
    }
    
    func performBatchUpdates(oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath=tableView.indexPath(for: cell) else { return }
        if presenter?.changeLike(currentRow: indexPath.row) == true {
            cell.setIsLiked(true)
        } else {
            cell.setIsLiked(false)
        }
    }
    
    func showLikeAlert(error: Error) {
        alertPresenter.showAlert(
            title: "Что-то пошло не так:",
            message: "Не удалось поставить like/dislike, \(error.localizedDescription)") { [weak self] in
                guard let self = self else { return }
            }
    }
}
