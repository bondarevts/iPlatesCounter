import SwiftUI

class MarkedPlateDocument: ObservableObject {
    @Published private var plate = MarkedPlate()
    @Published var images: [UIImage] = []
    
    var marks: [MarkedPlate.Mark] { plate.marks }
    
    func addMark(at location: CGPoint, size: CGFloat) {
        plate.addMark(x: Int(location.x), y: Int(location.y), size: Double(size))
    }
    
    func dropLastMark() {
        _ = plate.marks.popLast()
    }
    
    func clearMarks() {
        plate.marks.removeAll()
    }
    
}


extension MarkedPlate.Mark {
    var s: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(self.x), y: CGFloat(self.y)) }
}
