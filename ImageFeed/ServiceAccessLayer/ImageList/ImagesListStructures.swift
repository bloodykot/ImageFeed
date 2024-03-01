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

struct MockPhoto {
    var photos: [Photo] = []
    init() {
        self.photos.append(Photo(
            id: "1",
            size: CGSize(width: Double(7831), height: Double(5221)),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://images.unsplash.com/photo-1682687982501-1e58ab814714?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTA2NjV8MXwxfGFsbHwxfHx8fHx8Mnx8MTcwODg4NTg1MHw&ixlib=rb-4.0.3&q=80&w=200",
            largeImageURL: "www.yandex.ru",
            isLiked: false))
        self.photos.append(Photo(
            id: "2",
            size: CGSize(width: Double(4160), height: Double(6240)),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://images.unsplash.com/photo-1708834269879-e7bd99d7e77c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTA2NjV8MHwxfGFsbHwyfHx8fHx8Mnx8MTcwODg4NTg1MHw&ixlib=rb-4.0.3&q=80&w=200",
            largeImageURL: "www.yandex.ru",
            isLiked: false))
        self.photos.append(Photo(
            id: "3",
            size: CGSize(width: Double(3840), height: Double(5760)),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://images.unsplash.com/photo-1708793699440-67fa853abd4d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTA2NjV8MHwxfGFsbHwzfHx8fHx8Mnx8MTcwODg4NTg1MHw&ixlib=rb-4.0.3&q=80&w=200",
            largeImageURL: "www.yandex.ru",
            isLiked: false))
        self.photos.append(Photo(
            id: "4",
            size: CGSize(width: Double(3995), height: Double(5992)),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://images.unsplash.com/photo-1708710301724-6121560b6de0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTA2NjV8MHwxfGFsbHw0fHx8fHx8Mnx8MTcwODg4NTg1MHw&ixlib=rb-4.0.3&q=80&w=200",
            largeImageURL: "www.yandex.ru",
            isLiked: false))
        self.photos.append(Photo(
            id: "5",
            size: CGSize(width: Double(3056), height: Double(4592)),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://images.unsplash.com/photo-1708771754562-163e2994c815?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTA2NjV8MHwxfGFsbHw1fHx8fHx8Mnx8MTcwODg4NTg1MHw&ixlib=rb-4.0.3&q=80&w=200",
            largeImageURL: "www.yandex.ru",
            isLiked: false))
        self.photos.append(Photo(
            id: "6",
            size: CGSize(width: Double(9504), height: Double(6336)),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://images.unsplash.com/photo-1707343848610-16f9afe1ae23?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTA2NjV8MXwxfGFsbHw2fHx8fHx8Mnx8MTcwODg4NTg1MHw&ixlib=rb-4.0.3&q=80&w=200",
            largeImageURL: "www.yandex.ru",
            isLiked: false))
        self.photos.append(Photo(
            id: "7",
            size: CGSize(width: Double(8400), height: Double(5600)),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://images.unsplash.com/photo-1708724195876-1156245fce21?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTA2NjV8MHwxfGFsbHw3fHx8fHx8Mnx8MTcwODg4NTg1MHw&ixlib=rb-4.0.3&q=80&w=200",
            largeImageURL: "www.yandex.ru",
            isLiked: false))
        self.photos.append(Photo(
            id: "8",
            size: CGSize(width: Double(6094), height: Double(4063)),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://images.unsplash.com/photo-1708733925285-3c709f5eeae8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTA2NjV8MHwxfGFsbHw4fHx8fHx8Mnx8MTcwODg4NTg1MHw&ixlib=rb-4.0.3&q=80&w=200",
            largeImageURL: "www.yandex.ru",
            isLiked: false))
        self.photos.append(Photo(
            id: "9",
            size: CGSize(width: Double(4071), height: Double(6107)),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://images.unsplash.com/photo-1708583625765-e02e3fb6621d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTA2NjV8MHwxfGFsbHw5fHx8fHx8Mnx8MTcwODg4NTg1MHw&ixlib=rb-4.0.3&q=80&w=200",
            largeImageURL: "www.yandex.ru",
            isLiked: false))
        self.photos.append(Photo(
            id: "10",
            size: CGSize(width: Double(4016), height: Double(6016)),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://images.unsplash.com/photo-1708769467674-cd1303507f6b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w1MTA2NjV8MHwxfGFsbHwxMHx8fHx8fDJ8fDE3MDg4ODU4NTB8&ixlib=rb-4.0.3&q=80&w=200",
            largeImageURL: "www.yandex.ru",
            isLiked: false))
    }
}
