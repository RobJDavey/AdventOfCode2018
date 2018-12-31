import Foundation

public typealias Value = Int
public typealias Registers = Array<Value>
public typealias Register = Registers.Index

public enum Opcode {
    case addr(Register, Register, Register)
    case addi(Register, Value, Register)
    case mulr(Register, Register, Register)
    case muli(Register, Value, Register)
    case banr(Register, Register, Register)
    case bani(Register, Value, Register)
    case borr(Register, Register, Register)
    case bori(Register, Value, Register)
    case setr(Register, Register)
    case seti(Value, Register)
    case gtir(Value, Register, Register)
    case gtri(Register, Value, Register)
    case gtrr(Register, Register, Register)
    case eqir(Value, Register, Register)
    case eqri(Register, Value, Register)
    case eqrr(Register, Register, Register)
}

extension Opcode {
    public init(_ description: String, opcodeMap: [Int : String]) {
        let components = description
            .components(separatedBy: .whitespaces)
            .compactMap(Int.init)
        
        assert(components.count == 4)
        
        let opcodeNumber = components[0]
        let a = components[1]
        let b = components[2]
        let c = components[3]
        
        guard let opcodeName = opcodeMap[opcodeNumber] else {
            fatalError("Unknown opcode")
        }
        
        switch opcodeName {
        case "addr":
            self = .addr(a, b, c)
        case "addi":
            self = .addi(a, b, c)
        case "mulr":
            self = .mulr(a, b, c)
        case "muli":
            self = .muli(a, b, c)
        case "banr":
            self = .banr(a, b, c)
        case "bani":
            self = .bani(a, b, c)
        case "borr":
            self = .borr(a, b, c)
        case "bori":
            self = .bori(a, b, c)
        case "setr":
            self = .setr(a, c)
        case "seti":
            self = .seti(a, c)
        case "gtir":
            self = .gtir(a, b, c)
        case "gtri":
            self = .gtri(a, b, c)
        case "gtrr":
            self = .gtrr(a, b, c)
        case "eqir":
            self = .eqir(a, b, c)
        case "eqri":
            self = .eqri(a, b, c)
        case "eqrr":
            self = .eqrr(a, b, c)
        default:
            fatalError()
        }
    }
    
    public init(_ description: String) {
        let components = description
            .components(separatedBy: .whitespaces)
        
        assert(components.count == 4)
        
        let opcodeName = components[0]
        guard let a = Int(components[1]), let b = Int(components[2]), let c = Int(components[3]) else {
            fatalError()
        }
        
        switch opcodeName {
        case "addr":
            self = .addr(a, b, c)
        case "addi":
            self = .addi(a, b, c)
        case "mulr":
            self = .mulr(a, b, c)
        case "muli":
            self = .muli(a, b, c)
        case "banr":
            self = .banr(a, b, c)
        case "bani":
            self = .bani(a, b, c)
        case "borr":
            self = .borr(a, b, c)
        case "bori":
            self = .bori(a, b, c)
        case "setr":
            self = .setr(a, c)
        case "seti":
            self = .seti(a, c)
        case "gtir":
            self = .gtir(a, b, c)
        case "gtri":
            self = .gtri(a, b, c)
        case "gtrr":
            self = .gtrr(a, b, c)
        case "eqir":
            self = .eqir(a, b, c)
        case "eqri":
            self = .eqri(a, b, c)
        case "eqrr":
            self = .eqrr(a, b, c)
        default:
            fatalError()
        }
    }
    
    public func perform(on registers: inout Registers) {
        switch self {
        case let .addr(a, b, c):
            registers[c] = registers[a] + registers[b]
        case let .addi(a, b, c):
            registers[c] = registers[a] + b
        case let .mulr(a, b, c):
            registers[c] = registers[a] * registers[b]
        case let .muli(a, b, c):
            registers[c] = registers[a] * b
        case let .banr(a, b, c):
            registers[c] = registers[a] & registers[b]
        case let .bani(a, b, c):
            registers[c] = registers[a] & b
        case let .borr(a, b, c):
            registers[c] = registers[a] | registers[b]
        case let .bori(a, b, c):
            registers[c] = registers[a] | b
        case let .setr(a, c):
            registers[c] = registers[a]
        case let .seti(a, c):
            registers[c] = a
        case let .gtir(a, b, c):
            registers[c] = a > registers[b] ? 1 : 0
        case let .gtri(a, b, c):
            registers[c] = registers[a] > b ? 1 : 0
        case let .gtrr(a, b, c):
            registers[c] = registers[a] > registers[b] ? 1 : 0
        case let .eqir(a, b, c):
            registers[c] = a == registers[b] ? 1 : 0
        case let .eqri(a, b, c):
            registers[c] = registers[a] == b ? 1 : 0
        case let .eqrr(a, b, c):
            registers[c] = registers[a] == registers[b] ? 1 : 0
        }
    }
}
