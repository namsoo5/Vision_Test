//
//  AllPhotoCompareViewModel.swift
//  SimilarPhoto
//
//  Created by Enes on 8/5/24.
//

import Vision
import Photos
import SwiftUI

@Observable
final class AllPhotoCompareViewModel {
    var isLoading: Bool = false
    
    var sections: [SectionModel] = []
    var models: [AssetModel] = []
    var logString: [String] = []
    @ObservationIgnored var logStringStorage: [String] = []
    
    init() {
    }
    
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
    
    func fetchPhoto() {
        Task {
            let option = PHFetchOptions()
            let result = PHAsset.fetchAssets(with: .image, options: option)
            
            result.enumerateObjects { asset, index, _ in
                let model = AssetModel(asset: asset, date: asset.creationDate)
                self.models.append(model)
            }
            let imageRequest = PHCachingImageManager.default()
            let imageRequestOption = PHImageRequestOptions()
            imageRequestOption.isSynchronous = false
            imageRequestOption.deliveryMode = .opportunistic
            option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            models.forEach { model in
                imageRequest.requestImage(
                    for: model.asset,
                    targetSize: .init(width: 300, height: 300),
                    contentMode: .aspectFill,
                    options: imageRequestOption
                ) { image, info in
                    model.image = image
                }
            }
            filterDateGroup()
        }
    }
    
    private func filterDateGroup() {
        let calendar = Calendar.current
        var beforeKey = ""
        var sectionIndex = -1
        models.forEach { model in
            guard let date = model.date else {
                print("날짜없음")
                return
            }
            let component = calendar.dateComponents([.year, .month, .day], from: date)
            let year = component.year ?? 0
            let month = component.month ?? 0
            let day = component.day ?? 0
            
            let title = "\(year)-\(month)-\(day)"
            if beforeKey == title {
                sections[sectionIndex].assets.append(model)
            } else {
                let newSection = SectionModel(title: title)
                newSection.assets = [model]
                sections.append(newSection)
                beforeKey = title
                sectionIndex += 1
            }
        }
    }
    
    func compare(isLegacy: Bool) {
        if isLoading {
            return
        }
        self.isLoading = true
        self.isCancel = false
        updateLog()
        DispatchQueue.global().async { [self] in
            for section in sections {
                if isCancel {
                    return
                }
                let models = section.assets
                let startTime = CFAbsoluteTimeGetCurrent()
                var count = 0
                for i in models.indices {
                    if isCancel {
                        return
                    }
                    for j in i+1..<models.count {
                        if isCancel {
                            return
                        }
                        count += 1
                        let image1 = models[i].image
                        let image2 = models[j].image
                        guard let firstImage = featurePrint(image: image1, isLegacy: isLegacy),
                              let secondImage = featurePrint(image: image2, isLegacy: isLegacy) else {
                            return
                        }
                        var distance = Float(0)
                        do {
                            try firstImage.computeDistance(&distance, to: secondImage)
                        } catch let error {
                            print("Image comparison error.")
                            print(error.localizedDescription)
                        }
                    }
                }
                self.checkTime(start: startTime, log: "\(section.title)\n✅\(models.count)장 \(count)번 비교완료")
            }
            DispatchQueue.main.async {
                self.isLoading = false
                self.timer?.invalidate()
                self.timer = nil
            }
        }
        
    }
    
    private func checkTime(start time: CFAbsoluteTime, log: String) {
        let endTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = String(format: "%.02f", endTime - time)
        self.logStringStorage.append("\(log): \(elapsedTime) 초")
    }
    
    var timer: Timer?
    private func updateLog() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.logString = self.logStringStorage
            }
        }
    }
    
    @ObservationIgnored var isCancel: Bool = false
    func cancel() {
        isCancel = true
        self.timer?.invalidate()
        self.timer = nil
    }
}
