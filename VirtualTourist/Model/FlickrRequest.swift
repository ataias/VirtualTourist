//
//  FlickrRequest.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 20/02/21.
//

import Foundation
import CryptoKit
import UIKit

/// A FlickrRequest
struct Flickr {
    struct Request {
        public let verb: HTTPVerb
        /// Components without signature
        public let baseURL: URL
        public let queryItems: [(key: String, value: String)]


        /// Signs the request using HMAC-SHA1
        /// Returns a signed URLRequest ready to be performed
        public func signedRequestWith(consumerSecret: String, tokenSecret: String) -> URLRequest {
            guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
                defaultLog.error("Invalid baseURL: \(baseURL)")
                fatalError()
            }

            components.queryItems = self.queryItems.map { URLQueryItem(name: $0, value: $1) }
            components.queryItems!.append(
                URLQueryItem(
                    name: "oauth_signature",
                    value: signatureWith(consumerSecret: consumerSecret, tokenSecret: tokenSecret)
                )
            )
            guard let url = components.url else {
                defaultLog.error("Invalid components: \(components)")
                fatalError()
            }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = verb.rawValue

            return urlRequest
        }

        /// Calculates the signature for the current request using HMAC-SHA1
        func signatureWith(consumerSecret: String, tokenSecret: String) -> String {
            let keyData = "\(consumerSecret)&\(tokenSecret)".data(using: .utf8)!
            let key = SymmetricKey(data: keyData)
            let data = baseTextRequest.data(using: .utf8)!
            let authenticationCode = HMAC<Insecure.SHA1>.authenticationCode(for: data, using: key)

            let bytes = authenticationCode.makeIterator()
            var signatureData = Data()
            signatureData.append(contentsOf: bytes)
            return signatureData.base64EncodedString()
        }

        /// The base text request used as payload for computing the signature
        ///
        /// Source: [Flickr OAuth](https://www.flickr.com/services/api/auth.oauth.html)
        var baseTextRequest: String {
            var parts = [verb.rawValue]
            parts.append(baseURL.string.urlEncoded)
            parts.append(queryItems.sorted(by: { $0.key < $1.key }).map {
                return "\($0.key)=\($0.value)"
            }.joined(separator: "&").urlEncoded)
            return parts.joined(separator: "&")
        }
    }
}

enum HTTPVerb: String {
    case GET
    case POST
}

// MARK: - Flickr Response Types
extension Flickr {
    struct PhotosResponse: Codable {
        let photos: Photos
        let stat: String
    }

    struct Photos: Codable {
        let page: Int
        let pages: Int
        let perPage: Int
        let total: String
        let photos: [Photo]

        enum CodingKeys: String, CodingKey {
            case page, pages
            case perPage = "perpage"
            case total
            case photos = "photo"
        }
    }

    struct Photo: Codable {
        let id: String
        let owner: String
        let secret: String
        let server: String
        let farm: Int
        let title: String
        let isPublic: Int
        let isFriend: Int
        let isFamily: Int

        enum CodingKeys: String, CodingKey {
            case id
            case owner
            case secret
            case server
            case farm
            case title
            case isPublic = "ispublic"
            case isFriend = "isfriend"
            case isFamily = "isfamily"
        }

        var url: URL {
            let size_suffix = "z"
            let file = "\(id)_\(secret)_\(size_suffix).jpg"
            let link = "https://live.staticflickr.com/\(server)/\(file)"
            return URL(string: link)!
        }

        static var sample: Flickr.Photo {
            Photo(id: "123", owner: "owner", secret: "123", server: "123", farm: 123, title: "Title", isPublic: 1, isFriend: 0, isFamily: 0)
        }
    }
}

extension Flickr.Photo {
    static func convert(from photo: Photo) -> Flickr.Photo {
        return Flickr.Photo(
            id: photo.id!,
            owner: "",
            secret: photo.secret!,
            server: photo.server!,
            farm: Int(photo.farm),
            title: photo.title!,
            isPublic: photo.isPublic ? 1 : 0,
            isFriend: photo.isFriend ? 1 : 0,
            isFamily: photo.isFamily ? 1 : 0
        )
    }
}
