import Foundation

public struct Point {
    let x: Int
    let y: Int
}

extension Point : Equatable {
}

extension Point : Hashable {
}

extension Point : CustomStringConvertible {
    public var description: String {
        return "(\(x), \(y))"
    }
}

extension Point {
    public init?(_ description: String) {
        let components = description.components(separatedBy: ", ")
        
        guard components.count == 2, let x = Int(components[0]), let y = Int(components[1]) else {
            return nil
        }
        
        self.init(x: x, y: y)
    }
    
    func distance(to other: Point) -> Int {
        return abs(other.x - x) + abs(other.y - y)
    }
}

func bounds(for points: [Point]) -> (minX: Int, minY: Int, maxX: Int, maxY: Int) {
    let minX = points.reduce(Int.max) { min($0, $1.x) }
    let maxX = points.reduce(Int.min) { max($0, $1.x) }
    let minY = points.reduce(Int.max) { min($0, $1.y) }
    let maxY = points.reduce(Int.min) { max($0, $1.y) }
    return (minX, minY, maxX, maxY)
}

func closestPoints(_ points: [Point]) -> [Point : Point?] {
    let (minX, minY, maxX, maxY) = bounds(for: points)
    
    var distances: [Point : [Point : Int]] = [:]
    
    for x in minX...maxX {
        for y in minY...maxY {
            let target = Point(x: x, y: y)
            var targetValues: [Point : Int] = [:]
            
            for point in points {
                let distance = point.distance(to: target)
                targetValues[point] = distance
            }
            
            distances[target] = targetValues
        }
    }
    
    return distances.mapValues { targetValues in
        guard let min = targetValues.min(by: { $0.value < $1.value }) else {
            fatalError()
        }
        
        let count = targetValues.filter { $0.value == min.value }.count
        
        if count > 1 {
            return nil
        }
        
        return min.key
    }
}

func totalDistance(from target: Point, to points: [Point]) -> Int {
    return points.map { $0.distance(to: target) }.reduce(0, +)
}

public func part1(_ points: [Point]) -> Int {
    let (minX, minY, maxX, maxY) = bounds(for: points)
    let closest = closestPoints(points)
    
    var infinitePoints: Set<Point> = []
    
    for x in minX...maxX {
        for y in minY...maxY {
            if x == minX || x == maxX || y == minY || y == maxY {
                let target = Point(x: x, y: y)
                
                guard let closestPoint = closest[target], let infinitePoint = closestPoint else {
                    continue
                }
                
                infinitePoints.insert(infinitePoint)
            }
        }
    }
    
    let finitePoints = closest.compactMap { $0.value }
        .filter { !infinitePoints.contains($0) }
    
    let counts = Dictionary(grouping: finitePoints, by: { $0 })
        .mapValues { $0.count }
    
    guard let result = counts.values.max() else {
        fatalError()
    }
    
    return result
}

public func part2(_ points: [Point], limit: Int) -> Int {
    let (minX, minY, maxX, maxY) = bounds(for: points)
    var result = 0
    
    for x in minX...maxX {
        for y in minY...maxY {
            let point = Point(x: x, y: y)
            let total = totalDistance(from: point, to: points)
            
            if total < limit {
                result += 1
            }
        }
    }
    
    return result
}
