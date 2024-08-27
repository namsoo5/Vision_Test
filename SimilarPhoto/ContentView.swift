//
//  ContentView.swift
//  SimilarPhoto
//
//  Created by Enes on 8/5/24.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var item1: PhotosPickerItem?
    @State private var item2: PhotosPickerItem?
    @State private var selectedImage1: UIImage?
    @State private var selectedImage2: UIImage?
    @State private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            VStack(spacing: 5) {
                Text("프레임워크가 알고리즘의 일부(인식 속도, 정확도, 지원되는 언어 수 등)를 개선하는 OS 릴리스가 나올 때마다 리비전 번호는 1씩 증가")
                Text("버전1: iOS16에서 값의 범위는 0.0에서 40.0 사이입니다\n다른이미지만 보이려면 11미만 컷")
                Text("버전2: iOS17에서 값의 범위는 0.0에서 2.0 사이입니다\n다른이미지만 보이려면 0.5미만 컷")
            }
            .font(.system(size: 12))
            .multilineTextAlignment(.center)
            Divider()
            image1
                .frame(width: 200, height: 200)
                .clipped()
                .overlay {
                    PhotosPicker(
                        selection: $item1,
                        matching: .images
                    ) {
                        Text("피커1")
                            .frame(width: 200, height: 200)
                    }
                }
            image2
                .frame(width: 200, height: 200)
                .clipped()
                .overlay {
                    PhotosPicker(
                        selection: $item2,
                        matching: .images
                    ) {
                        Text("피커2")
                    }
                }
            Spacer().frame(height: 20)
            VStack {
                Text("버전1 >>> \(viewModel.revision1CompareScore)")
                Text("버전2 >>> \(viewModel.revision2CompareScore)")
            }
            Spacer().frame(height: 20)
            HStack {
                Button {
                    viewModel.compare(image1: selectedImage1, image2: selectedImage2, isLegacy: true)
                    viewModel.compare(image1: selectedImage1, image2: selectedImage2, isLegacy: false)
                } label: {
                    Text("테스트")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .border(.gray)
                }
            }
            Spacer().frame(height: 20)
            NavigationLink("전체 비교하기") {
                AllPhotoCompareView()
            }
            NavigationLink("사진 분류하기") {
                ObjectPhotoView()
            }
        }
        .padding()
        .onChange(of: item1) { oldValue, newValue in
            Task {
                if let imageData = await loadImage(newValue), let uiImage = UIImage(data: imageData) {
                    selectedImage1 = uiImage
                }
            }
        }
        .onChange(of: item2) { oldValue, newValue in
            Task {
                if let imageData = await loadImage(newValue), let uiImage = UIImage(data: imageData) {
                    selectedImage2 = uiImage
                }
            }
        }
    }
    
    @ViewBuilder
    var image1: some View {
        if let selectedImage = selectedImage1 {
            Image(uiImage: selectedImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.gray, lineWidth: 4)
        }
    }
    
    @ViewBuilder
    var image2: some View {
        if let selectedImage = selectedImage2 {
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
    ContentView()
}
