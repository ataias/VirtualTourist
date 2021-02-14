//
//  TravelLocationsView.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 14/02/21.
//

import SwiftUI
import MapKit

struct TravelLocationsView: View {

    // MARK: - Input
    let logout: () -> Void
    let locations: [TravelLocation]

    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode

    // MARK: - State and Properties
    @State private var coordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 56.948889, longitude: 24.106389),
        span: MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15))
    @State var isDragging = false

    var drag: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                self.isDragging = true
                print("onChanged: \(value.location)")
            }
            .onEnded { value in
                self.isDragging = false
                print("onEnded: \(value.location)")
            }
    }

    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 3.0, maximumDistance: 0)
            .onEnded { value in
                print("Ended: \(value)")
            }
    }


    var body: some View {
        ZStack {
            Map(coordinateRegion: $coordinateRegion,
                annotationItems: locations,
                annotationContent: mapAnnotation(location:)
            )
            .gesture(longPress)
//            Color.red
//                .opacity(0.1)
//                .simultaneousGesture(longPress)
//                .allowsHitTesting(false)
        }


//        .simultaneousGesture(drag)
//        .overlay(
//            Color.red.opacity(0.1)
//
//        )
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.logout()
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                    Text("Logout")
                }
            }
        }
    }

    func mapAnnotation(location: TravelLocation) -> MapAnnotation<OnTheMapPinView> {
        MapAnnotation(coordinate: location.coordinate) {
            OnTheMapPinView(action: {
                print("Hello")
            })
        }
    }

}

struct TravelLocationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            // TODO use sample array
            TravelLocationsView(logout: {}, locations: TravelLocation.sampleArray)
        }
    }
}
