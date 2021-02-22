//: [Previous](@previous)

import Foundation
import CryptoKit
import VirtualTourist

let keyData = "key".data(using: .utf8)!
let key = SymmetricKey(data: keyData)
let data = "The quick brown fox jumps over the lazy dog".data(using: .utf8)!
let authenticationCode = HMAC<Insecure.SHA1>.authenticationCode(for: data, using: key)
print(authenticationCode)


let data2 = "GET&https%3A%2F%2Fwww.flickr.com%2Fservices%2Foauth%2Frequest_token&oauth_callback%3Dhttp%253A%252F%252Fwww.example.com%26oauth_consumer_key%3D653e7a6ecc1d528c516cc8f92cf98611%26oauth_nonce%3D95613465%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1305586162%26oauth_version%3D1.0".data(using: .utf8)

//: [Next](@next)
