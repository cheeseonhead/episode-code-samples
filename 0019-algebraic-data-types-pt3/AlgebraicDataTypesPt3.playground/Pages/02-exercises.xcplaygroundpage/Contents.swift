
enum Either<A, B> {
    case left(A)
    case right(B)
}

struct Pair<A, B> {
    let first: A
    let second: B
}

struct Func<A, B> {
    let apply: (A) -> B
}

// Either<A, B> = A + B
// Pair<A, B>   = A * B
// Func<A, B>   = B^A

// Either<Pair<A, B>, Pair<A, C>>
//   = Pair<A, B> + Pair<A, C>
//   = A * B + A * C
//   = A * (B + C)
//   = Pair<A, B + C>
//   = Pair<A, Either<B, C>>

// Either(A, B) = A + B
// Pair(A, B)   = A * B
// Func(A, B)   = B^A

// | Algebra      | Swift Type System |
// | ------------ | ----------------- |
// | Sums         | Enums             |
// | Products     | Structs           |
// | Exponentials | Functions         |
// | Functions    | Generics          |

enum Optional<A> {
    case some(A)
    case none // Void
}

// Optional(A) = A + Void
//             = A + 1
// A? = A + 1

// Pair(Optional(A), Optional(B))
//   = A? * B?
//   = (A + 1) * (B + 1)
//   = A*B + A + B + 1

// A natural number is either:
// - Zero, or
// - The successor to some other natural number

enum NaturalNumber {
    case zero
    indirect case successor(NaturalNumber)
}

let zero = NaturalNumber.zero
let one = NaturalNumber.successor(.zero)
let two = NaturalNumber.successor(.successor(.zero))
let three = NaturalNumber.successor(.successor(.successor(.zero)))

let x: UInt = 0
x &- 1

func predecessor(_ nat: NaturalNumber) -> NaturalNumber? {
    switch nat {
    case .zero:
        return nil
    case .successor(let predecessor):
        return predecessor
    }
}

// NaturalNumber = 1 + NaturalNumber
//   = 1 + (1 + NaturalNumber)
//   = 1 + (1 + (1 + NaturalNumber))
//   = 1 + (1 + (1 + (1 + NaturalNumber)))
//   ...
//   = 1 + 1 + 1 + 1 + 1 + ...



// List<A>
// A value in List<A> is either:
// - empty list, or
// - a value (called the head) appended onto the rest of the list (called the tail)

enum List<A> {
    case empty
    indirect case cons(A, List<A>)
}

let xs: List<Int> = .cons(1, .cons(2, .cons(3, .empty)))
// [1, 2, 3]

func sum(_ xs: List<Int>) -> Int {
    switch xs {
    case .empty:
        return 0
    case let .cons(head, tail):
        return head + sum(tail)
    }
}

sum(xs)

// List(A) = 1 + A * List(A)
//  => List(A) - A * List(A) = 1
//  => List(A) * (1 - A) = 1
//  => List(A) = 1 / (1 - A)

// List(A) = 1 + A * List(A)
//         = 1 + A * (1 + A * List(A))
//         = 1 + A + A*A * List(A)
//         = 1 + A + A*A * (1 + A * List(A))
//         = 1 + A + A*A + A*A*A * List(A)
//         = 1 + A + A*A + A*A*A + A*A*A*A * List(A)
//         = 1 + A + A*A + A*A*A + A*A*A*A + ...

enum AlgebraicList<A> {
    case empty
    case one(A)
    case two(A, A)
    case three(A, A, A)
    case four(A, A, A, A)
    //...
}

AlgebraicList<Int>.four(1, 2, 3, 4)

// List(A) = 1 / (1 - A)
//         = 1 + A + A*A + A*A*A + ...

struct NonEmptyArray<A> {
    private let values: [A]

    init?(_ values: [A]) {
        guard !values.isEmpty else { return nil }
        self.values = values
    }

    init(values first: A, _ rest: A...) {
        self.values = [first] + rest
    }
}

NonEmptyArray([1, 2, 3])
NonEmptyArray([])

//dump(NonEmptyArray(values: 1, 2, 3))


extension NonEmptyArray: Collection {
    var startIndex: Int {
        return self.values.startIndex
    }

    var endIndex: Int {
        return self.values.endIndex
    }

    func index(after i: Int) -> Int {
        return self.values.index(after: i)
    }

    subscript(index: Int) -> A {
        get { return self.values[index] }
    }
}

//NonEmptyArray(values: 1, 2, 3).forEach { print($0) }

let ys = NonEmptyArray(values: 1, 2, 3)

extension NonEmptyArray {
    var first: A {
        return self.values.first!
    }
}

ys.first + 2


//NonEmptyArray<Int>().first


// List(A) = 1 + A + A*A + A*A*A + A*A*A*A + ...
// NonEmptyList(A) = A + A*A + A*A*A + A*A*A*A + ...
//                 = A * (1 + A + A*A + A*A*A + ...)
//                 = A * List(A)
//
//struct NonEmptyList<A> {
//  let head: A
//  let tail: List<A>
//}
//
//let zs = NonEmptyList(head: 1, tail: .cons(2, .cons(3, .empty)))

// NonEmptyList(A) = A + A*A + A*A*A + A*A*A*A + ...
//                 = A + A * (A + A*A + A*A*A + ...)
//                 = A + A * NonEmptyList(A)

enum NonEmptyList<A> {
    case singleton(A)
    indirect case cons(A, NonEmptyList<A>)
}

let zs: NonEmptyList<Int> = .cons(1, .cons(2, .singleton(3)))
let ws: NonEmptyList<Int> = .singleton(3)
// [1, 2, 3]

extension NonEmptyList {
    var first: A {
        switch self {
        case let .singleton(first):
            return first
        case let .cons(head, _):
            return head
        }
    }
}

zs.first
ws.first

extension NaturalNumber {
    static func +(lhs: NaturalNumber, rhs: NaturalNumber) -> NaturalNumber {
        switch lhs {
        case .zero:
            return rhs
        case .successor(let num):
            return .successor(num + rhs)
        }
    }

    static func *(lhs: NaturalNumber, rhs: NaturalNumber) -> NaturalNumber {
        switch lhs {
        case .zero:
            return .zero
        case .successor(let prev):
            return rhs + (rhs * prev)
        }
    }

    func predicessor() -> NaturalNumber? {
        switch self {
        case .zero:
            return nil
        case .successor(let prev):
            return prev
        }
    }

    func positive() -> WholeNumber {
        return .positive(self)
    }

    func negative() -> WholeNumber {
        return .negative(self)
    }
}

extension NaturalNumber: Comparable {
    public static func <(lhs: NaturalNumber, rhs: NaturalNumber) -> Bool {
        switch rhs {
        case .zero:
            return false
        case .successor(let prev):
            switch lhs {
            case .zero:
                return true
            case .successor(let lPrev):
                return lPrev < prev
            }
        }
    }
}

/*:
 5.) How could you implement *all* integers (both positive and negative) as an algebraic data type? Define all of the above functions and conformances on that type.
 */

enum WholeNumber {
    case positive(NaturalNumber) // Includes zero
    case negative(NaturalNumber) // Doesn't include zero, neg zero is technically neg one

    static func stepToZero(_ lhs: WholeNumber) -> WholeNumber {
        switch lhs {
        case .positive(let abs):
            return abs.predicessor()?.positive() ?? .positive(.zero)
        case .negative(let abs):
            return abs.predicessor()?.negative() ?? .positive(.zero)
        }
    }

    static prefix func -(lhs: WholeNumber) -> WholeNumber {
        switch lhs {
        case .negative(let num):
            return .positive(.successor(num))
        case .positive(let num):
            return num.predicessor()?.negative() ?? .positive(.zero)
        }
    }

    static func +(lhs: WholeNumber, rhs: WholeNumber) -> WholeNumber {
        switch lhs {
        case .negative:
            return -(-lhs + -rhs)
        case .positive(let num):
            switch rhs {
            case .positive(let rNum):
                return .positive(num + rNum)
            case .negative:
                return stepToZero(lhs) + stepToZero(rhs)
            }
        }
    }

    static func *(lhs: WholeNumber, rhs: WholeNumber) -> WholeNumber {
        switch lhs {
        case .positive(let num):
            switch rhs {
            case .positive(let rNum):
                return .positive(num * rNum)
            case .negative:
                return -(lhs * -rhs)
            }
        case .negative:
            return -(-lhs * rhs)
        }
    }
}

extension WholeNumber: Comparable {
    static func <(lhs: WholeNumber, rhs: WholeNumber) -> Bool {
        switch lhs {
        case .positive(let labs):
            switch rhs {
            case .positive(let rabs):
                return labs < rabs
            case .negative:
                return false
            }
        case .negative(let labs):
            switch rhs {
            case .positive:
                return true
            case .negative(let rabs):
                return !(labs < rabs)
            }
        }
    }
}

let ling = WholeNumber.positive(.zero)
let yi = WholeNumber.positive(.successor(.zero))
let fuYi = -yi
let er = yi + yi

assert(ling == ling)
assert(er == yi + yi + yi + fuYi)
assert(-yi == fuYi)

assert(-yi * fuYi == yi)
assert(er * fuYi == -er)

/*:
 6.) What familiar type is `List<Void>` equivalent to? Write `to` and `from` functions between those types showing how to travel back-and-forth between them.
 */
// Equal to NaturalNumber

func from(_ list: List<Void>) -> NaturalNumber {
    switch list {
    case .empty:
        return .zero
    case let .cons(_, tail):
        return .successor(from(tail))
    }
}

func to(_ number: NaturalNumber) -> List<Void> {
    switch number {
    case .zero:
        return .empty
    case .successor(let prev):
        return List<Void>.cons((), to(prev))
    }
}

from(to(one))
/*:
 7.) Conform `List` and `NonEmptyList` to the `ExpressibleByArrayLiteral` protocol.
 */
extension List: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = A

    public init(arrayLiteral elements: A...) {
        self.init(array: elements)
    }

    private init(array: [A]) {
        if array.isEmpty {
            self = .empty
        } else {
            self = .cons(array[0], List(array: Array(array.suffix(from: 1))))
        }
    }
}

let test: List<Void> = [(), ()]

/*:
 8.) Conform `List` to the `Collection` protocol.
 */
extension List: Collection {
    typealias Element = A
    typealias Index = Int

    var count: Int {
        switch self {
        case .empty:
            return 0
        case .cons(_, let tail):
            return 1 + tail.count
        }
    }
}
/*:
 9.) Conform each implementation of `NonEmptyList` to the `Collection` protocol.
 */
// TODO
/*:
 10.) Consider the type `enum List<A, B> { cae empty; case cons(A, B) }`. It's kinda like list without recursion, where the recursive part has just been replaced with another generic. Now consider the strange type:

    enum Fix<A> {
      case fix(ListF<A, Fix<A>>)
    }

 Construct a few values of this type. What other type does `Fix` seem to resemble?
 */
// TODO
/*:
 11.) Construct an explicit mapping between the `List<A>` and `Fix<A>` types by implementing:

 * `func to<A>(_ list: List<A>) -> Fix<A>`
 * `func from<A>(_ fix: Fix<A>) -> List<A>`

 The type `Fix` is known as the "fixed-point" of `List`. It is more generic than just dealing with lists, but unfortunately Swift does not have the type feature (higher-kinded types) to allow us to express this.
 */
// TODO
