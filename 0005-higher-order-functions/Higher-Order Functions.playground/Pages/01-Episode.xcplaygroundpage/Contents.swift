
func greet(at date: Date, name: String) -> String {
  let seconds = Int(date.timeIntervalSince1970) % 60
  return "Hello \(name)! It's \(seconds) seconds past the minute."
}

func greet(at date: Date) -> (String) -> String {
  return { name in
    let seconds = Int(date.timeIntervalSince1970) % 60
    return "Hello \(name)! It's \(seconds) seconds past the minute."
  }
}

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { a in { b in f(a, b) } }
}

curry(greet(at:name:))
greet(at:)

curry(String.init(data:encoding:))
  >>> { $0(.utf8) }

func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {

  return { b in { a in f(a)(b) } }
}

func flip<A, C>(_ f: @escaping (A) -> () -> C) -> () -> (A) -> C {

  return { { a in f(a)() } }
}

let stringWithEncoding = flip(curry(String.init(data:encoding:)))

let uft8String = stringWithEncoding(.utf8)

"Hello".uppercased(with: Locale.init(identifier: "en"))

String.uppercased(with:)

// (Self) -> (Arguments) -> ReturnType

String.uppercased(with:)("Hello")(Locale.init(identifier: "en"))

let uppercasedWithLocale = flip(String.uppercased(with:))
let uppercasedWithEn = uppercasedWithLocale(Locale.init(identifier: "en"))

"Hello" |> uppercasedWithEn

flip(String.uppercased)
flip(String.uppercased)()
"Hello" |> flip(String.uppercased)()

func zurry<A>(_ f: () -> A) -> A {
  return f()
}

"Hello" |> zurry(flip(String.uppercased))

[1, 2, 3]
  .map(incr)
  .map(square)

//curry([Int].map as ([Int]) -> ((Int) -> Int) -> [Int])

func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> ([B]) {
  return { $0.map(f) }
}

map(incr)
map(square)
map(incr >>> square >>> String.init)

Array(1...10)
  .filter { $0 > 5 }

func filter<A>(_ p: @escaping (A) -> Bool) -> ([A]) -> [A] {
  return { $0.filter(p) }
}

Array(1...10)
  |> filter { $0 > 5 }
  >>> map(incr >>> square)

/*:
 # Higher-Order Functions Exercises

 1. Write `curry` for functions that take 3 arguments.
 */
func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in { b in { c in f(a, b, c) } } }
}
/*:
 2. Explore functions and methods in the Swift standard library, Foundation, and other third party code, and convert them to free functions that compose using `curry`, `zurry`, `flip`, or by hand.
 */
// TODO
/*:
 3. Explore the associativity of function arrow `->`. Is it fully associative, _i.e._ is `((A) -> B) -> C` equivalent to `(A) -> ((B) -> C)`, or does it associate to only one side? Where does it parenthesize as you build deeper, curried functions?
 */
// TODO
// ((A) -> B) -> C  = C ^ ((A) -> B)
//                  = C ^ (B ^ A)

// (A) -> ((B) -> C)= ((B) -> C) ^ A
//                  = (C ^ B) ^ A
//                  = C ^ (B * A)
/*:
 4. Write a function, `uncurry`, that takes a curried function and returns a function that takes two arguments. When might it be useful to un-curry a function?
 */
// TODO
/*:
 5. Write `reduce` as a curried, free function. What is the configuration _vs._ the data?
 */
// TODO
/*:
 6. In programming languages that lack sum/enum types one is tempted to approximate them with pairs of optionals. Do this by defining a type `struct PseudoEither<A, B>` of a pair of optionals, and prevent the creation of invalid values by providing initializers.

 This is “type safe” in the sense that you are not allowed to construct invalid values, but not “type safe” in the sense that the compiler is proving it to you. You must prove it to yourself.
 */
// TODO
/*:
 7. Explore how the free `map` function composes with itself in order to transform a nested array. More specifically, if you have a doubly nested array `[[A]]`, then `map` could mean either the transformation on the inner array or the outer array. Can you make sense of doing `map >>> map`?
 */
// TODO

