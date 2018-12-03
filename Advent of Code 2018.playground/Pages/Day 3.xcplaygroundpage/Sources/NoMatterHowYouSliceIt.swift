import Foundation

public struct Point : Hashable {
    let x: Int
    let y: Int
}

public struct Claim : CustomStringConvertible {
    let id: String?
    let x: Int
    let y: Int
    let width: Int
    let height: Int
    
    var minX: Int {
        return min(x, x + width)
    }
    
    var maxX: Int {
        return max(x, x + width)
    }
    
    var minY: Int {
        return min(y, y + height)
    }
    
    var maxY: Int {
        return max(y, y + height)
    }
    
    public var description: String {
        guard let id = id else {
            return "\(x),\(y): \(width)x\(height)"
        }
        
        return "#\(id) @ \(x),\(y): \(width)x\(height)"
    }
    
    var points: [Point] {
        var result: [Point] = []
        
        for pX in minX..<maxX {
            for pY in minY..<maxY {
                result.append(Point(x: pX, y: pY))
            }
        }
        
        return result
    }
    
    func intersects(_ claim: Claim) -> Bool {
        return !(maxX <= claim.minX || claim.maxX <= minX || maxY <= claim.minY || claim.maxY <= minY)
    }
    
    func intersection(_ claim: Claim) -> Claim? {
        guard intersects(claim) else {
            return nil
        }
        
        let newMinX = max(minX, claim.minX)
        let newMaxX = min(maxX, claim.maxX)
        let newMinY = max(minY, claim.minY)
        let newMaxY = min(maxY, claim.maxY)
        
        let w = newMaxX - newMinX
        let h = newMaxY - newMinY
        
        return Claim(id: nil, x: newMinX, y: newMinY, width: w, height: h)
    }
}

extension Claim {
    public init?(_ line: String) {
        guard let regex = try? NSRegularExpression(pattern: "^#(?<id>\\d+) @ (?<x>\\d+),(?<y>\\d+): (?<w>\\d+)x(?<h>\\d+)$", options: []) else {
            return nil
        }
        
        let range = NSRange(location: 0, length: line.utf16.count)
        let matches = regex.matches(in: line, options: [], range: range)
        
        guard let match = matches.first, match.numberOfRanges == 6 else {
            return nil
        }
        
        let idRange = match.range(withName: "id")
        let xRange = match.range(withName: "x")
        let yRange = match.range(withName: "y")
        let wRange = match.range(withName: "w")
        let hRange = match.range(withName: "h")
        
        func getRange(_ text: String, _ range: NSRange) -> String {
            let start = text.utf16.index(text.utf16.startIndex, offsetBy: range.location)
            let end = text.utf16.index(text.utf16.startIndex, offsetBy: range.location + range.length)
            return String(text[start..<end])
        }
        
        guard let x = Int(getRange(line, xRange)),
            let y = Int(getRange(line, yRange)),
            let w = Int(getRange(line, wRange)),
            let h = Int(getRange(line, hRange)) else {
                return nil
        }
        
        let id = getRange(line, idRange)
        self.init(id: id, x: x, y: y, width: w, height: h)
    }
}

public func part1(_ claims: [Claim]) -> Int {
    var intersections: Set<Point> = []
    
    for (offset, claim) in claims.enumerated() {
        for index in offset.advanced(by: 1)..<claims.count {
            let other = claims[index]
            
            guard let intersection = claim.intersection(other) else {
                continue
            }
            
            intersections.formUnion(intersection.points)
        }
    }
    
    return intersections.count
}

public func part2(_ claims: [Claim]) -> String {
    for claim in claims {
        var success = true
        
        for other in claims {
            guard claim.id != other.id else {
                continue
            }
            
            if claim.intersects(other) {
                success = false
                break
            }
        }
        
        if let id = claim.id, success {
            return id
        }
    }
    
    fatalError()
}
