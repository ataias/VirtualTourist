//
//  Location.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 20/02/21.
//

import Foundation
import MapKit

/// A basic requirement for identifiable locations with titles that can be converted in map pins
protocol Location: Identifiable, Hashable, CustomStringConvertible {
    var id: UUID { get }
    var title: String { get }
    var subtitle: String { get }
    var latitude: Double { get }
    var longitude: Double { get }
    var coordinate: CLLocationCoordinate2D { get }

    init(id: UUID, title: String, subtitle: String, latitude: Double, longitude: Double)
}

extension Location {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

