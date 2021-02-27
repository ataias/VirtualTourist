//
//  ImageView.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 27/02/21.
//

import SwiftUI

/// Resizable image to take up as much space as needed
struct ImageView: View {
    let uiImage: UIImage
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

// TODO I was thinking of allowing sharing of the images
struct ImageDetail: View {
    let photo: Flickr.Photo
    let uiImage: UIImage
    let delete: () -> Void

    var body: some View {
        ImageView(uiImage: uiImage)
            .navigationTitle(photo.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: delete) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
    }
}


struct ImageView_Previews: PreviewProvider {
    static var image: UIImage = UIImage.getColoredRectImageWith(color: UIColor.red.cgColor, andSize: CGSize(width: 600, height: 800))

    static var previews: some View {
        NavigationView {
            ImageDetail(photo: Flickr.Photo.sample, uiImage: image, delete: {})
        }
    }
}
