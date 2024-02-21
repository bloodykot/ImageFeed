import Foundation

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlsResult
    let isLiked: Bool
    
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case width = "width"
        case height = "height"
        case createdAt = "created_at"
        case description = "description"
        case urls = "urls"
        case isLiked = "liked_by_user"

    }
}

struct UrlsResult: Codable {
    let thumbImage: String
    let largeImage: String
    
    private enum CodingKeys: String, CodingKey {
        case thumbImage = "thumb"
        case largeImage = "full"
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

extension Photo {
    init(result photos: PhotoResult) {
        let dateFormatter = DateFormatterSingleton.shared
        let createdAt = dateFormatter.date(from: photos.createdAt ?? "")
        self.init(
            id: photos.id,
            size: CGSize(width: Double(photos.width), height: Double(photos.height)),
            createdAt: createdAt,
            welcomeDescription: photos.description,
            thumbImageURL: photos.urls.thumbImage,
            largeImageURL: photos.urls.largeImage,
            isLiked: Bool(photos.isLiked)
        )
    }
}
