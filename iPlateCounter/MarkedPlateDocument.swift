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
        guard self.image != nil else { return }
        plate.addMark(x: Int(center.x), y: Int(center.y), diameter: Double(diameter))
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
