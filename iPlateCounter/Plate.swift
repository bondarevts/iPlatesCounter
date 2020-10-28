import Foundation


struct MarkedPlate {
    var marks: [Mark] = []
    
    private var uniqueMarkId = 0
    mutating func addMark(x: Int, y: Int, diameter: Double) {
        uniqueMarkId += 1
        marks.append(Mark(id: uniqueMarkId, x: x, y: y, diameter: diameter))
    }
    
    struct Mark: Identifiable, Hashable {
        let id: Int
        let x: Int  // mark center relative to the center of the image
        let y: Int
        let diameter: Double
        
        fileprivate init(id: Int, x: Int, y: Int, diameter: Double) {
            self.id = id
            self.x = x
            self.y = y
            self.diameter = diameter
        }
    }
}
