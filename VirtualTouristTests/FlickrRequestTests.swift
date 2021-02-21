//
//  FlickrRequestTests.swift
//  VirtualTouristTests
//
//  Created by Ataias Pereira Reis on 20/02/21.
//

import XCTest
@testable import VirtualTourist

class FlickrRequestTests: XCTestCase {


    func testBaseRequest() throws {
        let baseUrl = URL(string: "https://www.flickr.com/services/oauth/request_token")!
        let queryItems: [(key: String, value: String)] = [
            ("oauth_nonce", "95613465"),
            ("oauth_timestamp", "1305586162"),
            ("oauth_consumer_key", "653e7a6ecc1d528c516cc8f92cf98611"),
            ("oauth_signature_method", "HMAC-SHA1"),
            ("oauth_version", "1.0"),
            ("oauth_callback", "http://www.example.com".urlEncoded)
        ]
        let sut = FlickrRequest(verb: .GET, baseURL: baseUrl, queryItems: queryItems)

        XCTAssertEqual("GET&https%3A%2F%2Fwww.flickr.com%2Fservices%2Foauth%2Frequest_token&oauth_callback%3Dhttp%253A%252F%252Fwww.example.com%26oauth_consumer_key%3D653e7a6ecc1d528c516cc8f92cf98611%26oauth_nonce%3D95613465%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1305586162%26oauth_version%3D1.0", sut.baseTextRequest)
    }

    func testSignature() throws {
        let baseUrl = URL(string: "https://www.flickr.com/services/rest")!
        let queryItems: [(key: String, value: String)] = [
            ("nojsoncallback", "1"),
            ("oauth_nonce", "84354935"),
            ("format", "json"),
            ("oauth_consumer_key", "653e7a6ecc1d528c516cc8f92cf98611"),
            ("oauth_timestamp", "1305583871"),
            ("oauth_signature_method", "HMAC-SHA1"),
            ("oauth_version", "1.0"),
            ("oauth_token", "72157626318069415-087bfc7b5816092c"),
            ("method", "flickr.test.login")
        ]
        let sut = FlickrRequest(verb: .GET, baseURL: baseUrl, queryItems: queryItems)
        let signature = sut.signatureWith(consumerSecret: "consumerSecret", tokenSecret: "tokenSecret")
        XCTAssertEqual("OGpwLlIYhGW3L0rBpGctEZvB5l8=", signature)
    }


}
