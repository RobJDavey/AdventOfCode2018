import Foundation

let sampleStateRegex = try! NSRegularExpression(pattern: "^\\w+:\\s+\\[(?<r0>\\d+). (?<r1>\\d+). (?<r2>\\d+). (?<r3>\\d+)\\]$", options: [])
let sampleInstuctionRegex = try! NSRegularExpression(pattern: "^(?<i0>\\d+) (?<i1>\\d+) (?<i2>\\d+) (?<i3>\\d+)$", options: [])

func read(range: NSRange, in string: String) -> Substring {
    let startIndex = string.utf16.index(string.utf16.startIndex, offsetBy: range.location)
    let endIndex = string.utf16.index(startIndex, offsetBy: range.length)
    return string[startIndex..<endIndex]
}

func readSampleInstruction(_ sampleLine: String) -> [Int]? {
    let range = NSRange(location: 0, length: sampleLine.utf16.count)
    
    guard let stateMatch = sampleInstuctionRegex.firstMatch(in: sampleLine, options: [], range: range) else {
        return nil
    }
    
    let i0Range = stateMatch.range(withName: "i0")
    let i1Range = stateMatch.range(withName: "i1")
    let i2Range = stateMatch.range(withName: "i2")
    let i3Range = stateMatch.range(withName: "i3")
    
    let i0Text = read(range: i0Range, in: sampleLine)
    let i1Text = read(range: i1Range, in: sampleLine)
    let i2Text = read(range: i2Range, in: sampleLine)
    let i3Text = read(range: i3Range, in: sampleLine)
    
    guard let i0 = Int(i0Text),
        let i1 = Int(i1Text),
        let i2 = Int(i2Text),
        let i3 = Int(i3Text) else {
            return nil
    }
    
    return [i0, i1, i2, i3]
}

func readSampleState(_ sampleLine: String) -> Registers? {
    let range = NSRange(location: 0, length: sampleLine.utf16.count)
    
    guard let stateMatch = sampleStateRegex.firstMatch(in: sampleLine, options: [], range: range) else {
        return nil
    }
    
    let r0Range = stateMatch.range(withName: "r0")
    let r1Range = stateMatch.range(withName: "r1")
    let r2Range = stateMatch.range(withName: "r2")
    let r3Range = stateMatch.range(withName: "r3")
    
    let r0Text = read(range: r0Range, in: sampleLine)
    let r1Text = read(range: r1Range, in: sampleLine)
    let r2Text = read(range: r2Range, in: sampleLine)
    let r3Text = read(range: r3Range, in: sampleLine)
    
    guard let r0 = Value(r0Text),
        let r1 = Value(r1Text),
        let r2 = Value(r2Text),
        let r3 = Value(r3Text) else {
            return nil
    }
    
    return [r0, r1, r2, r3]
}

func test(opcode: Opcode, on actual: Registers, expecting expected: Registers) -> Bool {
    var actual = actual
    opcode.perform(on: &actual)
    return expected == actual
}

func analyze(sample: String, possibilities: inout [Int : Set<String>]) -> Int {
    let sampleLines = sample.components(separatedBy: .newlines)
    assert(sampleLines.count == 3)
    
    guard let beforeState = readSampleState(sampleLines[0]),
        let instruction = readSampleInstruction(sampleLines[1]),
        let afterState = readSampleState(sampleLines[2]),
        beforeState.count == 4,
        instruction.count == 4,
        afterState.count == 4 else {
            fatalError()
    }
    
    let opcodeNumber = instruction[0]
    let a = instruction[1]
    let b = instruction[2]
    let c = instruction[3]
    
    var count = 0
    
    if test(opcode: .addr(a, b, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("addr")
        count += 1
    }
    
    if test(opcode: .addi(a, b, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("addi")
        count += 1
    }
    
    if test(opcode: .mulr(a, b, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("mulr")
        count += 1
    }
    
    if test(opcode: .muli(a, b, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("muli")
        count += 1
    }
    
    if test(opcode: .banr(a, b, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("banr")
        count += 1
    }
    
    if test(opcode: .bani(a, b, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("bani")
        count += 1
    }
    
    if test(opcode: .borr(a, b, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("borr")
        count += 1
    }
    
    if test(opcode: .bori(a, b, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("bori")
        count += 1
    }
    
    if test(opcode: .setr(a, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("setr")
        count += 1
    }
    
    if test(opcode: .seti(a, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("seti")
        count += 1
    }
    
    if test(opcode: .gtir(a, b, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("gtir")
        count += 1
    }
    
    if test(opcode: .gtri(a, b, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("gtri")
        count += 1
    }
    
    if test(opcode: .gtrr(a, b, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("gtrr")
        count += 1
    }
    
    if test(opcode: .eqir(a, b, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("eqir")
        count += 1
    }
    
    if test(opcode: .eqri(a, b, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("eqri")
        count += 1
    }
    
    if test(opcode: .eqrr(a, b, c), on: beforeState, expecting: afterState) {
        possibilities[opcodeNumber, default: []].insert("eqrr")
        count += 1
    }
    
    return count
}

public func parse(_ text: String) -> (samples: [String], program: [String]) {
    let sections = text.components(separatedBy: "\n\n\n")
    assert(sections.count == 2)
    
    let samples = sections[0].components(separatedBy: "\n\n")
    let program = sections[1].components(separatedBy: .newlines).filter { !$0.isEmpty }
    
    return (samples, program)
}

public func part1(samples: [String]) -> (opcodeMap: [Int : String], answer1: Int) {
    var possibilities: [Int : Set<String>] = [:]
    var threeOrMore = 0
    
    for sample in samples {
        let possibilities = analyze(sample: sample, possibilities: &possibilities)
        if possibilities >= 3 {
            threeOrMore += 1
        }
    }
    
    var matches: [Int : String] = [:]
    
    while !possibilities.isEmpty {
        guard let match = possibilities.first(where: { $0.value.count == 1 }),
            let name = match.value.first else {
                fatalError()
        }
        
        matches[match.key] = name
        
        let remainingPossibilities: [Int : Set<String>] = possibilities.mapValues { names in
            let remaining = names.filter { !matches.values.contains($0) }
            return Set(remaining)
        }
        
        possibilities = Dictionary(uniqueKeysWithValues: remainingPossibilities.filter { !$0.value.isEmpty })
    }
    
    return (matches, threeOrMore)
}

public func part2(program: [String], opcodeMap: [Int : String]) -> Int {
    let opcodes = program.map { Opcode($0, opcodeMap: opcodeMap) }
    var registers = [0, 0, 0, 0]
    
    for opcode in opcodes {
        opcode.perform(on: &registers)
    }
    
    return registers[0]
}
