//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Dmitry Kirdin on 23.02.2024.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration
    
    private enum QueryParam {
        static let clientID = "client_id"
        static let redirectURI = "redirect_uri"
        static let responseType = "response_type"
        static let scope = "scope"
    }
    
    private enum WebConstants {
        static let authorizePath = "/oauth/authorize/native"
        static let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
        static let code = "code"
    }
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        return URLRequest(url: url)
    }
    
    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {return nil}
        
        urlComponents.queryItems = [
            URLQueryItem(name: QueryParam.clientID, value: configuration.accessKey),
            URLQueryItem(name: QueryParam.redirectURI, value: configuration.redirectURI),
            URLQueryItem(name: QueryParam.responseType, value: WebConstants.code),
            URLQueryItem(name: QueryParam.scope, value: configuration.accessScope)
        ]
        
        return urlComponents.url
    }
    
    func code(from url: URL) -> String? {
        if
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == WebConstants.authorizePath,
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: {$0.name == WebConstants.code})
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
}
