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
    @State private var pinnedLocations: [CMKPointAnnotation] = []
    @State private var showingPlaceDetails = false

    var body: some View {
        ZStack {
            MapView(
                centerCoordinate: $coordinateRegion.center,
                selectedPlace: .constant(nil),
                showingPlaceDetails: $showingPlaceDetails,
                annotations: $pinnedLocations
            )
        }
        .sheet(isPresented: $showingPlaceDetails) {
            TravelLocationDetail()
        }
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

}

struct TravelLocationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            // TODO use sample array
            TravelLocationsView(logout: {}, locations: TravelLocation.sampleArray)
        }
    }
}
