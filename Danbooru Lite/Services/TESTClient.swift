//
//  File.swift
//  Danbooru Lite
//
//  Created by Satish on 29/05/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import Alamofire
import Foundation
import Foundation
import Reachability
import RxAlamofire
import RxSwift

enum TESTClient {
    case test(type: ServiceType, url: String)
}

extension TESTClient {
    
    fileprivate var path: String {
        switch self {
        case .test(type: let type, url: _):
            let limit = 100
            let page = 1
            switch type {
            case .flickr:
                return "?method=flickr.interestingness.getList&api_key=97adbb4e968f8802d83ef157d53b3862&per_page=\(limit)&page=\(page)&format=json&nojsoncallback=1"
            case .danbooru:
                return "posts.json?limit=\(limit)&page=\(page)"
            case .gelbooru:
                return "index.php?page=dapi&s=post&q=index&json=1&pid=\(page)"
            case .yandere, .kochan:
                return "post.json?limit=\(limit)&page=\(page)"
            }
        }
    }
    
    fileprivate var method: HTTPMethod {
        return .get
    }
    
    fileprivate var baseURL: String {
        switch self {
        case .test(type: _, url: let endpoint):
            return endpoint
        }
    }
    
    fileprivate var url: String {
        return self.baseURL + self.path
    }
    
    // MARK: - Public Interface -
    
    func request() -> Observable<(RESTMeta, Any)> {
        
        // If No Internet Connection Throws error
        if Reachability()!.connection == .none {
            return Observable.error(RESTError(statusCode: 1001, title: "Connectivity", message: "No internet connection.", type: .warning))
        }
        print("DEBUG: RESTClient \nREQUEST : \(self.method.rawValue) \(self.url) \n")
        // If Internet Connection Avaiable then request data
        return Observable.create({ (observer) -> Disposable in
            requestJSON(self.method, self.url).subscribe({ event in
                switch event {
                case .next(let responce, let data):
                    print("DEBUG: RESTClient \nRESPONCE StatusCode : \(responce.statusCode) \n")
                    do {
                        observer.onNext(try self.handleResponce(responce: responce, data: data))
                    } catch let e as RESTError {
                        observer.onError(e)
                    } catch {
                        observer.onError(error)
                    }
                    
                case .error(let error):
                    observer.onError(self.handleError(error: error))
                case .completed:
                    observer.onCompleted()
                }
            })
        })
        
    }
    
}

// MARK: - Handle Responce
extension TESTClient {
    
    fileprivate func handleResponce(responce: HTTPURLResponse, data: Any) throws -> (RESTMeta, Any) {
        let meta: RESTMeta = RESTMeta(statusCode: responce.statusCode)
        
        if responce.statusCode == 200 {
            return (meta, self.parse(data: data))
        } else {
            throw RESTError(statusCode: meta.statusCode, title: meta.title, message: meta.message, type: meta.type)
        }
        
    }
    
    fileprivate func parse(data: Any) -> Any {
        
        switch self {
        case .test(type: let type, url: _):
            switch type {
            case .flickr:
                if let dictData: [String: Any] = data as? [String: Any],
                    let photos: [String: Any] = dictData["photos"] as? [String: Any],
                    let photo: [[String: Any]] = photos["photo"] as? [[String: Any]] {
                    return photo.flatMap({ (item) -> Post? in
                        if let id: String = item["id"] as? String,
                            let farm: Int = item["farm"] as? Int,
                            let server: String = item["server"] as? String,
                            let secret: String = item["secret"] as? String {
                            return Post(id: Int(id) ?? 0, tagString: nil, fileURL: "https://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg", largeFileURL: "https://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg", previewFileURL: "https://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret)_m.jpg")
                        } else {
                            return nil
                        }
                    })
                } else {
                    return []
                }
            case .danbooru:
                guard let arrData: [[String: Any]] = data as? [[String: Any]] else {
                    return []
                }
                return arrData.flatMap({ (item) -> Post? in
                    if let id: Int = item["id"] as? Int, let previewFileURL: String = item["preview_file_url"] as? String, let fileURL: String = item["file_url"] as? String {
                        let post: Post = Post(id: id, tagString: nil, fileURL: fileURL, largeFileURL: nil, previewFileURL: previewFileURL)
                        if let largeFileURL: String = item["large_file_url"] as? String {
                            post.largeFileURL = largeFileURL
                        }
                        if let tagString: String = item["tag_string"] as? String {
                            post.tagString = tagString
                        }
                        return post
                    } else {
                        return nil
                    }
                })
            case .gelbooru:
                guard let arrData: [[String: Any]] = data as? [[String: Any]] else {
                    return []
                }
                return arrData.flatMap({ (item) -> Post? in
                    if let id: Int = item["id"] as? Int, let previewFileURL: String = item["file_url"] as? String, let fileURL: String = item["file_url"] as? String {
                        let post: Post = Post(id: id, tagString: nil, fileURL: fileURL, largeFileURL: nil, previewFileURL: previewFileURL)
                        if let largeFileURL: String = item["file_url"] as? String {
                            post.largeFileURL = largeFileURL
                        }
                        if let tagString: String = item["tags"] as? String {
                            post.tagString = tagString
                        }
                        return post
                    } else {
                        return nil
                    }
                })
            case .yandere, .kochan:
                guard let arrData: [[String: Any]] = data as? [[String: Any]] else {
                    return []
                }
                return arrData.flatMap({ (item) -> Post? in
                    if let id: Int = item["id"] as? Int, let previewFileURL: String = item["preview_url"] as? String, let fileURL: String = item["file_url"] as? String {
                        let post: Post = Post(id: id, tagString: nil, fileURL: fileURL, largeFileURL: nil, previewFileURL: previewFileURL)
                        if let largeFileURL: String = item["file_url"] as? String {
                            post.largeFileURL = largeFileURL
                        }
                        if let tagString: String = item["tags"] as? String {
                            post.tagString = tagString
                        }
                        return post
                    } else {
                        return nil
                    }
                })
            }
        }
    }
}

// MARK: - Handle Error
extension TESTClient {
    fileprivate func handleError(error: Error) -> Error {
        if let error = error as? AFError {
            if error.isResponseSerializationError {
                print("ERROR: RESTClient Serialization Error HTML Responce")
            } else if error.isResponseValidationError {
                print("ERROR: RESTClient Validation Error HTML Responce")
            } else if error.isMultipartEncodingError {
                print("ERROR: RESTClient Multipart Encoding Error")
            } else if error.isParameterEncodingError {
                print("ERROR: RESTClient Parameter Encoding Error")
            } else if error.isInvalidURLError {
                print("ERROR: RESTClient InvalidURL Error")
            }
            let meta: RESTMeta = RESTMeta(statusCode: 1000)
            return RESTError(statusCode: meta.statusCode, title: meta.title, message: meta.message, type: meta.type)
        }
        print("ERROR: RESTClient Unknown Error : \(error.localizedDescription)")
        return error
    }
    
}
