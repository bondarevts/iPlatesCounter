import SwiftUI

class MarkedPlateDocument: ObservableObject {
    @Published private var plate = MarkedPlate()
    @Published var images: [UIImage] = []
    
    var marks: [MarkedPlate.Mark] { plate.marks }
    
    func addMark(at center: CGPoint, diameter: CGFloat) {
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
    var s: CGFloat { CGFloat(self.diameter) }
    var location: CGPoint { CGPoint(x: CGFloat(self.x), y: CGFloat(self.y)) }
}
