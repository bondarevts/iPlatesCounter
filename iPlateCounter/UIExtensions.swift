import SwiftUI

extension CGSize {
    static func +(size1: Self, size2: Self) -> CGSize {
        CGSize(width: size1.width + size2.width, height: size1.height + size2.height)
    }

    static func -(size1: Self, size2: Self) -> CGSize {
        CGSize(width: size1.width - size2.width, height: size1.height - size2.height)
    }

    static func *(size: Self, value: CGFloat) -> CGSize {
        CGSize(width: size.width * value, height: size.height * value)
    }

    static func /(size: Self, value: CGFloat) -> CGSize {
        CGSize(width: size.width / value, height: size.height / value)
    }

    static prefix func -(size: Self) -> CGSize {
        CGSize(width: -size.width, height: -size.height)
    }
}

extension CGPoint {
    static func *(point: Self, value: CGFloat) -> CGPoint {
        CGPoint(x: point.x * value, y: point.y * value)
    }

    static func /(point: Self, value: CGFloat) -> CGPoint {
        CGPoint(x: point.x / value, y: point.y / value)
    }

    static func -(point: Self, value: CGFloat) -> CGPoint {
        CGPoint(x: point.x - value, y: point.y - value)
    }

    static func +(point1: Self, point2: CGPoint) -> CGPoint {
        CGPoint(x: point1.x + point2.x, y: point1.y + point2.y)
    }

    func offset(with size: CGSize) -> CGPoint {
        CGPoint(x: x + size.width, y: y + size.height)
    }

    init(from size: CGSize) {
        self.init(x: size.width, y: size.height)
    }
}

extension View {
    func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        self.frame(width: size.width, height: size.height, alignment: alignment)
    }
}
