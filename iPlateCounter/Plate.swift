import Foundation


struct MarkedPlate {
    var marks: [Mark] = []
    
    private var uniqueMarkId = 0
    mutating func addMark(x: Int, y: Int, size: Double) {
        uniqueMarkId += 1
        marks.append(Mark(id: uniqueMarkId, x: x, y: y, size: size))
    }
    
    struct Mark: Identifiable, Hashable {
        let id: Int
        let x: Int
        let y: Int
        let size: Double
        
        fileprivate init(id: Int, x: Int, y: Int, size: Double) {
            self.id = id
            self.x = x
            self.y = y
            self.size = size
        }
    }
}
