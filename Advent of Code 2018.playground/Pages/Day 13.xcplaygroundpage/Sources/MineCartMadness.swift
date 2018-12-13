import Foundation

public typealias Track = [[TrackPiece?]]
public typealias Carts = [Cart]
public typealias Point = (x: Int, y: Int)

public struct Cart {
    var direction: Direction
    var position: Point
    var turns: Int = 0
}

extension Cart {
    init?(_ character: Character, position: Point) {
        switch character {
        case "^":
            self.init(direction: .north, position: position, turns: 0)
        case ">":
            self.init(direction: .east, position: position, turns: 0)
        case "v":
            self.init(direction: .south, position: position, turns: 0)
        case "<":
            self.init(direction: .west, position: position, turns: 0)
        default:
            return nil
        }
    }
    
    mutating func turnAtIntersection() {
        switch turns % 3 {
        case 0:
            direction = direction.left
        case 2:
            direction = direction.right
        default:
            break
        }
        
        turns += 1
    }
    
    mutating func turn(trackPiece: TrackPiece) {
        switch trackPiece {
        case .leftCorner where direction == .north, .rightCorner where direction == .south:
            direction = .west
        case .leftCorner where direction == .east, .rightCorner where direction == .west:
            direction = .south
        case .leftCorner where direction == .south, .rightCorner where direction == .north:
            direction = .east
        case .leftCorner where direction == .west, .rightCorner where direction == .east:
            direction = .north
        case .crossroads:
            turnAtIntersection()
        default:
            fatalError("Can't turn here")
        }
    }
    
    mutating func move(on track: Track) {
        let (trackPiece, location) = nextTrackPiece(on: track)
        position = location
        
        switch trackPiece {
        case .crossroads, .leftCorner, .rightCorner:
            turn(trackPiece: trackPiece)
        default:
            break
        }
    }
    
    func nextTrackPiece(on track: Track) -> (trackPiece: TrackPiece, location: Point) {
        let coordinate: Point
        
        switch direction {
        case .north:
            coordinate = (position.x, position.y - 1)
        case .east:
            coordinate = (position.x + 1, position.y)
        case .south:
            coordinate = (position.x, position.y + 1)
        case .west:
            coordinate = (position.x - 1, position.y)
        }
        
        guard let trackPiece = track[coordinate] else {
            fatalError("Somehow left the track")
        }
        
        return (trackPiece, coordinate)
    }
}

extension Cart {
    var icon: Character {
        switch direction {
        case .north:
            return "^"
        case .east:
            return ">"
        case .south:
            return "v"
        case .west:
            return "<"
        }
    }
}

extension Cart : Equatable {
    public static func == (lhs: Cart, rhs: Cart) -> Bool {
        return lhs.direction == rhs.direction && lhs.position == rhs.position
    }
}

extension Cart : Comparable {
    public static func < (lhs: Cart, rhs: Cart) -> Bool {
        if lhs.position.y == rhs.position.y {
            return lhs.position.x < rhs.position.x
        }
        
        return lhs.position.y < rhs.position.y
    }
}

public enum Direction {
    case north, east, south, west
}

extension Direction {
    var left: Direction {
        switch self {
        case .north:
            return .west
        case .east:
            return .north
        case .south:
            return .east
        case .west:
            return .south
        }
    }
    
    var right: Direction {
        switch self {
        case .north:
            return .east
        case .east:
            return .south
        case .south:
            return .west
        case .west:
            return .north
        }
    }
    
    func move(point: Point) -> Point {
        switch self {
        case .north:
            return (point.x, point.y - 1)
        case .east:
            return (point.x + 1, point.y)
        case .south:
            return (point.x, point.y + 1)
        case .west:
            return (point.x - 1, point.y)
        }
    }
}

public enum TrackPiece : Character {
    case leftCorner = "\\"
    case rightCorner = "/"
    case verticalTrack = "|"
    case horizontalTrack = "-"
    case crossroads = "+"
    
    init?(_ character: Character) {
        switch character {
        case "^", "v":
            self = .verticalTrack
        case "<", ">":
            self = .horizontalTrack
        default:
            self.init(rawValue: character)
        }
    }
}

extension Array where Element == Cart {
    func getCollision() -> Point? {
        for (offset, cart) in enumerated() {
            for index in index(after: offset)..<endIndex {
                let other = self[index]
                if cart.position == other.position {
                    return cart.position
                }
            }
        }
        
        return nil
    }
    
    subscript(_ point: Point) -> Index? {
        for (index, cart) in enumerated() {
            if cart.position == point {
                return index
            }
        }
        
        return nil
    }
}

extension Array where Element == [TrackPiece?] {
    subscript(_ point: Point) -> TrackPiece? {
        return self[point.y][point.x]
    }
}

func output(track: Track, carts: Carts) -> String {
    var characters: [[Character]] = []
    
    for row in track {
        let rowCharacters = row.map { $0?.rawValue ?? " " }
        characters.append(rowCharacters)
    }
    
    for cart in carts {
        let position = cart.position
        characters[position.y][position.x] = cart.icon
    }
    
    return characters.map { String($0) }.joined(separator: "\n")
}

public func parseTrack(_ input: String) -> (track: Track, carts: Carts) {
    let lines = input.components(separatedBy: .newlines)
    let characters = lines.map { Array($0) }
    
    var track: Track = []
    var carts: Carts = []
    
    for (y, row) in characters.enumerated() {
        var trackRow: [TrackPiece?] = []
        
        for (x, character) in row.enumerated() {
            let point = (x, y)
            let trackPiece = TrackPiece(character)
            trackRow.append(trackPiece)
            
            if let cart = Cart(character, position: point) {
                carts.append(cart)
            }
        }
        
        track.append(trackRow)
    }
    
    return (track, carts)
}

public func part1(track: Track, carts: Carts) -> Point {
    var carts = carts
    
    for _ in 1... {
        var newCarts: Carts = []
        carts.sort()
        
        while !carts.isEmpty {
            var cart = carts.removeFirst()
            cart.move(on: track)
            newCarts.append(cart)
            
            let allCarts = carts + newCarts
            if let collision = allCarts.getCollision() {
                return collision
            }
        }
        
        carts = newCarts
    }
    
    fatalError()
}

public func part2(track: Track, carts: Carts) -> Point {
    var carts = carts
    
    for _ in 1... {
        var newCarts: Carts = []
        carts.sort()
        
        while !carts.isEmpty {
            var cart = carts.removeFirst()
            cart.move(on: track)
            newCarts.append(cart)
            
            let allCarts = carts + newCarts
            
            if let collision = allCarts.getCollision() {
                while let index = carts[collision] {
                    carts.remove(at: index)
                }
                
                while let index = newCarts[collision] {
                    newCarts.remove(at: index)
                }
            }
        }
        
        if newCarts.count == 1 {
            return newCarts.first!.position
        }
        
        carts = newCarts
    }
    
    fatalError()
}
