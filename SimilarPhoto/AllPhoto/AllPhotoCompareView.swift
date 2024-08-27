//
//  AllPhotoCompareView.swift
//  SimilarPhoto
//
//  Created by Enes on 8/5/24.
//

import SwiftUI

struct AllPhotoCompareView: View {
    @State private var viewModel: AllPhotoCompareViewModel = .init()
    
    var body: some View {
        VStack {
            Text("총사진: \(viewModel.models.count)")
            ScrollView {
                ForEach(viewModel.logString.indices, id: \.self) {
                    Text(viewModel.logString[$0])
                }
            }
            .frame(maxWidth: .infinity)
            .border(.gray)
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            Button {
                viewModel.compare(isLegacy: true)
            } label: {
                Text("버전1 전체 검사시작")
            }
            Spacer().frame(height: 20)
            Button {
                viewModel.compare(isLegacy: false)
            } label: {
                Text("버전2 전체 검사시작")
            }
            Spacer().frame(height: 30)
            Spacer().frame(height: 30)
        }
        .onDisappear {
            viewModel.cancel()
        }
        .onAppear {
            viewModel.fetchPhoto()
        }
    }
}

#Preview {
    AllPhotoCompareView()
}


