//
//  ObjectPhotoViewModel.swift
//  SimilarPhoto
//
//  Created by Enes on 8/14/24.
//

import UIKit
import Vision

@Observable
final class ObjectPhotoViewModel {
    var categories: [String] = []
    var categories2: [String] = []
    
    @MainActor
    func classify(_ image: UIImage) {
        categories.removeAll()
        categories2.removeAll()
        guard let ciImage = CIImage(image: image) else {
            print("nil")
            return
        }
        let handler = VNImageRequestHandler(ciImage: ciImage)
        let request = VNClassifyImageRequest { request, error in
            if let result = request.results as? [VNClassificationObservation] {
                var temp: [String] = []
                result.forEach {
                    if $0.confidence > 0 {
                        let text = $0.identifier + " \($0.confidence)"
                        temp.append(text)
                    }
                }
                self.categories = temp
            }
        }
        request.revision = VNClassifyImageRequestRevision2
        
        let request2 = VNClassifyImageRequest { request, error in
            if let result = request.results as? [VNClassificationObservation] {
                var temp: [String] = []
                result.forEach {
                    if $0.confidence > 0 {
                        let text = $0.identifier + " \($0.confidence)"
                        temp.append(text)
                    }
                }
                self.categories2 = temp
            }
        }
        request2.revision = VNClassifyImageRequestRevision1
        do {
            //            print(try request.supportedIdentifiers())
            try handler.perform([request, request2])
        } catch {
            print("❌",error)
        }
    }
}
