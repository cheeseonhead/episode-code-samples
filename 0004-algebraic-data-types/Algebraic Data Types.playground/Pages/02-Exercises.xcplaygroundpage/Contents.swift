/*:
 # Algebraic Data Types Exercises

 1. What algebraic operation does the function type `(A) -> B` correspond to? Try explicitly enumerating all the values of some small cases like `(Bool) -> Bool`, `(Unit) -> Bool`, `(Bool) -> Three` and `(Three) -> Bool` to get some intuition.
 */
// TODO
/*:
 2. Consider the following recursively defined data structure. Translate this type into an algebraic equation relating `List<A>` to `A`.
 */
indirect enum List<A> {
  case empty
  case cons(A, List<A>)
}
// TODO
// List<A>  = 1 + (1 * List<A>)
//          = 1 + (1 * (1 + (1 * List<A>)))
//          = 1 + (1 + (1 * List<A>))
//          = 1 + 1 + (1 * List<A>)
//          = 1 + 1 + 1 + 1 + ...
/*:
 3. Is `Optional<Either<A, B>>` equivalent to `Either<Optional<A>, Optional<B>>`? If not, what additional values does one type have that the other doesn’t?
 */
// Optional<Either<A, B>>   = 1 + Either<A, B>
//                          = 1 + (A + B)
// Either<A?, B?>   = A? + B?
//                  = (1 + A) + (1 + B)
//                  = 1 + (A + 1 + B)
//                  = 1 + (1 + (A + B))
//                  = Optional<Optional<Either<A, B>>
/*:
 4. Is `Either<Optional<A>, B>` equivalent to `Optional<Either<A, B>>`?
 */
// TODO
// Either<A?, B>    = A? + B
//                  = 1 + A + B

// Either<A, B>?    = 1 + Either<A, B>
//                  = 1 + A + B
/*:
 5. Swift allows you to pass types, like `A.self`, to functions that take arguments of `A.Type`. Overload the `*` and `+` infix operators with functions that take any type and build up an algebraic representation using `Pair` and `Either`. Explore how the precedence rules of both operators manifest themselves in the resulting types.
 */
// TODO
struct Pair<A, B> {
  let first: A
  let second: B
}

enum Either<A, B> {
  case left(A)
  case right(B)
}

func +<A, B>(_ a: A.Type, _ b: B.Type) -> Either<A, B>.Type {
    return Either<A, B>.self
}
