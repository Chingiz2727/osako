import UIKit
import SDWebImage

public func setImage(with url: URL?, in imageView: UIImageView) {
    setImage(with: url, in: imageView, placeholder: nil)
}

public func setImage(with url: URL?, in imageView: UIImageView, placeholder: @autoclosure () -> UIImage?) {
    let options: SDWebImageOptions = [.refreshCached,.retryFailed]
    imageView.sd_setImage(with: url, placeholderImage: placeholder(), options: options) { image, error, cache, resultUrl in
        
    }
}
