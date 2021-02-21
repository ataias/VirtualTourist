//
//  MapView.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 14/02/21.
//

import SwiftUI
import MapKit
import Combine

// MARK: - MapView

/// A map view that accepts an array of locations to create its pins
///
/// It is assumed the order of the elements is relatively stable, adding or removing one element
struct MapView<T: Location>: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var selectedPlace: T?
    @Binding var locations: [T]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.region = region
        mapView.delegate = context.coordinator
        // TODO should the pins be initialized here?
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        updatePins(view, context: context)
        context.coordinator.previousLocations = locations
        defaultLog.debug("LOCATIONS: \(locations)")
    }

    private func updatePins(_ view: MKMapView, context: Context) {
        let cmkAnnotations = view.annotations as! [CMKPointAnnotation]
        let differences = locations.difference(from: context.coordinator.previousLocations)

        for difference in differences {
            switch difference {
            case .insert(offset: _, element: let element, associatedWith: _):
                view.addAnnotation(CMKPointAnnotation(from: element))
            case .remove(offset: _, element: let element, associatedWith: _):
                let annotation = cmkAnnotations.first { $0.id == element.id }
                view.removeAnnotation(annotation!)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        /// Locations from the time the map view was last updated. Useful for verifying which pins to add and remove on the next update
        var previousLocations: [T]

        init(_ parent: MapView) {
            self.parent = parent
            self.previousLocations = []
        }

        // MARK: - MKMapViewDelegate
        func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
            let gesture = UILongPressGestureRecognizer()
            gesture.minimumPressDuration = 1.0
            gesture.addTarget(self, action: #selector(dropPinOnLongPress))
            mapView.addGestureRecognizer(gesture)
        }

        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.region = mapView.region
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "Placemark"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }

            annotationView?.animatesDrop = true

            return annotationView
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let placemark = view.annotation as? CMKPointAnnotation else { return }

            parent.selectedPlace = placemark.convert()
        }

        // MARK: - Auxiliary Methods
        @objc func dropPinOnLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                let cgPointLocation = gestureRecognizer.location(in: gestureRecognizer.view)
                let view = gestureRecognizer.view as! MKMapView
                let location: CLLocationCoordinate2D = view.convert(cgPointLocation, toCoordinateFrom: view)
                defaultLog.debug("\(location)")
                addNewLocation(location, toMap: view)
            }
        }

        func addNewLocation(_ location: CLLocationCoordinate2D, toMap mapView: MKMapView) {
            // Only update the state binding, as this will trigger a view update which will actually add the annotation
            let newLocation = CMKPointAnnotation()
            newLocation.title = "Example title"
            newLocation.coordinate = location

            parent.locations.append(newLocation.convert())
            parent.selectedPlace = newLocation.convert()
        }

    }
}

// MARK: - Helper Extensions

extension CLLocationCoordinate2D: CustomStringConvertible {
    public var description: String {
        "CLLocationCoordinate2D(latitude: \(self.latitude), longitude: \(self.longitude)"
    }
}

// MARK: - CMKPointAnnotation

/// A Codable sub-class of MKPointAnnotation
fileprivate class CMKPointAnnotation: MKPointAnnotation, Codable, Identifiable {
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

    public init<T: Location>(from location: T) {
        super.init()
        self.id = location.id
        self.title = location.title
        self.subtitle = location.subtitle
        self.coordinate = location.coordinate
    }

    public func convert<T: Location>() -> T {
        return T.init(
            id: id,
            title: title ?? "",
            subtitle: subtitle ?? "",
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }
}

// MARK: - Codable Coordinate Region

struct CoordinateRegion: Codable {

    var region: MKCoordinateRegion

    enum CodingKeys: CodingKey {
        case latitude
        case longitude
        case latitudeDelta
        case longitudeDelta
    }

    public init(center: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        self.region = MKCoordinateRegion(center: center, span: span)
    }

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)

        let latitudeDelta = try container.decode(CLLocationDegrees.self, forKey: .latitudeDelta)
        let longitudeDelta = try container.decode(CLLocationDegrees.self, forKey: .longitudeDelta)

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)

        self.region = MKCoordinateRegion(center: coordinate, span: span)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(region.center.latitude, forKey: .latitude)
        try container.encode(region.center.longitude, forKey: .longitude)
        try container.encode(region.span.latitudeDelta, forKey: .latitudeDelta)
        try container.encode(region.span.longitudeDelta, forKey: .longitudeDelta)
    }

}


// RawRepresentable is useful for using this struct with AppStorage
// Source: [Save Custom Codable Types in App Storage or Scene Storage](https://lostmoa.com/blog/SaveCustomCodableTypesInAppStorageOrSceneStorage/) by Natalia Panferova
extension CoordinateRegion: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(CoordinateRegion.self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return ""
        }
        return result
    }
}
