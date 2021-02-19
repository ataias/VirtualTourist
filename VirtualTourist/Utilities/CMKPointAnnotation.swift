//
//  CMKPointAnnotation.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 19/02/21.
//

import Foundation
import MapKit

/// A Codable sub-class of MKPointAnnotation
class CMKPointAnnotation: MKPointAnnotation, Codable, Identifiable {
    var id = UUID()

    enum CodingKeys: CodingKey {
        case title
        case subtitle
        case latitude
        case longitude
    }

    override init() {
        super.init()
    }

    public required init(from decoder: Decoder) throws {
        super.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String?.self, forKey: .title)
        subtitle = try container.decode(String?.self, forKey: .subtitle)

        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
}
