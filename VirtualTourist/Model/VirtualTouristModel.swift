//
//  VirtualTouristModel.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 14/02/21.
//

import Foundation
import Combine
import OAuthSwift

class VirtualTouristModel: ObservableObject {
    var oauthswift: OAuthSwift?
    @Published var isAuthenticated = false
    @Published var isLoggingIn = false

    // TODO use the onReceiveValue
    public func authorize() {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "json") else {
            fatalError("Secrets.json couldn't be found.")
        }
        let url = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let appSecrets = try? decoder.decode(AppSecrets.self, from: data) else {
            fatalError("Could not decode secrets file")
        }

        doOAuthFlickr(appSecrets.flickrApi)

    }

    private func doOAuthFlickr(_ flickrApi: FlickrApi){
        isLoggingIn = true

        let oauthswift = OAuth1Swift(
            consumerKey:    flickrApi.key,
            consumerSecret: flickrApi.secret,
            requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
            authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
            accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
        )
        self.oauthswift = oauthswift
        oauthswift.authorizeURLHandler = OAuthSwiftOpenURLExternally.sharedInstance
        let _ = oauthswift.authorize(withCallbackURL: URL(string: "virtualtourist:///authenticate")!) { [self] result in
            
            self.isLoggingIn = false
            switch result {
            case .success(let (credential, _, _)):
                // TODO save credentials
                print(credential.oauthToken)
                self.isAuthenticated = true
            case .failure(let error):
                print(error.description)
            }
        }
    }

}

/// Secrets that are part of the API bundle like api keys
fileprivate struct AppSecrets: Decodable {
    let flickrApi: FlickrApi
}

fileprivate struct FlickrApi: Decodable {
    let key: String
    let secret: String
}
