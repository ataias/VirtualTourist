//
//  VirtualTouristModel.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 14/02/21.
//

import Foundation
import Combine
import OAuthSwift
import UIKit
import CryptoKit

class VirtualTouristModel: ObservableObject {
    // MARK: - Public Properties
    @Published var locations: [TravelLocation] = [] // TODO should come from core data
    @Published var isAuthenticated = false
    @Published var isLoggingIn = false

    // MARK: - Private properties
    private var oauthswift: OAuthSwift?
    private var credentials: FlickrOAuth!
    private var flickrApi: FlickrApi!
    private static var credentialsFile = FileManager.documentsDirectory.appendingPathComponent("authentication.json")

    private var getPhotosCancellable: AnyCancellable?

    // MARK: - Public Methods
    init() {

        loadSecrets()

        if !FileManager.default.fileExists(atPath: Self.credentialsFile.path) {
            defaultLog.debug("Credentials file does not exist yet. User need to log in.")
            return
        }

        do {
            let credentials = try FileManager.read(Self.credentialsFile) as FlickrOAuth
            self.credentials = credentials
            self.isAuthenticated = true
            defaultLog.info("Authenticated from file with username \(self.credentials!.username, privacy: .private(mask: .hash))")
        } catch {
            defaultLog.error("\(error.localizedDescription)")
        }
    }


}

// MARK: - Flickr Authentication
extension VirtualTouristModel {

    /// Initialize Flickr OAuth Process
    public func login() {
        doOAuthFlickr(flickrApi)
    }

    /// Deletes authentication files, returning user to the login screen
    public func logout() {
        // Some APIs have an endpoint to invalidate the credential on the server; however, flickr does not seem to have one, so we just delete the credentials locally for logout
        isAuthenticated = false
        do {
            defaultLog.debug("Logging out user \(self.credentials!.username, privacy: .private(mask: .hash))")
            try FileManager().removeItem(at: Self.credentialsFile)

        } catch {
            defaultLog.error("\(error.localizedDescription)")
        }
    }

    // MARK: - Private Methods
    private func loadSecrets() {
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

        self.flickrApi = appSecrets.flickrApi

    }
    private func doOAuthFlickr(_ flickrApi: FlickrApi) {
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
            case .success(let (credential,_, parameters)):
                save(flickrOauth: credential, parameters: parameters)
                self.isAuthenticated = true
                defaultLog.info("Authenticated with username \(self.credentials!.username, privacy: .private(mask: .hash))")
            case .failure(let error):
                defaultLog.error("\(error.localizedDescription)")
            }
        }
    }

    private func save(flickrOauth: OAuthSwiftCredential, parameters: [String: Any]) {
        let credentials = FlickrOAuth(
            id: (parameters["user_nsid"] as! String).removingPercentEncoding!,
            username: parameters["username"] as! String,
            fullName: (parameters["fullname"] as! String).removingPercentEncoding!,
            token: flickrOauth.oauthToken,
            tokenSecret: flickrOauth.oauthTokenSecret
        )
        do {
            try FileManager.save(credentials, to: Self.credentialsFile)
            self.credentials = credentials
        } catch {
            defaultLog.error("\(error.localizedDescription)")
            fatalError(error.localizedDescription)
        }
    }

}


// MARK: - Photos
extension VirtualTouristModel {
    func photos(for location: TravelLocation, onCompletion: @escaping ([UIImage]) -> Void, onError: ((Error) -> Void)? = nil) {

        // TODO select other pages here... depending if there are already photos or not
        let request = Flickr.Requests.PhotoSearch(location: location, accuracy: nil, page: 1)
            .urlRequest(flickrApi: flickrApi, credentials: credentials)

        getPhotosCancellable = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Flickr.PhotosResponse.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .failure(let error):
                        print("Error when running \(#function): \(error)")
                        onError?(error)
                    case .finished:
                        print("Finished \(#function) successfully")
                    }
                },
                receiveValue: {
                    defaultLog.debug("\(String(describing: $0))")
                }
            )
    }
}

// MARK: - Location
extension VirtualTouristModel {
    func delete(location: TravelLocation) {
        if let index = locations.firstIndex(where: { location.id == $0.id }) {
            self.locations.remove(at: index)
        }
    }
}

// MARK: - CryptoKit
extension AES.GCM.Nonce: CustomStringConvertible {
    public var description: String {
        makeIterator().map { "\($0)" }.joined()
    }
}

/// Secrets that are part of the API bundle like api keys
internal struct AppSecrets: Decodable {
    let flickrApi: FlickrApi
}

internal struct FlickrApi: Decodable {
    let key: String
    let secret: String
}

internal struct FlickrOAuth: Codable {
    /// The flickr user nsid
    let id: String
    let username: String
    let fullName: String
    let token: String
    let tokenSecret: String
}


// MARK: Flickr.Requests
extension Flickr {
    enum Requests<T: Location> {
        case PhotoSearch(location: T, accuracy: Int? ,page: Int)

        func urlRequest(flickrApi: FlickrApi, credentials: FlickrOAuth) -> URLRequest {
            let baseURL = URL(string: "https://www.flickr.com/services/rest/")!
            var request: Flickr.Request
            switch self {
            case let .PhotoSearch(location: location, accuracy, page: page):
                var queryItems = [
                    ("method", "flickr.photos.search"),
                    ("lat", "\(location.latitude)"),
                    ("lat", "\(location.longitude)")
                ]
                if let accuracy = accuracy {
                    queryItems.append(("accuracy", "\(accuracy)"))
                }
                queryItems.append(contentsOf: jsonQueryItems(page: page))
                queryItems.append(contentsOf: oauthQueryItems(flickrApi: flickrApi, credentials: credentials))
                request = Flickr.Request(verb: .GET, baseURL: baseURL, queryItems: queryItems)
            }

            return request.signedRequestWith(consumerSecret: flickrApi.secret, tokenSecret: credentials.tokenSecret)
        }

        private func jsonQueryItems(page: Int) -> [(key: String, value: String )] {
            return [
                ("format", "json"),
                ("nojsoncallback", "1"),
                ("per_page", "20"),
                ("page", "\(page)")
            ]
        }

        private func oauthQueryItems(flickrApi: FlickrApi, credentials: FlickrOAuth) -> [(key: String, value: String )] {
            let nonce = AES.GCM.Nonce()
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            let timestamp = formatter.string(from: NSNumber(value: CFAbsoluteTimeGetCurrent() * 1e6))!

            return [
                ("oauth_consumer_key", flickrApi.key),
                ("oauth_signature_method", "HMAC-SHA1"),
                ("oauth_version", "1.0"),
                ("oauth_token", credentials.token),
                ("oauth_timestamp", "\(timestamp)"),
                ("oauth_nonce", "\(nonce)"),
            ]
        }
    }

}
