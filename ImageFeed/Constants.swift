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


