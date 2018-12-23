//
//  DownloadQueuer.swift
//  Danbooru Lite
//
//  Created by Satish on 23/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import Dispatch
import Foundation
import Kingfisher
import Photos

class DownloadQueuer: NSObject {

    public let queue = DispatchQueue(label: "com.danboorulite.imagedownloading.queue")
    static let instance: DownloadQueuer = DownloadQueuer()

    func add(URL url: URL) {
        if PHPhotoLibrary.authorizationStatus() == .authorized{
            
//            queue.asyncAfter(deadline: .now() + 10, execute: {
//                ImageDownloader.default.downloadImage(with: url, retrieveImageTask: nil, options: nil, progressBlock: {
//                    receivedSize, totalSize in
//                    let percentage = (Float(receivedSize) / Float(totalSize)) * 100.0
//                    print("downloading progress: \(percentage)%")
//                }, completionHandler: { image, error, url, data in
//                    if let error = error {
//                        print(error)
//                    }
//                    if let image = image {
//                        PHPhotoLibrary.shared().savePhoto(image: image, albumName: "Danbooru Lite")
//                        //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                    }
//                })
//            })
            queue.async {
                ImageDownloader.default.downloadImage(with: url, retrieveImageTask: nil, options: nil, progressBlock: {
                    receivedSize, totalSize in
                    let percentage = (Float(receivedSize) / Float(totalSize)) * 100.0
                    print("downloading progress: \(percentage)%")
                }, completionHandler: { image, error, url, data in
                    if let error = error {
                        print(error)
                    }
                    if let image = image {
                        PHPhotoLibrary.shared().savePhoto(image: image, albumName: "Danbooru Lite")
                        //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                })
            }
        }
    }

}
