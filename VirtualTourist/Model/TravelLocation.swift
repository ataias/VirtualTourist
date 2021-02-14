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
    let createdAt: Date
    let latitude: Double
    let longitude: Double
    let updatedAt: Date


    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

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

    static var sample: TravelLocation {
        sampleArray[0]
    }
}
