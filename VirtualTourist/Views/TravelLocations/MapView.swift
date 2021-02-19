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

struct MapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var selectedPlace: MKPointAnnotation?
    @Binding var showingPlaceDetails: Bool
    @Binding var annotations: [CMKPointAnnotation]
//    @Binding var locations: [TravelLocation]

    var cancellable: AnyCancellable?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.centerCoordinate = centerCoordinate
        mapView.delegate = context.coordinator

        return mapView
    }

    // When reading the points below, consider making this MapView generic! It could be MapView<T: Location> where Location is a protocol that requires latitude and longitude, besides optionally a title and a subtitle; it would also need identifiable 
    // TODO move CMKPointAnnotation to this file, maybe just delete it and use MKPointAnnotation directly
    // TODO use only TravelLocation in the arguments here
    // TODO CMKPointAnnotation and TravelLocation have a UUID which is the same; we create it on TravelLocation and then give that UUID to the CMKPointAnnotation!
    // TODO keep the logic here, but check the UUIDs instead and then remove/subtract annotation accordingly
    func updateUIView(_ view: MKMapView, context: Context) {
        let currentAnnotations = Set(self.annotations)
        let oldAnnotations = Set(view.annotations as! [CMKPointAnnotation])

        let toRemove = Array(oldAnnotations.subtracting(currentAnnotations))
        let toAdd = Array(currentAnnotations.subtracting(oldAnnotations))
        view.removeAnnotations(toRemove)
        view.addAnnotations(toAdd)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
            let gesture = UILongPressGestureRecognizer()
            gesture.minimumPressDuration = 1.0
            gesture.addTarget(self, action: #selector(dropPinOnLongPress))
            mapView.addGestureRecognizer(gesture)
        }

        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
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
            guard let placemark = view.annotation as? MKPointAnnotation else { return }

            parent.selectedPlace = placemark
            parent.showingPlaceDetails = true
        }

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
            let newLocation = CMKPointAnnotation()
            newLocation.title = "Example title"
            newLocation.coordinate = location

            parent.annotations.append(newLocation)
            parent.selectedPlace = newLocation
            parent.showingPlaceDetails = true
        }

    }
}

// MARK: - Helper Extensions

extension CLLocationCoordinate2D: CustomStringConvertible {
    public var description: String {
        "CLLocationCoordinate2D(latitude: \(self.latitude), longitude: \(self.longitude)"
    }
}
