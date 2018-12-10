import Foundation

let pattern = "^position=<\\s*(?<x>-?\\d+),\\s*(?<y>-?\\d+)> velocity=<\\s*(?<dx>-?\\d+),\\s*(?<dy>-?\\d+)>$"
let regex = try! NSRegularExpression(pattern: pattern, options: [])

struct Position {
    let x: Int
    let y: Int
}

public struct Point {
    let origin: Position
    let dx: Int
    let dy: Int
}

extension Point {
    func position(at t: Int) -> Position {
        let x = origin.x + (t * dx)
        let y = origin.y + (t * dy)
        return Position(x: x, y: y)
    }
}

extension Point {
    public init(_ description: String) {
        let range = NSRange(location: 0, length: description.utf16.count)
        
        guard let matches = regex.firstMatch(in: description, options: [], range: range) else {
            fatalError()
        }
        
        let xRange = matches.range(withName: "x")
        let yRange = matches.range(withName: "y")
        let dxRange = matches.range(withName: "dx")
        let dyRange = matches.range(withName: "dy")
        
        func getRange(_ text: String, _ range: NSRange) -> String {
            let start = text.utf16.index(text.utf16.startIndex, offsetBy: range.location)
            let end = text.utf16.index(text.utf16.startIndex, offsetBy: range.location + range.length)
            return String(text[start..<end])
        }
        
        let x = Int(getRange(description, xRange))!
        let y = Int(getRange(description, yRange))!
        origin = Position(x: x, y: y)
        dx = Int(getRange(description, dxRange))!
        dy = Int(getRange(description, dyRange))!
    }
}

func getMinimum(positions: [Position]) -> ((Int, Int), (Int, Int)) {
    let minX = positions.map { $0.x }.min()!
    let minY = positions.map { $0.y }.min()!
    let maxX = positions.map { $0.x }.max()!
    let maxY = positions.map { $0.y }.max()!
    return ((minX, minY), (maxX, maxY))
}

public func draw(points: [Point], atTime t: Int) -> String {
    let positionsAtTime = points.map { $0.position(at: t) }
    let ((minX, minY), (maxX, maxY)) = getMinimum(positions: positionsAtTime)
    let width = maxX - minX + 1
    let height = maxY - minY + 1
    
    var grid = Array(repeating: Array(repeating: Character(" "), count: width), count: height)
    
    for point in positionsAtTime {
        let x = point.x - minX
        let y = point.y - minY
        
        grid[y][x] = "█"
    }
    
    return grid.map { String($0) }.joined(separator: "\n")
}

public func findSmallestTime(points: [Point]) -> Int {
    var dxMin = Int.max
    var dyMin = Int.max
    
    for t in 0... {
        let positionsAtTime = points.map { $0.position(at: t) }
        let ((minX, minY), (maxX, maxY)) = getMinimum(positions: positionsAtTime)
        let dx = maxX - minX
        let dy = maxY - minY
        
        if dx > dxMin || dy > dyMin {
            return t - 1
        }
        
        dxMin = dx
        dyMin = dy
    }
    
    fatalError()
}
