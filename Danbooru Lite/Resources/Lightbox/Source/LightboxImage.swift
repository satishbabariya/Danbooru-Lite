import UIKit

open class LightboxImage {

  open fileprivate(set) var image: UIImage?
  open fileprivate(set) var imageURL: URL?
  open fileprivate(set) var videoURL: URL?
  open var text: String

  // MARK: - Initialization

  public init(image: UIImage, text: String = "", videoURL: URL? = nil) {
    self.image = image
    self.text = text
    self.videoURL = videoURL
  }

  public init(imageURL: URL, text: String = "", videoURL: URL? = nil) {
    self.imageURL = imageURL
    self.text = text
    self.videoURL = videoURL
  }
}
