//
//  HomeCell.swift
//  Danbooru
//
//  Created by Satish on 20/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import Foundation
import Material

class HomeCell: CollectionViewCell {
    
    fileprivate var imageView: UIImageView!
    fileprivate var fileURL: String = ""
    
    override func layoutSubviews() {
        super.layoutSubviews()
        depthPreset = .depth2
        cornerRadiusPreset = .cornerRadius1
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        if imageView != nil {
            print("Cell Dinit Called")
            imageView.image = nil
            imageView.removeFromSuperview()
            imageView = nil
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepareImageView()
        prepareConstraints()
    }
    
    fileprivate func prepareImageView() {
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
    }
    
    fileprivate func prepareConstraints() {
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDictionary()))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [.alignAllLeft, .alignAllRight], metrics: nil, views: viewDictionary()))
    }
    
    func configureCell(Post post: Post) {
        if Application.isLargeThumbnail() {
            if let url = post.fileURL {
                fileURL = url
            }
        } else {
            if let url = post.previewFileURL {
                fileURL = url
            }
        }
//        if Application.isLargeThumbnail(){
//            if let url = post.fileURL {
//                imageView.setImage(link: url)
//            }
//        }else{
//            if let url = post.previewFileURL {
//                imageView.setImage(link: url)
//            }
//        }
    }
    
    func loadFile() {
        imageView.setImage(link: fileURL)
    }
    
    func releseFile(){
        imageView.image = nil
    }
    
}
