import Foundation

public struct Point {
    let x: Int
    let y: Int
}

extension Point : Hashable {
}

public enum Acre : Character {
    case open = "."
    case trees = "|"
    case lumberyard = "#"
}

func draw(_ acres: [Point : Acre]) {
    let points = Set(acres.keys)
    let xValues = points.map { $0.x }
    let yValues = points.map { $0.y }
    
    let xMin = xValues.min()!
    let xMax = xValues.max()!
    let yMin = yValues.min()!
    let yMax = yValues.max()!
    
    for y in yMin...yMax {
        for x in xMin...xMax {
            let point = Point(x: x, y: y)
            let acre = acres[point]!
            print(acre.rawValue, terminator: "")
        }
        
        print()
    }
    
    print()
}

public func parse(_ description: String) -> [Point : Acre] {
    let lines = description.components(separatedBy: .newlines)
    let acres = lines.map { $0.compactMap(Acre.init)}
    
    var result: [Point : Acre] = [:]
    
    for (y, row) in acres.enumerated() {
        for (x, acre) in row.enumerated() {
            let point = Point(x: x, y: y)
            result[point] = acre
        }
    }
    
    return result
}

func createMapper(_ acres: [Point : Acre]) -> ((Point, Acre) -> (Point, Acre)) {
    return { key, value in
        var surrounding: [Acre] = []
        
        for yOffset in -1...1 {
            for xOffset in -1...1 {
                guard yOffset != 0 || xOffset != 0 else {
                    continue
                }
                
                let point = Point(x: key.x + xOffset, y: key.y + yOffset)
                guard let acre = acres[point] else {
                    continue
                }
                
                surrounding.append(acre)
            }
        }
        
        switch value {
        case .open:
            if surrounding.filter({ $0 == .trees }).count >= 3 {
                return (key, .trees)
            }
        case .trees:
            if surrounding.filter({ $0 == .lumberyard }).count >= 3 {
                return (key, .lumberyard)
            }
        case .lumberyard:
            if !surrounding.contains(.lumberyard) || !surrounding.contains(.trees) {
                return (key, .open)
            }
        }
        
        return (key, value)
    }
}

public func part1(_ acres: [Point : Acre]) -> Int {
    var acres = acres
    
    for _ in 1...10 {
        let mapper = createMapper(acres)
        let mapped = acres.map(mapper)
        acres = Dictionary(uniqueKeysWithValues: mapped)
    }
    
    let values = Array(acres.values)
    let trees = values.filter { $0 == .trees }.count
    let lumberyards = values.filter { $0 == .lumberyard }.count
    return trees * lumberyards
}

public func part2(_ acres: [Point : Acre]) -> Int {
    var acres = acres
    
    let target = 1_000_000_000
    let threshold = 10
    
    var history: [Int] = []
    var possibleAnswers: [Int] = []
    
    for minute in 1...target {
        let mapper = createMapper(acres)
        let mapped = acres.map(mapper)
        acres = Dictionary(uniqueKeysWithValues: mapped)
        let values = Array(acres.values)
        let trees = values.filter { $0 == .trees }.count
        let lumberyards = values.filter { $0 == .lumberyard }.count
        let total = trees * lumberyards
        
        if let index = history.lastIndex(of: total) {
            let remaining = target - minute
            let repeatRate = minute - index - 1
            let remainder = remaining % repeatRate
            let finalIndex = index + remainder
            let possibleAnswer = history[finalIndex]
            possibleAnswers.append(possibleAnswer)
            
            if possibleAnswers.count > threshold {
                possibleAnswers.removeFirst(possibleAnswers.count - threshold)
                
                let answerSet = Set(possibleAnswers)
                if answerSet.count == 1 {
                    return answerSet.first!
                }
            }
        }
        
        history.append(total)
    }
    
    fatalError()
}
