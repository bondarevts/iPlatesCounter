import Foundation


struct MarkedPlate {
    var marks: [Mark] = [
        Mark(id:1000, x: 0, y: 0, diameter: 100),
        Mark(id:1001, x: -50, y: -50, diameter: 10),
        Mark(id:1002, x: 50, y: -50, diameter: 10),
        Mark(id:1003, x: -50, y: 50, diameter: 10),
        Mark(id:1004, x: 50, y: 50, diameter: 10),
    ]
    
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
