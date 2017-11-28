//
//  Item.swift
//  wish-list
//
//  Created by Caio Sanchez Christino on 27/11/17.
//  Copyright © 2017 Caio Sanchez Christino. All rights reserved.
//

import UIKit

let apiKey = "1511802137422ab7964de"

class Item {
    let processingQueue = OperationQueue()
    func searchItemForTerm(_ searchTerm: String, completion : @escaping (_ results: ItemSearchResults?, _ error : NSError?) -> Void){
        
        guard let searchURL = itemSearchURLForSearchTerm(searchTerm) else {
            let APIError = NSError(domain: "ItemSearch", code: 1, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
            completion(nil, APIError)
            return
        }
        
        let searchRequest = URLRequest(url: searchURL)
        
        URLSession.shared.dataTask(with: searchRequest, completionHandler: { (data, response, error) in
            if let _ = error {
                let APIError = NSError(domain: "ItemSearch", code: 2, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                OperationQueue.main.addOperation({
                    completion(nil, APIError)
                })
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    let APIError = NSError(domain: "ItemSearch", code: 3, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
            }
            
            do {
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject],
                    
                    let requestInfo = resultsDictionary["requestInfo"] as? [String:AnyObject] else {
                        let APIError = NSError(domain: "ItemSearch", code: 4, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                        OperationQueue.main.addOperation({
                            completion(nil, APIError)
                        })
                        return
                }
                
                let status = requestInfo["status"] as! String
                switch (status) {
                case "OK":
                    print("Results processed OK")
                case "FAIL":
                    if let message = resultsDictionary["message"] {
                        let APIError = NSError(domain: "ItemSearch", code: 5, userInfo: [NSLocalizedFailureReasonErrorKey:message])
                        
                        OperationQueue.main.addOperation({
                            completion(nil, APIError)
                        })
                    }
                    
                    let APIError = NSError(domain: "ItemSearch", code: 6, userInfo: nil)
                    
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    
                    return
                default:
                    let APIError = NSError(domain: "ItemSearch", code: 7, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                
                let itemReceived = resultsDictionary["categories"] as! [[String:AnyObject]]
                var itemPhotos = [ItemPhoto]()
                
                for photoObject in itemReceived {
                        guard let idItem = photoObject["id"] as? Int,
                        let nameItem = photoObject["name"] as? String ,
                        let linkItem = photoObject["link"] as? String ,
                        let offer = photoObject["hasOffer"] as? Int ,
                        let thumbnails = photoObject["thumbnail"] as? [String:AnyObject],
                        let product = photoObject["hasProduct"] as? Int else {
                            break
                    }
                    let itemPhoto = ItemPhoto(id: idItem, name: nameItem, link: linkItem, hasOffer: offer, hasProduct: product, urlThumbnail:thumbnails.values.first as! String)
                    itemPhotos.append(itemPhoto)
                    
                    guard let url = itemPhoto.getUrlThumbnail(),
                        let imageData = try? Data(contentsOf: url as URL) else {
                            break
                    }
                    
                    if let image = UIImage(data: imageData) {
                        itemPhoto.thumbnail = image
                        itemPhotos.append(itemPhoto)
                    }
                }
                
                OperationQueue.main.addOperation({
                    completion(ItemSearchResults(searchTerm: searchTerm, searchResults: itemPhotos), nil)
                })
                
            } catch _ {
                completion(nil, nil)
                return
            }
        }) .resume()
    }
    
    fileprivate func itemSearchURLForSearchTerm(_ searchTerm:String) -> URL? {
        guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        let URLString = "https://sandbox-api.lomadee.com/v2/\(apiKey)/category/_search?sourceId=35894859&keyword=\(escapedTerm)"
        guard let url = URL(string:URLString) else {
            return nil
        }
        return url
    }
}
