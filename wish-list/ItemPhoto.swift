//
//  ItemPhoto.swift
//  wish-list
//
//  Created by Caio Sanchez Christino on 27/11/17.
//  Copyright © 2017 Caio Sanchez Christino. All rights reserved.
//

import UIKit

class ItemPhoto : Equatable {
    let id : Int
    let name : String
    let hasProduct : Int
    let hasOffer : Int
    let link : String
    let urlThumbnail : String
    
    var thumbnail : UIImage?
    
    init (id:Int, name:String, link:String, hasOffer:Int, hasProduct:Int, urlThumbnail: String) {
        self.id = id
        self.name = name
        self.hasOffer = hasOffer
        self.hasProduct = hasProduct
        self.link = link
        self.urlThumbnail = urlThumbnail
    }
    
    func getUrlThumbnail(_ size:String = "m") -> URL? {
        if let url =  URL(string: urlThumbnail) {
            return url
        }
        return nil
    }
    
    func sizeToFillWidthOfSize(_ size:CGSize) -> CGSize {
        guard let thumbnail = thumbnail else {
            return size
        }
        
        let imageSize = thumbnail.size
        var returnSize = size
        
        let aspectRatio = imageSize.width / imageSize.height
        
        returnSize.height = returnSize.width / aspectRatio
        
        if returnSize.height > size.height {
            returnSize.height = size.height
            returnSize.width = size.height * aspectRatio
        }
        return returnSize
    }
}

func == (lhs: ItemPhoto, rhs: ItemPhoto) -> Bool {
    return lhs.id == rhs.id
}
