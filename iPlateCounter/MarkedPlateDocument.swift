import SwiftUI

class MarkedPlateDocument: ObservableObject {
    @Published private var plate = MarkedPlate()
    @Published var images: [UIImage] = [] {
        didSet {
            clearMarks()
        }
    }
    var image: UIImage? { images.first }
    
    var marks: [MarkedPlate.Mark] { plate.marks }
    
    func addMark(at center: CGPoint, diameter: CGFloat) {
        guard image != nil, 0..<image!.size.width ~= center.x, 0..<image!.size.height ~= center.y else { return }
        plate.addMark(x: Int(center.x), y: Int(center.y), diameter: Double(diameter))
    }

    func removeMark(_ mark: MarkedPlate.Mark) {
        plate.marks.removeAll { $0.id == mark.id }
    }

    func dropLastMark() {
        _ = plate.marks.popLast()
    }
    
    func clearMarks() {
        plate.marks.removeAll()
    }    
}


extension MarkedPlate.Mark {
    var size: CGFloat { CGFloat(self.diameter) }
    var location: CGPoint { CGPoint(x: CGFloat(self.x), y: CGFloat(self.y)) }
}
