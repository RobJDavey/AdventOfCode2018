import Foundation

typealias TileDictionary = [Point : TileType]

public struct Point {
    let x: Int
    let y: Int
}

extension Point : Hashable {
}

public enum TileType : Character {
    case waterSpring = "+"
    case clay = "#"
    case sand = "."
    case water = "~"
    case waterSand = "|"
}

public struct Tile {
    let type: TileType
    let position: Point
}

extension Tile : Hashable {
}

public func parse(_ input: String) -> Set<Tile> {
    let lines = input.components(separatedBy: .newlines)
    var result: Set<Tile> = [ Tile(type: .waterSpring, position: Point(x: 500, y: 0)) ]
    
    for line in lines {
        let parts = line.components(separatedBy: ", ")
        assert(parts.count == 2)
        
        let range = parts[1].components(separatedBy: "=").last!.components(separatedBy: "..")
        assert(range.count == 2)
        
        let fixedCoordinate = parts[0].components(separatedBy: "=")
        assert(fixedCoordinate.count == 2)
        
        let makePoint: (Int, Int) -> Point
        
        if fixedCoordinate[0] == "x" {
            makePoint = { x, y in Point(x: x, y: y) }
        } else {
            makePoint = { y, x in Point(x: x, y: y) }
        }
        
        let fixed = Int(fixedCoordinate[1])!
        let rangeStart = Int(range[0])!
        let rangeEnd = Int(range[1])!
        
        for other in rangeStart...rangeEnd {
            let point = makePoint(fixed, other)
            let tile = Tile(type: .clay, position: point)
            result.insert(tile)
        }
    }
    
    return result
}

func draw(_ tiles: TileDictionary) {
    let points = Set(tiles.keys)
    let xValues = points.map { $0.x }
    let yValues = points.map { $0.y }
    
    let minX = xValues.min()! - 1
    let minY = yValues.min()!
    let maxX = xValues.max()! + 1
    let maxY = yValues.max()!
    
    for y in minY...maxY {
        for x in minX...maxX {
            let point = Point(x: x, y: y)
            let tile = tiles[point, default: .sand]
            print(tile.rawValue, terminator: "")
        }
        
        print()
    }
    
    print()
}

func canFlowDown(from point: Point, tiles: [Point : TileType], valid: Set<TileType> = [.sand]) -> Bool {
    let pointBelow = Point(x: point.x, y: point.y + 1)
    let value = tiles[pointBelow, default: .sand]
    return valid.contains(value)
}

func canFlowLeft(from point: Point, tiles: [Point : TileType]) -> Bool {
    var point = point
    var value: TileType
    
    repeat {
        point = Point(x: point.x - 1, y: point.y)
        
        if canFlowDown(from: point, tiles: tiles) {
            return true
        }
        
        value = tiles[point, default: .sand]
    } while value != .clay
    
    return false
}

func canFlowRight(from point: Point, tiles: [Point : TileType]) -> Bool {
    var point = point
    var value: TileType
    
    repeat {
        point = Point(x: point.x + 1, y: point.y)
        
        if canFlowDown(from: point, tiles: tiles) {
            return true
        }
        
        value = tiles[point, default: .sand]
    } while value != .clay
    
    return false
}

func flowDown(from point: inout Point, tiles: inout TileDictionary) {
    let pointBelow = Point(x: point.x, y: point.y + 1)
    tiles[pointBelow, default: .sand] = .waterSand
    point = pointBelow
}

func fillLevel(from point: inout Point, tiles: inout TileDictionary) {
    var currentPoint = point
    tiles[point] = .sand
    point = Point(x: point.x, y: point.y - 1)
    
    repeat {
        let leftPoint = Point(x: currentPoint.x - 1, y: currentPoint.y)
        let currentTile = tiles[leftPoint, default: .sand]
        
        guard currentTile != .clay else {
            break
        }
        
        currentPoint = leftPoint
    } while true
    
    repeat {
        tiles[currentPoint, default: .sand] = .water
        currentPoint = Point(x: currentPoint.x + 1, y: currentPoint.y)
    } while tiles[currentPoint, default: .sand] != .clay
}

func fillFlowRight(from point: inout Point, tiles: inout TileDictionary) {
    tiles[point] = .sand
    
    repeat {
        let leftPoint = Point(x: point.x - 1, y: point.y)
        let currentTile = tiles[leftPoint, default: .sand]
        
        guard currentTile != .clay else {
            break
        }
        
        point = leftPoint
    } while true
    
    repeat {
        tiles[point, default: .sand] = .waterSand
        point = Point(x: point.x + 1, y: point.y)
    } while tiles[point, default: .sand] != .clay && !canFlowDown(from: point, tiles: tiles, valid: [.sand, .waterSand])
    
    tiles[point] = .waterSand
}

func fillFlowLeft(from point: inout Point, tiles: inout TileDictionary) {
    tiles[point] = .sand
    
    repeat {
        let rightPoint = Point(x: point.x + 1, y: point.y)
        let currentTile = tiles[rightPoint, default: .sand]
        
        guard currentTile != .clay else {
            break
        }
        
        point = rightPoint
    } while true
    
    repeat {
        tiles[point, default: .sand] = .waterSand
        point = Point(x: point.x - 1, y: point.y)
    } while tiles[point, default: .sand] != .clay && !canFlowDown(from: point, tiles: tiles, valid: [.sand, .waterSand])
    
    tiles[point] = .waterSand
}

func fillFlowBoth(from point: Point, tiles: inout TileDictionary) -> (left: Point, right: Point) {
    var point = point
    tiles[point] = .sand
    
    let left: Point
    let right: Point
    
    repeat {
        point = Point(x: point.x - 1, y: point.y)
    } while !canFlowDown(from: point, tiles: tiles, valid: [.sand, .waterSand])
    
    left = point
    
    repeat {
        tiles[point, default: .sand] = .waterSand
        point = Point(x: point.x + 1, y: point.y)
    } while !canFlowDown(from: point, tiles: tiles, valid: [.sand, .waterSand])
    
    tiles[point] = .waterSand
    right = point
    return (left, right)
}

func pourDown(from currentPoint: inout Point, tiles: inout [Point : TileType], maxY: Int) {
    while canFlowDown(from: currentPoint, tiles: tiles) {
        flowDown(from: &currentPoint, tiles: &tiles)
        if currentPoint.y > maxY {
            return
        }
    }
    
    let nextPoint = Point(x: currentPoint.x, y: currentPoint.y + 1)
    if tiles[nextPoint] == .waterSand {
        return
    }
    
    var leftAvailable: Bool
    var rightAvailable: Bool
    
    repeat {
        leftAvailable = canFlowLeft(from: currentPoint, tiles: tiles)
        rightAvailable = canFlowRight(from: currentPoint, tiles: tiles)
        
        if !leftAvailable && !rightAvailable {
            fillLevel(from: &currentPoint, tiles: &tiles)
        }
    } while !leftAvailable && !rightAvailable
    
    if leftAvailable && rightAvailable {
        var (left, right) = fillFlowBoth(from: currentPoint, tiles: &tiles)
        pourDown(from: &left, tiles: &tiles, maxY: maxY)
        pourDown(from: &right, tiles: &tiles, maxY: maxY)
    } else if leftAvailable {
        fillFlowLeft(from: &currentPoint, tiles: &tiles)
        pourDown(from: &currentPoint, tiles: &tiles, maxY: maxY)
    } else if rightAvailable {
        fillFlowRight(from: &currentPoint, tiles: &tiles)
        pourDown(from: &currentPoint, tiles: &tiles, maxY: maxY)
    }
}

public func run(_ tiles: Set<Tile>) -> (part1: Int, part2: Int) {
    let yValues = tiles.map { $0.position.y }
    let maxY = yValues.max()!
    
    var tiles = Dictionary(uniqueKeysWithValues: tiles.map { (key: $0.position, value: $0.type) })
    
    let minY = Set(tiles.filter { $0.value == .clay }.map { $0.key.y }).min()!
    let source = tiles.first { (key, value) in value == .waterSpring }!.key
    var currentPoint = source
    
    pourDown(from: &currentPoint, tiles: &tiles, maxY: maxY)
    
    let tilesInRange = tiles.filter { $0.key.y <= maxY && $0.key.y >= minY }
    let part1 = tilesInRange.filter { $0.value == .water || $0.value == .waterSand }.count
    let part2 = tilesInRange.filter { $0.value == .water }.count
    return (part1, part2)
}
