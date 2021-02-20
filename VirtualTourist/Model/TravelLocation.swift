//
//  TravelLocation.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 14/02/21.
//

import Foundation
import MapKit

struct TravelLocation: Codable, Identifiable {
    var id = UUID()
    let title: String
    let subtitle: String
    let latitude: Double
    let longitude: Double

    let createdAt: Date
    let updatedAt: Date

    var formattedCreatedAt: String {
        Self.dateFormatter.string(from: createdAt)
    }
    var formattedUpdatedAt: String {
        Self.dateFormatter.string(from: updatedAt)
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

    init(id: UUID, title: String, subtitle: String, latitude: Double, longitude: Double) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = Date()
        self.updatedAt = createdAt
    }
}
