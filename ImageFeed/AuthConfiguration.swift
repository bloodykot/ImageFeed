import UIKit

enum Constants {
    // MARK: Unsplash api base path
    static let defaultAPIBaseURLString = "https://api.unsplash.com"
    static let baseURLString = "https://unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let baseAuthTokenPath = "/oauth/token"
    // MARK: Unsplash api constants
    static let accessKey = "y2xYClR4oIHX-ypxB6sRB3T207314sI9tdngMuyJ2Tg"
    static let secretKey = "oFHgojxxgIO6mt0R-uFQwPble7EyZm0LXs5neXPSaI8"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    // MARK: Storage conctants
    static let bearerToken = "bearerToken"
    static let ypBlack = UIColor(
        red: 26/255,
        green: 27/255,
        blue: 34/255,
        alpha: 1)
    static let ypRed = UIColor(
        red: 245/255,
        green: 107/255,
        blue: 108/255,
        alpha: 1)
    static let ypGrey = UIColor(
        red: 174/255,
        green: 175/255,
        blue: 180/255,
        alpha: 1)
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString:  String
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURL: URL(string: Constants.defaultAPIBaseURLString)!,
            authURLString: Constants.unsplashAuthorizeURLString)
    }
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    
}

struct MockDataProfile {
    let profile = Profile(
        username: "James",
        name: "Bond",
        loginName: "agent007",
        bio: "unkown")
    let urlString = "https://avatars.mds.yandex.net/get-kinopoisk-image/4303601/f3ec11b5-fcc3-46a1-948f-fc1f8b4d14f9/600x900"
}
