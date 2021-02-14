//
//  FileManager+Extensions.swift
//  TheMovieManager (iOS)
//
//  Created by Ataias Pereira Reis on 04/01/21.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }

    /// Decodes from file URL using the default JSONDecoder
    /// - Parameter url: the url to read the data from
    /// - Returns: an optional with the decoded data; nil if the files does not exist
    /// - Throws: when file exists and couldn't load or decode it
    static func read<T: Decodable>(_ url: URL) throws -> T? {

        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let loaded = try decoder.decode(T.self, from: data)
        return loaded
    }

    /// Saves a codable structure to the given URL using the default JSONEncoder
    /// - Parameter encodable: the encodable data you want to have
    /// - Parameter to: the url to save the file to
    /// - throws
    static func save<T: Encodable>(_ encodable: T, to url: URL) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(encodable)
        try data.write(to: url, options: [.atomicWrite])
    }
}

