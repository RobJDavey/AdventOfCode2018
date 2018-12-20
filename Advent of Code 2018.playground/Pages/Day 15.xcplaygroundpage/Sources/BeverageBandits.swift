import Foundation

typealias Map = [Point : MapTile]
typealias Distances = [Point : UInt]
typealias Units = [Unit]

struct Point {
    let x: Int
    let y: Int
}

extension Point {
    init(_ x: Int, _ y: Int) {
        self.init(x: x, y: y)
    }
    
    var adjacent: [Point] {
        return [
            Point(x, y - 1),
            Point(x - 1, y),
            Point(x + 1, y),
            Point(x, y + 1),
        ]
    }
}

extension Point : CustomStringConvertible {
    var description: String {
        return "\(x),\(y)"
    }
}

extension Point : Comparable {
    static func < (lhs: Point, rhs: Point) -> Bool {
        if lhs.y == rhs.y {
            return lhs.x < rhs.x
        }
        
        return lhs.y < rhs.y
    }
}

extension Point : Equatable {
}

extension Point : Hashable {
}


enum MapTile : Character {
    case wall = "#"
    case openCavern = "."
}

extension Dictionary where Key == Point, Value == MapTile {
    static func parse(_ description: String) -> (map: Map, units: Units) {
        let lines = description.components(separatedBy: .newlines)
        var map: Map = [:]
        var units: Units = []
        
        for (y, line) in lines.enumerated() {
            for (x, character) in line.enumerated() {
                let position = Point(x, y)
                
                guard let mapTile = MapTile(rawValue: character) else {
                    guard let unit = Unit(character, position: position) else {
                        fatalError()
                    }
                    
                    units.append(unit)
                    map[position] = .openCavern
                    continue
                }
                
                map[position] = mapTile
            }
        }
        
        return (map, units)
    }
    
    func selectLocation(from location: Point, to locations: Set<Point>, in map: Map, with units: Units) -> Point? {
        let distances = map.calculateDistances(from: location, with: units)
        let possibleLocations = distances.filter { locations.contains($0.key) }
        
        guard !possibleLocations.isEmpty, let min = possibleLocations.map({ $0.value }).min() else {
            return nil
        }
        
        let nearest = possibleLocations.filter { $0.value == min }
        guard !nearest.isEmpty else {
            fatalError("This should not be the case")
        }
        
        return nearest.map { $0.key }.sorted().first
    }
    
    func calculateDistances(from source: Point, with units: Units) -> Distances {
        var result: Distances = [source : 0]
        
        for distance in UInt(0)... {
            let outerPoints = result.filter { $0.value == distance }.map { $0.key }
            if outerPoints.isEmpty {
                break
            }
            
            for outerPoint in outerPoints {
                for adjacentPoint in outerPoint.adjacent {
                    guard isValid(at: adjacentPoint, with: units) else {
                        continue
                    }
                    
                    if let _ = result[adjacentPoint] {
                        continue
                    }
                    
                    result[adjacentPoint] = distance + 1
                }
            }
        }
        
        return result
    }
    
    func isValid(at point: Point, with units: Units? = nil) -> Bool {
        if let _ = units?.unit(at: point) {
            return false
        }
        
        guard let mapTile = self[point] else {
            return false
        }
        
        return mapTile == .openCavern
    }
    
    func draw(with units: Units? = nil, includeNames: Bool = false, override: (Point) -> Character? = { _ in nil}) -> String {
        let points = Set(keys)
        let xValues = Set(points.map { $0.x })
        let yValues = Set(points.map { $0.y })
        
        guard let minX = xValues.min(), let minY = yValues.min(), let maxX = xValues.max(), let maxY = yValues.max() else {
            fatalError()
        }
        
        var result: [[Character]] = []
        
        for y in minY...maxY {
            var row: [Character] = []
            
            for x in minX...maxX {
                let point = Point(x, y)
                
                if let overridden = override(point) {
                    row.append(overridden)
                } else if let unit = units?.first(where: { $0.isAlive && $0.position == point }) {
                    row.append(unit.type.rawValue)
                } else {
                    let mapTile  = self[point, default: .wall]
                    row.append(mapTile.rawValue)
                }
            }
            
            if includeNames, let units = units {
                let rowUnits = units.filter { $0.isAlive }.filter { $0.position.y == y }.sorted()
                if !rowUnits.isEmpty {
                    let descriptions = rowUnits.map { $0.description }.joined(separator: ", ")
                    row.append(contentsOf: "   \(descriptions)")
                }
            }
            
            result.append(row)
        }
        
        return result.map { String($0) }.joined(separator: "\n")
    }
}

enum UnitType : Character {
    case elf = "E"
    case goblin = "G"
}

final class Unit {
    let type: UnitType
    var position: Point
    var health: Int
    var attackPower: Int
    
    init(type: UnitType, position: Point, health: Int = 200, attackPower: Int = 3) {
        self.type = type
        self.position = position
        self.health = health
        self.attackPower = attackPower
    }
    
    var isAlive: Bool {
        return health > 0
    }
    
    var isDead: Bool {
        return !isAlive
    }
    
    func attack(_ enemy: Unit) {
        enemy.health -= attackPower
    }
    
    func findEnemies(in units: Units) -> Units {
        return units.filter { $0.type != type }.filter { $0.isAlive }
    }
    
    func canFindEnemy(in units: Units) -> Bool {
        return !findEnemies(in: units).isEmpty
    }
    
    func findUnitsInAttackRange(_ units: Units) -> Units {
        let enemies = findEnemies(in: units)
        return position.adjacent.compactMap { enemies.unit(at: $0) }
    }
    
    func isInAttackRange(_ units: Units) -> Bool {
        return !findUnitsInAttackRange(units).isEmpty
    }
    
    func findLocationsInRange(of units: Units, in map: Map) -> Set<Point> {
        let enemies = findEnemies(in: units)
        let adjacentToEnemies = Set(enemies.flatMap { $0.position.adjacent })
        return adjacentToEnemies.filter { map.isValid(at: $0, with: units) }
    }
    
    func performMovement(on map: Map, with units: Units) {
        guard isAlive else {
            return
        }
        
        guard !isInAttackRange(units) else {
            return
        }
        
        let locations = findLocationsInRange(of: units, in: map)
        
        guard let selectedLocation = map.selectLocation(from: position, to: locations, in: map, with: units) else {
            return
        }
        
        let adjacent = Set(position.adjacent)
        
        guard let selectedMove = map.selectLocation(from: selectedLocation, to: adjacent, in: map, with: units) else {
            return
        }
        
        position = selectedMove
    }
    
    func performAttack(with units: Units) {
        guard isAlive else {
            return
        }
        
        let unitsInAttackRange = findUnitsInAttackRange(units)
        
        guard !unitsInAttackRange.isEmpty else {
            return
        }
        
        guard let lowestHP = unitsInAttackRange.map({ $0.health }).min() else {
            fatalError("Should have a minimum")
        }
        
        let unitsOnLowestHP = unitsInAttackRange.filter { $0.health == lowestHP }
        
        guard let target = unitsOnLowestHP.sorted().first else {
            fatalError("Should have a target")
        }
        
        attack(target)
    }
    
    func performTurn(on map: Map, with units: Units) {
        guard isAlive else {
            return
        }
        
        performMovement(on: map, with: units)
        performAttack(with: units)
    }
}

extension Unit {
    convenience init?(_ character: Character, position: Point) {
        guard let type = UnitType(rawValue: character) else {
            return nil
        }
        
        self.init(type: type, position: position)
    }
}

extension Unit : CustomStringConvertible {
    var description: String {
        return "\(type.rawValue)(\(health))"
    }
}

extension Unit : Equatable {
    static func == (lhs: Unit, rhs: Unit) -> Bool {
        return lhs.type == rhs.type
            && lhs.position == rhs.position
            && lhs.health == rhs.health
            && lhs.attackPower == rhs.attackPower
    }
}

extension Unit : Comparable {
    static func < (lhs: Unit, rhs: Unit) -> Bool {
        return lhs.position < rhs.position
    }
}

extension Array where Element == Unit {
    var totalHealth: Int {
        return filter { $0.isAlive }.reduce(0, { $0 + $1.health })
    }
    
    func unit(at point: Point) -> Unit? {
        return first(where: { $0.position == point })
    }
}

func runSimulation(map: Map, units: Units) -> (round: Int, health: Int, score: Int) {
    var units = units
    
    for round in 0... {
        units.sort()
        
        for unit in units {
            if !unit.canFindEnemy(in: units) {
                let health = units.totalHealth
                let score = round * health
                return (round, health, score)
            }
            
            if unit.isAlive {
                unit.performTurn(on: map, with: units)
            }
            
            units.removeAll(where: { $0.isDead })
        }
    }
    
    return (0, 0, 0)
}

public func part1(_ input: String) -> Int {
    let (map, units) = Map.parse(input)
    assert(map.draw(with: units) == input)
    let (_, _, score) = runSimulation(map: map, units: units)
    return score
}

public func part2(_ input: String) -> Int {
    for attackPower in 4... {
        var (map, units) = Map.parse(input)
        let elves = units.filter { $0.type == .elf }
        elves.forEach { $0.attackPower = attackPower }
        
        for round in 0... {
            if !elves.filter({ $0.isDead }).isEmpty {
                break
            }
            
            units.sort()
            
            for unit in units {
                if !unit.canFindEnemy(in: units) {
                    let health = units.totalHealth
                    let score = round * health
                    return score
                }
                
                if unit.isAlive {
                    unit.performTurn(on: map, with: units)
                }
                
                units.removeAll(where: { $0.isDead })
            }
        }
    }
    
    fatalError()
}
