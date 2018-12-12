import Foundation

typealias State = (value: String, offset: Int)

let potPlanted = Character("#")
let potEmpty = Character(".")

func runGeneration(state: State, rules: [String : Character]) -> State {
    let padding = String(repeating: potEmpty, count: 4)
    let paddedState = padding + state.value + padding
    var currentIndex = paddedState.index(paddedState.startIndex, offsetBy: 2)
    let endIndex = paddedState.index(paddedState.endIndex, offsetBy: -1)
    var result: String = paddedState
    
    while true {
        let first = paddedState.index(currentIndex, offsetBy: -2)
        let last = paddedState.index(currentIndex, offsetBy: 2)
        
        if last >= endIndex {
            break
        }
        
        let text = String(paddedState[first...last])
        let match: Character = rules[text] ?? potEmpty
        result.replaceSubrange(currentIndex...currentIndex, with: [match])
        currentIndex = paddedState.index(after: currentIndex)
    }
    
    let characters = Array(result)
    let index = characters.firstIndex(of: potPlanted)!
    let newOffset = state.offset - 4 + index
    let newValue = String(characters[index...]).trimmingCharacters(in: CharacterSet(charactersIn: "\(potEmpty)"))
    return (newValue, newOffset)
}

func parse(input: String) -> (initialState: String, rules: [String : Character]) {
    var lines = input.components(separatedBy: .newlines)
    let initialStateLine = lines.removeFirst()
    let initialStateParts = initialStateLine.components(separatedBy: ": ")
    assert(initialStateParts.count == 2)
    assert(initialStateParts[0] == "initial state")
    lines.removeFirst()
    
    var rules: [String: Character] = [:]
    
    for line in lines {
        let parts = line.components(separatedBy: " => ")
        assert(parts.count == 2)
        let key = parts[0]
        let value = parts[1].first!
        rules[key] = value
    }
    
    return (initialState: initialStateParts[1], rules: rules)
}

func sum(state: State) -> Int {
    let pots = state.value
    let values = sequence(first: state.offset, next: { $0 + 1})
    let zipped = zip(pots, values)
    
    return zipped.reduce(0) { (total, zippedItem) -> Int in zippedItem.0 == potPlanted ? total + zippedItem.1 : total }
}

public func part1(_ text: String, generations: Int = 20) -> Int{
    let (initialState, rules) = parse(input: text)
    var state: State = (initialState, 0)
    
    for _ in 1...generations {
        state = runGeneration(state: state, rules: rules)
    }
    
    return sum(state: state)
}

public func part2(_ text: String, generations: Int = 50_000_000_000) -> Int{
    let (initialState, rules) = parse(input: text)
    var state: State = (initialState, 0)
    
    var recentDeltas: [Int] = []
    var lastScore = 0
    
    for generation in 1...generations {
        state = runGeneration(state: state, rules: rules)
        let newScore = sum(state: state)
        let delta = newScore - lastScore
        recentDeltas.append(delta)
        
        if recentDeltas.count > 100 {
            recentDeltas.removeFirst()
            
            let uniqueDeltas = Set(recentDeltas)
            if uniqueDeltas.count == 1 {
                let remaining = generations - generation
                let offset = remaining * uniqueDeltas.first!
                return newScore + offset
            }
        }
        
        lastScore = newScore
    }
    
    return sum(state: state)
}
