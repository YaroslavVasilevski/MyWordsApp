import Foundation
import UIKit


class Images {
    enum ImageNames {
        case bellImage
        case bellSlashImage
        case gearshapeImage
        case arrowImage
        
        var image: UIImage {
            switch self {
            case .bellImage:
                return UIImage(systemName: "bell")!
            case .bellSlashImage:
                return UIImage(systemName: "bell.slash")!
            case .gearshapeImage:
                return UIImage(systemName: "gearshape")!
            case .arrowImage:
                return UIImage(systemName: "arrow.left.circle")!
            }
        }
    }
}
