//
//  ObjectPhotoView.swift
//  SimilarPhoto
//
//  Created by Enes on 8/14/24.
//

import SwiftUI
import PhotosUI

struct ObjectPhotoView: View {
    @State private var viewModel: ObjectPhotoViewModel = .init()
    
    @State private var item: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack {
            originImage
                .frame(width: 200, height: 200)
                .clipped()
                .overlay {
                    PhotosPicker(
                        selection: $item,
                        matching: .images
                    ) {
                        Text("피커2")
                    }
                }
                .onChange(of: item) { oldValue, newValue in
                    Task {
                        if let imageData = await loadImage(newValue), let uiImage = UIImage(data: imageData) {
                            selectedImage = uiImage
                            viewModel.classify(uiImage)
                        }
                    }
                }
            HStack {
                ScrollView {
                    Text("버전2")
                    VStack(alignment: .leading) {
                        ForEach(viewModel.categories.indices, id: \.self) {
                            Text(viewModel.categories[$0])
                                .font(.system(size: 13))
                        }
                    }
                }
                Divider()
                ScrollView {
                    Text("버전1")
                    VStack(alignment: .leading) {
                        ForEach(viewModel.categories2.indices, id: \.self) {
                            Text(viewModel.categories2[$0])
                                .font(.system(size: 13))
                        }
                    }
                }
            }
        }
    }
    
    
    @ViewBuilder
    var originImage: some View {
        if let selectedImage = selectedImage {
            Image(uiImage: selectedImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.gray, lineWidth: 4)
        }
    }
    
    
    @MainActor
    private func loadImage(_ item: PhotosPickerItem?) async -> Data? {
        guard let imageData = try? await item?.loadTransferable(type: Data.self) else {
            return nil
        }
        return imageData
    }
}

#Preview {
    ObjectPhotoView()
}
