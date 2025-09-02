//
//  ContentView.swift
//  iOS_16
//
//  Created by Arjunan on 14/08/25.
//

import SwiftUI
import PhotosUI


struct PhotosPickerExample: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared(), label: {
            Text("Select avatar")
        })
        .onChange(of: selectedItem) { newItem in
            newItem?.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    imageData = data
                case .failure(let err):
                    print("Error: \(err.localizedDescription)")
                }
            }
        }

        if let data = imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        }
        

    }
}

#Preview {
    PhotosPickerExample()
}
