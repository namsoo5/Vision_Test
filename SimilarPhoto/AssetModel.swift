//
//  AssetModel.swift
//  SimilarPhoto
//
//  Created by Enes on 8/5/24.
//

import Photos
import UIKit

class AssetModel {
    let asset: PHAsset
    var date: Date?
    var image: UIImage?
    
    init(asset: PHAsset, date: Date?) {
        self.asset = asset
        self.date = date
    }
}

class SectionModel {
    let title: String
    var assets: [AssetModel] = []
    
    init(title: String) {
        self.title = title
    }
}
