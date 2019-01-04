func zip2<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
  var result: [(A, B)] = []
  (0..<min(xs.count, ys.count)).forEach { idx in
    result.append((xs[idx], ys[idx]))
  }
  return result
}

func zip3<A, B, C>(_ xs: [A], _ ys: [B], _ zs: [C]) -> [(A, B, C)] {
  return zip2(xs, zip2(ys, zs)) // [(A, (B, C))]
    .map { a, bc in (a, bc.0, bc.1) }
}

func zip2<A, B, C>(
  with f: @escaping (A, B) -> C
  ) -> ([A], [B]) -> [C] {

  return { zip2($0, $1).map(f) }
}

func zip3<A, B, C, D>(
  with f: @escaping (A, B, C) -> D
  ) -> ([A], [B], [C]) -> [D] {

  return { zip3($0, $1, $2).map(f) }
}

func zip2<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
  guard let a = a, let b = b else { return nil }
  return (a, b)
}

func zip3<A, B, C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? {
  return zip2(a, zip2(b, c))
    .map { a, bc in (a, bc.0, bc.1) }
}

func zip2<A, B, C>(
  with f: @escaping (A, B) -> C
  ) -> (A?, B?) -> C? {

  return { zip2($0, $1).map(f) }
}

func zip3<A, B, C, D>(
  with f: @escaping (A, B, C) -> D
  ) -> (A?, B?, C?) -> D? {

  return { zip3($0, $1, $2).map(f) }
}


enum Result<A, E> {
  case success(A)
  case failure(E)
}

func map<A, B, E>(_ f: @escaping (A) -> B) -> (Result<A, E>) -> Result<B, E> {
  return { result in
    switch result {
    case let .success(a):
      return .success(f(a))
    case let .failure(e):
      return .failure(e)
    }
  }
}

func zip2<A, B, E>(_ a: Result<A, E>, _ b: Result<B, E>) -> Result<(A, B), E> {

  switch (a, b) {
  case let (.success(a), .success(b)):
    return .success((a, b))
  case let (.success, .failure(e)):
    return .failure(e)
  case let (.failure(e), .success):
    return .failure(e)
  case let (.failure(e1), .failure(e2)):
//    return .failure(e1)
    return .failure(e2)
  }
}

import NonEmpty

enum Validated<A, E> {
  case valid(A)
  case invalid(NonEmptyArray<E>)
}

func map<A, B, E>(_ f: @escaping (A) -> B) -> (Validated<A, E>) -> Validated<B, E> {
  return { result in
    switch result {
    case let .valid(a):
      return .valid(f(a))
    case let .invalid(e):
      return .invalid(e)
    }
  }
}

func zip2<A, B, E>(_ a: Validated<A, E>, _ b: Validated<B, E>) -> Validated<(A, B), E> {

  switch (a, b) {
  case let (.valid(a), .valid(b)):
    return .valid((a, b))
  case let (.valid, .invalid(e)):
    return .invalid(e)
  case let (.invalid(e), .valid):
    return .invalid(e)
  case let (.invalid(e1), .invalid(e2)):
    return .invalid(e1 + e2)
  }
}

func zip2<A, B, C, E>(
  with f: @escaping (A, B) -> C
  ) -> (Validated<A, E>, Validated<B, E>) -> Validated<C, E> {

  return { zip2($0, $1) |> map(f) }
}

func zip3<A, B, C, E>(_ a: Validated<A, E>, _ b: Validated<B, E>, _ c: Validated<C, E>) -> Validated<(A, B, C), E> {
  return zip2(a, zip2(b, c))
    |> map { a, bc in (a, bc.0, bc.1) }
}

func zip3<A, B, C, D, E>(
  with f: @escaping (A, B, C) -> D
  ) -> (Validated<A, E>, Validated<B, E>, Validated<C, E>) -> Validated<D, E> {

  return { zip3($0, $1, $2) |> map(f) }
}

import Foundation

func compute(_ a: Double, _ b: Double) -> Double {
  return sqrt(a) + sqrt(b)
}

func validate(_ a: Double, label: String) -> Validated<Double, String> {
  return a < 0
  ? .invalid(NonEmptyArray("\(label) must be non-negative."))
  : .valid(a)
}

zip2(with: compute)(
  validate(-1, label: "first"),
  validate(-3, label: "second")
)

//compute(validate(2, label: "first"), validate(3, label: "second"))

struct Func<R, A> {
  let apply: (R) -> A
}

func map<A, B, R>(_ f: @escaping (A) -> B) -> (Func<R, A>) -> Func<R, B> {
  return { r2a in
    return Func { r in
      f(r2a.apply(r))
    }
  }
}

func zip2<A, B, R>(_ r2a: Func<R, A>, _ r2b: Func<R, B>) -> Func<R, (A, B)> {
  return Func<R, (A, B)> { r in
    (r2a.apply(r), r2b.apply(r))
  }
}

func zip3<A, B, C, R>(
  _ r2a: Func<R, A>,
  _ r2b: Func<R, B>,
  _ r2c: Func<R, C>
  ) -> Func<R, (A, B, C)> {

  return zip2(r2a, zip2(r2b, r2c)) |> map { ($0, $1.0, $1.1) }
}

func zip2<A, B, C, R>(
  with f: @escaping (A, B) -> C
  ) -> (Func<R, A>, Func<R, B>) -> Func<R, C> {

  return { zip2($0, $1) |> map(f) }
}

func zip3<A, B, C, D, R>(
  with f: @escaping (A, B, C) -> D
  ) -> (Func<R, A>, Func<R, B>, Func<R, C>) -> Func<R, D> {

  return { zip3($0, $1, $2) |> map(f) }
}

zip2(
  with: +)(Func { 2 }, Func { 3 }).apply(())

let randomNumber = Func<Void, Int> {
  (try? String(contentsOf: URL(string: "https://www.random.org/integers/?num=1&min=1&max=30&col=1&base=10&format=plain&rnd=new")!))
    .map { $0.trimmingCharacters(in: .newlines) }
    .flatMap(Int.init)
    ?? 0
}

randomNumber.apply(())

let aWordFromPointFree = Func<Void, String> {
  (try? String(contentsOf: URL(string: "https://www.pointfree.co")!))
    .map { $0.split(separator: " ")[1566] }
    .map(String.init)
    ?? "PointFree"
}

aWordFromPointFree.apply(())

zip2(
  with: [String].init(repeating:count:))(aWordFromPointFree, randomNumber).apply(())


struct F3<A> {
  let run: (@escaping (A) -> Void) -> Void
}

func map<A, B>(_ f: @escaping (A) -> B) -> (F3<A>) -> F3<B> {
  return { f3 in
    return F3 { callback in
      f3.run { callback(f($0)) }
    }
  }
}

func zip2<A, B>(_ fa: F3<A>, _ fb: F3<B>) -> F3<(A, B)> {
  return F3<(A, B)> { callback in
//    callback
    var a: A?
    var b: B?

    fa.run {
      a = $0
      if let b = b { callback(($0, b)) }
    }
    fb.run {
      b = $0
      if let a = a { callback((a, $0)) }
    }

//    fa.run { a in
//      fb.run { b in
//        callback((a, b))
//      }
//    }
  }
}


func zip2<A, B, C>(
  with f: @escaping (A, B) -> C
  ) -> (F3<A>, F3<B>) -> F3<C> {

  return { zip2($0, $1) |> map(f) }
}

func zip3<A, B, C>(_ fa: F3<A>, _ fb: F3<B>, _ fc: F3<C>) -> F3<(A, B, C)> {
  return zip2(fa, zip2(fb, fc)) |> map { ($0, $1.0, $1.1) }
}

func zip3<A, B, C, D>(
  with f: @escaping (A, B, C) -> D
  ) -> (F3<A>, F3<B>, F3<C>) -> F3<D> {

  return { zip3($0, $1, $2) |> map(f) }
}

func delay(by duration: TimeInterval, line: UInt = #line, execute: @escaping () -> Void) {
  print("delaying line \(line) by \(duration)")
  DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
    execute()
    print("executed line \(line)")
  }
}
let anInt = F3<Int> { callback in
  delay(by: 0.5) {
    callback(42)
  }
}
let aMessage = F3<String> { callback in
  delay(by: 1) {
    callback("Hello!")
  }
}

zip2(aMessage, anInt)

zip2(with: [String].init(repeating:count:))(
  aMessage,
  anInt
  ).run { value in
    print(value)
}


// ((A, B) -> C) -> ([A],             [B])             -> [C]
// ((A, B) -> C) -> ( A?,              B?)             ->  C?
// ((A, B) -> C) -> (Validated<E, A>, Validated<E, B>) -> Validated<E, C>
// ((A, B) -> C) -> (Func<R, A>,      Func<R, B>)      -> Func<R, C>
// ((A, B) -> C) -> (F3<A>,           F4<B>)           -> F3<C>

/*:
 # The Many Faces of Zip: Part 2

 ## Exercises

 1.) Can you make the `zip2` function on our `F3` type thread safe?
 */
// TODO
/*:
 2.) Generalize the `F3` type to a type that allows returning values other than `Void`: `struct F4<A, R> { let run: (@escaping (A) -> R) -> R }`. Define `zip2` and `zip2(with:)` on the `A` type parameter.
 */
// TODO
/*:
 3.) Find a function in the Swift standard library that resembles the function above. How could you use `zip2` on it?
 */
// TODO
/*:
 4.) This exercise explore what happens when you nest two types that each support a `zip` operation.

 - Consider the type `[A]? = Optional<Array<A>>`. The outer layer `Optional`  has `zip2` defined, but also the inner layer `Array`  has a `zip2`. Can we define a `zip2` on `[A]?` that makes use of both of these zip structures? Write the signature of such a function and implement it.
 */
// TODO
/*:
 - Using the `zip2` defined above write an example usage of it involving two `[A]?` values.
 */
// TODO
/*:
 - Consider the type `[Validated<A, E>]`. We again have have a nesting of types, each of which have their own `zip2` operation. Can you define a `zip2` on this type that makes use of both `zip` structures? Write the signature of such a function and implement it.
 */
// TODO
/*:
 - Using the `zip2` defined above write an example usage of it involving two `[Validated<A, E>]` values.
 */
// TODO
/*:
 - Consider the type `Func<R, A?>`. Again we have a nesting of types, each of which have their own `zip2` operation. Can you define a `zip2` on this type that makes use of both structures? Write the signature of such a function and implement it.
 */
// TODO
/*:
 - Consider the type `Func<R, [A]>`. Again we have a nesting of types, each of which have their own `zip2` operation. Can you define a `zip2` on this type that makes use of both structures? Write the signature of such a function and implement it.
 */
// TODO
/*:
 - Do you see anything common in the implementation of all of your functions?
 */
// TODO
/*:
 5.) In this series of episodes on `zip` we have described zipping types as a kind of way to swap the order of containers, e.g. we can transform a tuple of arrays to an array of tuples `([A], [B]) -> [(A, B)]`. There’s a more general concept that aims to flip contains of any type. Implement the following to the best of your ability, and describe in words what they represent:

 - `sequence: ([A?]) -> [A]?`
 - `sequence: ([Result<A, E>]) -> Result<[A], E>`
 - `sequence: ([Validated<A, E>]) -> Validated<[A], E>`
 - `sequence: ([F3<A>]) -> F3<[A]`
 - `sequence: (Result<A?, E>) -> Result<A, E>?`
 - `sequence: (Validated<A?, E>) -> Validated<A, E>?`
 - `sequence: ([[A]]) -> [[A]]`.

 Note that you can still flip the order of these containers even though they are both the same container type. What does this represent? Evaluate the function on a few sample nested arrays.

 Note that all of these functions also represent the flipping of containers, e.g. an array of optionals transforms into an optional array, an array of results transforms into a result of an array, or a validated optional transforms into an optional validation, etc.
 */
// TODO
