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
    @Binding var locations: [TravelLocation]

    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode

    // MARK: - State and Properties
    @State private var coordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 56.948889, longitude: 24.106389),
        span: MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15))
    @State var isDragging = false
    @State private var showingPlaceDetails = false
    @State private var selectedPlace: TravelLocation?

    var body: some View {
        ZStack {
            MapView(
                centerCoordinate: $coordinateRegion.center,
                selectedPlace: $selectedPlace,
                showingPlaceDetails: $showingPlaceDetails,
                locations: $locations
            )
        }
        .sheet(isPresented: $showingPlaceDetails) {
            if let selectedPlace = selectedPlace {
                TravelLocationDetail(location: selectedPlace) {
                    showingPlaceDetails = false
                    if let index = locations.firstIndex(where: { selectedPlace.id == $0.id }) {
                        locations.remove(at: index)
                    }
                    self.selectedPlace = nil
                }
            }
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
            TravelLocationsView(logout: {}, locations: .constant(TravelLocation.sampleArray))
        }
    }
}
