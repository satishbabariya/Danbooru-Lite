//
//  Post.swift
//  Danbooru
//
//  Created by Satish on 20/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import Foundation

class Post: Codable {
    var id: Int
    var tagString: String?
    var fileURL: String?
    var largeFileURL: String?
    var previewFileURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case tagString = "tag_string"
        case fileURL = "file_url"
        case largeFileURL = "large_file_url"
        case previewFileURL = "preview_file_url"
    }
    
    init(id: Int, tagString: String?, fileURL: String?, largeFileURL: String?, previewFileURL: String?) {
        self.id = id
        
        self.tagString = tagString
        
        self.fileURL = fileURL
        self.largeFileURL = largeFileURL
        self.previewFileURL = previewFileURL
        
    }    
    
    func lightBoxImage() -> LightboxImage {
        
        
        if let largeFileURL = fileURL, let url = URL(string: largeFileURL) {
            let image = LightboxImage(imageURL: url)
            if let tags = tagString{
                    image.text = tags
            }
            return image
        } else if let fileURL = fileURL, let url = URL(string: fileURL) {
            let image = LightboxImage(imageURL: url)
            if let tags = tagString{
                image.text = tags
            }
            return image
        }
       
        return LightboxImage(image: #imageLiteral(resourceName: "image"))
    }
    
}

extension Post: Hashable {
    var hashValue: Int {
        return self.id
    }
}

extension Post: Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id &&
            
            lhs.tagString == rhs.tagString &&
            
            lhs.fileURL == rhs.fileURL &&
            lhs.largeFileURL == rhs.largeFileURL &&
            lhs.previewFileURL == rhs.previewFileURL
    }
}
