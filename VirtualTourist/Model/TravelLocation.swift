//
//  TravelLocation.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 14/02/21.
//

import Foundation
import MapKit

struct TravelLocation: Codable, Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let latitude: Double
    let longitude: Double
}

extension TravelLocation {
    init(title: String, subtitle: String, latitude: Double, longitude: Double) {
        self.init(id: UUID(), title: title, subtitle: subtitle, latitude: latitude, longitude: longitude)
    }
}

extension TravelLocation {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

}

extension TravelLocation {
    static let sampleArray: [TravelLocation] = {
        let url = Bundle.main.url(forResource: "mockTravelLocation", withExtension: ".json")!
        let locations: [TravelLocation] = try! FileManager.read(url)
        return locations
    }()

    // TODO add some to json
//    static var sample: TravelLocation {
//        sampleArray[0]
//    }
    static var sample: TravelLocation {
        TravelLocation(id: UUID(), title: "Test Location", subtitle: "Sub Location", latitude: 2.5, longitude: 3.5)
    }
}

extension TravelLocation: Location {
    var description: String {
        return "(\(id), \(latitude), \(longitude))"
    }
}

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

