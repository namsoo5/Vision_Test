//
//  ViewModel.swift
//  SimilarPhoto
//
//  Created by Enes on 8/5/24.
//

import Foundation
import Vision
import SwiftUI

@Observable
final class ViewModel {
    var revision1CompareScore: Float = 0
    var revision2CompareScore: Float = 0
    
    private func featurePrint(image: UIImage?, isLegacy: Bool) -> VNFeaturePrintObservation? {
        let request = VNGenerateImageFeaturePrintRequest()
        request.revision = isLegacy ? VNGenerateImageFeaturePrintRequestRevision1 : VNGenerateImageFeaturePrintRequestRevision2
        guard let cgImage = image?.cgImage else {
            print("error cgImage")
            return nil
        }
        let handler = VNImageRequestHandler(cgImage: cgImage)
        do {
            try handler.perform([request])
            
            let result = request.results?.first
            return result
        } catch {
            print(error)
        }
        return nil
    }
    
    func compare(image1: UIImage?, image2: UIImage?, isLegacy: Bool) {
        guard let firstImage = featurePrint(image: image1, isLegacy: isLegacy),
              let secondImage = featurePrint(image: image2, isLegacy: isLegacy) else {
            return
        }
        
        var distance = Float(1)
        do {
            try firstImage.computeDistance(&distance, to: secondImage)
            print("Image similarity distance: \(distance)")
            if isLegacy {
                revision1CompareScore = distance
            } else {
                revision2CompareScore = distance
            }
            
        } catch let error {
            print("Image comparison error.")
            print(error.localizedDescription)
        }
    }
}
