import Foundation

public func parse(_ description: String) -> (ip: Register, opcodes: [Opcode]) {
    var lines = description.components(separatedBy: .newlines)
    let ipLine = lines.removeFirst()
    let ipLineParts = ipLine.components(separatedBy: .whitespaces)
    
    guard ipLineParts.count == 2, ipLineParts[0] == "#ip", let ipRegister = Register(ipLineParts[1]) else {
        fatalError()
    }
    
    let opcodes = lines.map(Opcode.init)
    return (ipRegister, opcodes)
}

public func part1(ipIndex: Int, opcodes: [Opcode], registers: [Int] = Array(repeating: 0, count: 6)) -> Int {
    precondition(registers.count == 6)
    var registers = registers
    var ip = 0
    
    while registers[ipIndex] < opcodes.count {
        ip = registers[ipIndex]
        let opcode = opcodes[ip]
        opcode.perform(on: &registers)
        registers[ipIndex] += 1
    }
    
    return registers[0]
}

public func part2(target: Int = 10551306) -> Int {
    var factors: [Int] = []
    
    for i in 1...target {
        if target % i == 0 {
            factors.append(i)
        }
    }
    
    return factors.reduce(0, +)
}
