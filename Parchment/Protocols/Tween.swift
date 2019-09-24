import Foundation
import UIKit

func tween(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
  return ((to - from) * progress) + from
}
