
// NSObject > UIResponder > UIView > UIControl > UIButton

func wrapView(padding: UIEdgeInsets) -> (UIView) -> UIView {
  return { subview in
    let wrapper = UIView()
    subview.translatesAutoresizingMaskIntoConstraints = false
    wrapper.addSubview(subview)
    NSLayoutConstraint.activate([
      subview.leadingAnchor.constraint(
        equalTo: wrapper.leadingAnchor, constant: padding.left
      ),
      subview.rightAnchor.constraint(
        equalTo: wrapper.rightAnchor, constant: -padding.right
      ),
      subview.topAnchor.constraint(
        equalTo: wrapper.topAnchor, constant: padding.top
      ),
      subview.bottomAnchor.constraint(
        equalTo: wrapper.bottomAnchor, constant: -padding.bottom
      ),
      ])
    return wrapper
  }
}

let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
view.backgroundColor = .darkGray

let padding = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)

let wrapper = wrapView(padding: padding)(view)
wrapper.frame.size = CGSize(width: 300, height: 300)
wrapper.backgroundColor = .lightGray
wrapper

wrapView(padding: padding) as (UIView) -> UIView
wrapView(padding: padding) as (UIButton) -> UIView
wrapView(padding: padding) as (UISwitch) -> UIView
wrapView(padding: padding) as (UIStackView) -> UIView

//wrapView(padding: padding) as (UIResponder) -> UIView

//wrapView(padding: padding) as (UIView) -> UIButton
wrapView(padding: padding) as (UIView) -> UIResponder
wrapView(padding: padding) as (UIView) -> NSObject
wrapView(padding: padding) as (UIView) -> AnyObject


/*

 If A < B

 then (B -> C) < (A -> C)

 then (C -> A) < (C -> B)

 -------------------------

 If A < B

 then B -> C
        <              contravariant
      A -> C

 then      C -> A
             <         covariant
           C -> B
 */


func map<A, B>(_ f: (A) -> B) -> ([A]) -> [B] {
  fatalError("Unimplemented")
}


struct Func<A, B> {
  let apply: (A) -> B
}


func map<A, B, C>(_ f: @escaping (B) -> C)
  -> ((Func<A, B>) -> Func<A, C>) {
  return { g in
    Func(apply: g.apply >>> f)
  }
}

//func map<A, B, C>(_ f: @escaping (A) -> B)
//  -> ((Func<A, C>) -> Func<B, C>) {
//    return { g in
//      f // (A) -> B
//      g.apply // (A) -> C
//    }
//}

func contramap<A, B, C>(_ f: @escaping (B) -> A)
  -> ((Func<A, C>) -> Func<B, C>) {
    return { g in
//      f // (B) -> A
//      g.apply // (A) -> C
//      Func(apply: f >>> g.apply)
      Func(apply: g.apply <<< f)
    }
}


struct F3<A> {
  let run: (@escaping (A) -> Void) -> Void
}

func map<A, B>(_ f: @escaping (A) -> B) -> (F3<A>) -> F3<B> {
  return { f3 in
    return F3 { callback in
      f3.run(f >>> callback)
    }
  }
}

// (A) -> B
//  -1    +1

// ((A) -> Void) -> Void
//  |_|    |___|
//   -1      +1
// |___________|    |___|
//      -1           +1

// A = +1


// (A) -> ((B) -> C) -> D)
//         |_|   |_|
//          -1    +1
//         |_______|   |_|
//            -1        +1
// |_|    |______________|
//  -1           +1

// A = -1
// B = +1
// C = -1
// D = +1


// Set<A: Hashable, Equatable>
let xs = Set<Int>([1, 2, 3, 4, 4, 4, 4])

xs.forEach { print($0) }

struct PredicateSet<A> {
  let contains: (A) -> Bool

  func contramap<B>(_ f: @escaping (B) -> A) -> PredicateSet<B> {
    return PredicateSet<B>(contains: f >>> self.contains)
  }
}

let ys = PredicateSet { [1, 2, 3, 4].contains($0) }

let evens = PredicateSet { $0 % 2 == 0 }
let odds = evens.contramap { $0 + 1 }
evens.contains(1)
odds.contains(1)

let allInts = PredicateSet<Int> { _ in true }
let longStrings = PredicateSet<String> { $0.count > 100 }

let allIntsNot1234 = PredicateSet { !ys.contains($0) }
allIntsNot1234.contains(5)
allIntsNot1234.contains(4)

let isLessThan10 = PredicateSet<Int> { $0 < 10 }

struct User {
  let id: Int
  let name: String
}

let usersWithIdLessThan10 = isLessThan10.contramap(^\User.id)
usersWithIdLessThan10.contains(User(id: 100, name: "Blob"))

let usersWithShortNames = isLessThan10.contramap(^\User.name.count)
usersWithShortNames.contains(User(id: 1, name: "Blob Blob Blob"))



func map<A: Hashable, B: Hashable>(
  _ f: @escaping (A) -> B
  ) -> (Set<A>) -> Set<B> {

  return { xs in
    var ys = Set<B>()
    for x in xs {
      ys.insert(f(x))
    }
    return ys
  }
}

let zs: Set<Int> = [-1, 0, 1]
zs
  |> map(square)

// map(f >>> g) == map(f) >>> map(g)

struct Trivial<A>: Hashable {
  let value: A

  static func == (lhs: Trivial, rhs: Trivial) -> Bool {
    return true
  }

  var hashValue: Int {
    return 1
  }
}

zs
  |> map(Trivial.init >>> ^\.value)

zs
  |> map(Trivial.init)
  |> map(^\.value)

zs.map(Trivial.init >>> ^\.value)
zs.map(Trivial.init).map(^\.value)

/*:
 # Contravariance Exercises

 1.) Determine the sign of all the type parameters in the function `(A) -> (B) -> C`. Note that this is a curried function. It may be helpful to fully parenthesize the expression before determining variance.
 */
// TODO
/*:
 2.) Determine the sign of all the type parameters in the following function:

 `(A, B) -> (((C) -> (D) -> E) -> F) -> G`
 */
// TODO
/*:
 3.) Recall that [a setter is just a function](https://www.pointfree.co/episodes/ep6-functional-setters#t813) `((A) -> B) -> (S) -> T`. Determine the variance of each type parameter, and define a `map` and `contramap` for each one. Further, for each `map` and `contramap` write a description of what those operations mean intuitively in terms of setters.
 */
// TODO
typealias Setter<A, B, S, T> = (@escaping (A) -> B) -> (S) -> T

func map<A, B, S, T, C>(_ f: @escaping (A) -> C) -> (@escaping Setter<A, B, S, T>) -> Setter<C, B, S, T> {
    return { setter in
        return { g in
            return { s in
                return s
                    |> setter(f >>> g)
            }
        }
    }
}

func map<A, B, S, T, C>(_ f: @escaping (T) -> C) -> (@escaping Setter<A, B, S, T>) -> Setter<A, B, S, C> {
    return { setter in
        return { g in
            return { s in
                return s
                    |> setter(g)
                    |> f
            }
        }
    }
}

func pullBack<A, B, S, T, C>(_ f: @escaping (C) -> B) -> (@escaping Setter<A, B, S, T>) -> Setter<A, C, S, T> {
    return { setter in
        return { g in
            return { s in
                s |> setter(f <<< g)
            }
        }
    }
}

func pullBack<A, B, S, T, C>(_ f: @escaping (C) -> S) -> (@escaping Setter<A, B, S, T>) -> Setter<A, B, C, T> {
    return { setter in
        return { g in
            return { c in
                c
                    |> f
                    |> setter(g)
            }
        }
    }
}

/*:
 4.) Define `union`, `intersect`, and `invert` on `PredicateSet`.
 */
// TODO
extension PredicateSet {
    func union(with other: PredicateSet) -> PredicateSet {
        return PredicateSet { a in
            self.contains(a) || other.contains(a)
        }
    }

    func intersect(with other: PredicateSet) -> PredicateSet {
        return PredicateSet { a in
            self.contains(a) && other.contains(a)
        }
    }

    func invert() -> PredicateSet {
        return PredicateSet { a in
            !self.contains(a)
        }
    }
}
/*:
 This collection of exercises explores building up complex predicate sets and understanding their performance characteristics.

 5a.) Create a predicate set `isPowerOf2: PredicateSet<Int>` that determines if a value is a power of `2`, _i.e._ `2^n` for some `n: Int`.
 */
// TODO
func powerOf2Check(_ n: Int) -> Bool {
    switch n {
    case 1: return true
    case .min..<1:
        return false
    case _ where n % 2 == 0:
        return powerOf2Check(n / 2)
    default:
        return false
    }
}

let isPowerOf2: PredicateSet<Int> = PredicateSet { n in
    powerOf2Check(n)
}

isPowerOf2.contains(1024)
isPowerOf2.contains(-1)
isPowerOf2.contains(129)
/*:
 5b.) Use the above predicate set to derive a new one `isPowerOf2Minus1: PredicateSet<Int>` that tests if a number is of the form `2^n - 1` for `n: Int`.
 */
// TODO
let isPowerOf2Minus1 = PredicateSet<Int> { n in
    isPowerOf2.contains(n + 1)
}
/*:
 5c.) Find an algorithm online for testing if an integer is prime, and turn it into a predicate `isPrime: PredicateSet<Int>`.
 */
// TODO
/*:
 5d.) The intersection `isPrime.intersect(isPowerOf2Minus1)` consists of numbers known as [Mersenne primes](https://en.wikipedia.org/wiki/Mersenne_prime). Compute the first 10.
 */
// TODO
/*:
 5e.) Recall that `&&` and `||` are short-circuiting in Swift. How does that translate to `union` and `intersect`?
 */
// TODO
/*:
 6.) What is the difference between `isPrime.intersect(isPowerOf2Minus1)` and `isPowerOf2Minus1.intersect(isPrime)`? Which one represents a more performant predicate set?
 */
// TODO
/*:
 7.) It turns out that dictionaries `[K: V]` do not have `map` on `K` for all the same reasons `Set` does not. There is an alternative way to define dictionaries in terms of functions. Do that and define `map` and `contramap` on that new structure.
 */
// TODO
// [K: V] == (K) -> V
/*:
 8.) Define `CharacterSet` as a type alias of `PredicateSet`, and construct some of the sets that are currently available in the [API](https://developer.apple.com/documentation/foundation/characterset#2850991).
 */
// TODO
typealias CharacterSet = PredicateSet<Character>
/*:
 Let's explore happens when a type parameter appears multiple times in a function signature.

 9a.) Is `A` in positive or negative position in the function `(B) -> (A, A)`? Define either `map` or `contramap` on `A`.
 */
// Positive
func map<A, B, C>(_ f: @escaping (A) -> C) -> (@escaping (B) -> (A, A)) -> (B) -> (C, C) {
    return { g in
        return { b in
            let aPair = g(b)
            return (aPair.0 |> f, aPair.1 |> f)
        }
    }
}
/*:
 9b.) Is `A` in positive or negative position in `(A, A) -> B`? Define either `map` or `contramap`.
 */
// TODO
/*:
 9c.) Consider the type `struct Endo<A> { let apply: (A) -> A }`. This type is called `Endo` because functions whose input type is the same as the output type are called "endomorphisms". Notice that `A` is in both positive and negative position. Does that mean that _both_ `map` and `contramap` can be defined, or that neither can be defined?
 */
// Neither
struct Endo<A> { let apply: (A) -> A }
/*:
 9d.) Turns out, `Endo` has a different structure on it known as an "invariant structure", and it comes equipped with a different kind of function called `imap`. Can you figure out what it’s signature should be?
 */
// TODO
func imap<A>(_ f: @escaping (A) -> A) -> (Endo<A>) -> Endo<A> {
    return { endo in
        return Endo<A>(apply: endo.apply >>> f)
    }
}
/*:
 10.) Consider the type `struct Equate<A> { let equals: (A, A) -> Bool }`. This is just a struct wrapper around an equality check. You can think of it as a kind of "type erased" `Equatable` protocol. Write `contramap` for this type.
 */
// TODO
struct Equate<A> { let equals: (A, A) -> Bool }

func pullBack<A, B>(_ f: @escaping (B) -> A) -> (Equate<A>) -> Equate<B> {
    return { equate in
        return Equate<B> { lhs, rhs in
            equate.equals(lhs |> f, rhs |> f)
        }
    }
}
/*:
 11.) Consider the value `intEquate = Equate<Int> { $0 == $1 }`. Continuing the "type erased" analogy, this is like a "witness" to the `Equatable` conformance of `Int`. Show how to use `contramap` defined above to transform `intEquate` into something that defines equality of strings based on their character count.
 */
// TODO
let intEquate = Equate<Int> { $0 == $1 }

let strCountEquate = intEquate |> pullBack(^\String.count)

strCountEquate.equals("Hello", "World")
