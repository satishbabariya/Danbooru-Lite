//
//  RESTClient.swift
//  Danbooru
//
//  Created by Satish on 01/04/18.
//  Copyright © 2018 Satish Babariya. All rights reserved.
//

import Alamofire
import Foundation
import Reachability
import RxSwift

enum RESTClient {

    case posts(limit: Int, page: Int, tags: String?)
    case tagsAutoComplete(name: String)
    case flickrSearch(limit: Int, page: Int, name: String)
}

extension RESTClient {

    fileprivate var path: String {
        switch self {
        case .posts(let limit, let page, let tags):
            var endpoint: String = ""
            switch Application.Service.get() {
            case .flickr:
                endpoint = "?method=flickr.interestingness.getList&api_key=97adbb4e968f8802d83ef157d53b3862&per_page=\(limit)&page=\(page)&format=json&nojsoncallback=1"
            case .danbooru:
                endpoint = "posts.json?limit=\(limit)&page=\(page)"
            case .gelbooru:
                endpoint = "index.php?page=dapi&s=post&q=index&json=1&pid=\(page)"
            case .yandere, .kochan:
                endpoint = "post.json?limit=\(limit)&page=\(page)"
            }
            if let tags = tags {
                endpoint += "&tags=\(tags)"
            }
            return endpoint
        case .tagsAutoComplete(let name):
            switch Application.Service.get() {
            case .flickr:
                return ""
            case .danbooru:
                return "tags/autocomplete.json?search[name_matches]=\(name)"
            case .gelbooru:
                return "tags/autocomplete.json?search[name_matches]=\(name)"
            case .yandere, .kochan:
                return "tag.json?name=\(name)"
            }
        case .flickrSearch(limit: let limit, page: let page, name: let name):
            switch Application.Service.get() {
            case .flickr:
                return "?api_key=97adbb4e968f8802d83ef157d53b3862&content_type=1&format=json&method=flickr.photos.search&nojsoncallback=1&page=\(page)&per_page=\(limit)&privacy_filter=1&text=\(name)"
            case .danbooru:
                return "tags/autocomplete.json?search[name_matches]=\(name)"
            case .gelbooru:
                return "index.php?page=dapi&s=post&q=index&json=1&pid=\(page)&tags=\(name)"
            case .yandere, .kochan:
                return "tag.json?name=\(name)"
            }
        }
    }

    fileprivate var method: HTTPMethod {
        return .get
    }

    fileprivate var baseURL: String {
        return Application.Service.url()
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
        return Observable.create({ (observer) -> Disposable in
            Alamofire.request(self.url, method: self.method, parameters: nil, encoding: JSONEncoding.default, headers: nil)
                .responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let jsonResponse):
                    do {
                        observer.onNext(try self.handleResponce(responce: response.response ?? HTTPURLResponse(), data: jsonResponse))
                        observer.onCompleted()
                    } catch let e as RESTError {
                        observer.onError(e)
                    } catch {
                        observer.onError(error)
                    }
                case .failure(let error):
                    observer.onError(self.handleError(error: error))
                }
            })

            return Disposables.create()
        })
    }

}

// MARK: - Handle Responce
extension RESTClient {

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
        case .posts:
            switch Application.Service.get() {
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
        case .tagsAutoComplete:
            guard let arrData: [[String: Any]] = data as? [[String: Any]] else {
                return []
            }
            return arrData.flatMap({ (item) -> String? in
                if let name: String = item["name"] as? String {
                    return name
                } else {
                    return nil
                }
            })
        case .flickrSearch:
            switch Application.Service.get() {
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
            default:
                return []
            }
        }
    }
}

// MARK: - Handle Error
extension RESTClient {
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
