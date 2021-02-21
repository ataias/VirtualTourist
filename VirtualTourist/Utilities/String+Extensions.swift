//
//  String+Extensions.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 21/02/21.
//

import Foundation

extension String {
    /// Percent encoded URL for query format
    var urlEncoded: String {
        var set = CharacterSet()
        set.insert(charactersIn: "*'();:@&=+$,/?#[]%")
        set.invert()
        return self.addingPercentEncoding(withAllowedCharacters: set)!
    }
}
