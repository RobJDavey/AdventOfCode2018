import Foundation

enum Direction : Character {
    case north = "N"
    case east = "E"
    case south = "S"
    case west = "W"
}

extension Direction : CustomStringConvertible {
    var description: String {
        return "\(rawValue)"
    }
}

struct Point {
    let x: Int
    let y: Int
    
    var adjacent: Set<Point> {
        return [
            Point(x: x - 1, y: y),
            Point(x: x + 1, y: y),
            Point(x: x, y: y - 1),
            Point(x: x, y: y + 1),
        ]
    }
}

extension Point : Hashable {
}

extension Point {
    func move(_ direction: Direction, doors: inout Set<Point>) -> Point {
        let door: Point
        let result: Point
        
        switch direction {
        case .north:
            door = Point(x: x, y: y - 1)
            result = Point(x: x, y: y - 2)
        case .east:
            door = Point(x: x + 1, y: y)
            result = Point(x: x + 2, y: y)
        case .south:
            door = Point(x: x, y: y + 1)
            result = Point(x: x, y: y + 2)
        case .west:
            door = Point(x: x - 1, y: y)
            result = Point(x: x - 2, y: y)
        }
        
        doors.insert(door)
        return result
    }
}

protocol Expression {
    func evaluate(locations: Set<Point>, distance: inout Int, furthest: inout Point, doors: inout Set<Point>) -> Set<Point>
}

struct DirectionExpression : Expression {
    let direction: Direction
    
    func evaluate(locations: Set<Point>, distance: inout Int, furthest: inout Point, doors: inout Set<Point>) -> Set<Point> {
        precondition(locations.count == 1)
        let newLocations = Set(locations.map { $0.move(direction, doors: &doors) })
        distance += 1
        furthest = newLocations.first!
        return newLocations
    }
}

struct OptionExpression : Expression {
    let options: [Expression]
    
    func evaluate(locations: Set<Point>, distance: inout Int, furthest: inout Point, doors: inout Set<Point>) -> Set<Point> {
        var result: Set<Point> = []
        var best = distance
        var furthestPoint = furthest
        
        for option in options {
            var optionDistance = distance
            var optionFurthest = furthest
            let output = option.evaluate(locations: locations, distance: &optionDistance, furthest: &optionFurthest, doors: &doors)
            result = result.union(output)
            
            if optionDistance > best {
                best = optionDistance
                furthestPoint = optionFurthest
            }
            
            best = max(best, optionDistance)
        }
        
        distance = best
        furthest = furthestPoint
        
        return result
    }
}

struct SequenceExpression : Expression {
    let children: [Expression]
    
    func evaluate(locations: Set<Point>, distance: inout Int, furthest: inout Point, doors: inout Set<Point>) -> Set<Point> {
        var current = locations
        
        for child in children {
            current = child.evaluate(locations: current, distance: &distance, furthest: &furthest, doors: &doors)
        }
        
        return current
    }
}

func readExpression(in text: String, index: inout String.Index) -> Expression {
    var children: [Expression] = []
    var current: [Expression] = []
    
    while index < text.endIndex {
        let character = text[index]
        index = text.index(after: index)
        
        switch character {
        case "^":
            continue
        case "|":
            let sequence = SequenceExpression(children: current)
            children.append(sequence)
            current = []
        case "(":
            let child = readExpression(in: text, index: &index)
            current.append(child)
        case "$", ")":
            let sequence = SequenceExpression(children: current)
            children.append(sequence)
            return OptionExpression(options: children)
        default:
            let direction = Direction(rawValue: character)!
            let expression = DirectionExpression(direction: direction)
            current.append(expression)
        }
    }
    
    fatalError()
}

func draw(doors: Set<Point>) -> String {
    precondition(!doors.isEmpty)
    let xValues = doors.map { $0.x }
    let yValues = doors.map { $0.y }
    
    let xMin = xValues.min()! - 1
    let xMax = xValues.max()! + 1
    let yMin = yValues.min()! - 1
    let yMax = yValues.max()! + 1
    
    var result: [[Character]] = []
    
    for y in yMin...yMax {
        var row: [Character] = []
        
        for x in xMin...xMax {
            let point = Point(x: x, y: y)
            let xMod = x % 2
            let yMod = y % 2
            
            if x == 0 && y == 0 {
                row.append("X")
            } else if xMod == 1 && yMod == 1 {
                row.append("#")
            } else if doors.contains(point) {
                row.append(xMod == 0 ? "-" : "|")
            } else if xMod == 0 && yMod == 0 {
                row.append(".")
            } else {
                row.append("#")
            }
        }
        
        result.append(row)
    }
    
    return result.map { String($0) }.joined(separator: "\n")
}

func calculateDistances(from start: Point, to end: Point, with doors: Set<Point>) -> [Point : Int] {
    var result: [Point : Int] = [start : 0]
    
    for distance in 0... {
        let current = Set(result.filter { $0.value == distance }.keys)
        
        if current.isEmpty {
            break
        }
        
        for item in current {
            for yOffset in -1...1 {
                for xOffset in -1...1 {
                    if xOffset != 0 && yOffset != 0 {
                        continue
                    }
                    
                    let doorPoint = Point(x: item.x + xOffset, y: item.y + yOffset)
                    guard doors.contains(doorPoint) else {
                        continue
                    }
                    
                    let xRoomOffset = xOffset * 2
                    let yRoomOffset = yOffset * 2
                    let roomPoint = Point(x: item.x + xRoomOffset, y: item.y + yRoomOffset)
                    
                    if let _ = result[roomPoint] {
                        continue
                    }
                    
                    result[roomPoint] = distance + 1
                }
            }
        }
    }
    
    return result
}

public func run(_ description: String) -> (answer1: Int, answer2: Int) {
    var index = description.startIndex
    let sequence = readExpression(in: description, index: &index)
    
    let origin = Point(x: 0, y: 0)
    let start: Set<Point> = [origin]
    var furthest = origin
    var distance = 0
    var doors: Set<Point> = []
    let _ = sequence.evaluate(locations: start, distance: &distance, furthest: &furthest, doors: &doors)
    let distances = calculateDistances(from: origin, to: furthest, with: doors)
    
    let answer1 = distances[furthest]!
    let answer2 = distances.filter { $0.value >= 1000 }.count
    return (answer1, answer2)
}
