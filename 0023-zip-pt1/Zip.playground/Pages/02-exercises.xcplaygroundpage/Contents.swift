/*:
 # The Many Faces of Zip: Part 1

 ## Exercises

 1.) In this episode we came across closures of the form `{ ($0, $1.0, $1.1) }` a few times in order to unpack a tuple of the form `(A, (B, C))` to `(A, B, C)`. Create a few overloaded functions named `unpack` to automate this.

 */
// TODO
func unpack<A, B, C>(_ packed: (A, (B, C))) -> (A, B, C) {
    return (packed.0, packed.1.0, packed.1.1)
}
/*:
 2.) Define `zip4`, `zip5`, `zip4(with:)` and `zip5(with:)` on arrays and optionals. Bonus: [learn](https://nshipster.com/swift-gyb/) how to use Apple's `gyb` tool to generate higher-arity overloads.
 */
// TODO
/*:
 3.) Do you think `zip2` can be seen as a kind of associative infix operator? For example, is it true that `zip(xs, zip(ys, zs)) == zip(zip(xs, ys), zs)`? If it's not strictly true, can you define an equivalence between them?
 */
// TODO
/*:
 4.) Define `unzip2` on arrays, which does the opposite of `zip2: ([(A, B)]) -> ([A], [B])`. Can you think of any applications of this function?
 */
// TODO
func unzip2<A, B>(_ zs: [(A, B)]) -> ([A], [B]) {
    return (
        zs.map { $0.0 },
        zs.map { $0.1 }
    )
}
/*:
 5.) It turns out, that unlike the `map` function, `zip2` is not uniquely defined. A single type can have multiple, completely different `zip2` functions. Can you find another `zip2` on arrays that is different from the one we defined? How does it differ from our `zip2` and how could it be useful?
 */
// TODO
/*:
 6.) Define `zip2` on the result type: `(Result<A, E>, Result<B, E>) -> Result<(A, B), E>`. Is there more than one possible implementation? Also define `zip3`, `zip2(with:)` and `zip3(with:)`.

 Is there anything that seems wrong or “off” about your implementation? If so, it
 will be improved in the next episode 😃.
 */
// TODO
/*:
 7.) In [previous](/episodes/ep14-contravariance) episodes we've considered the type that simply wraps a function, and let's define it as `struct Func<R, A> { let apply: (R) -> A }`. Show that this type supports a `zip2` function on the `A` type parameter. Also define `zip3`, `zip2(with:)` and `zip3(with:)`.
 */
// TODO
struct Func<R, A> { let apply: (R) -> A }

func zip2<R, A, B>(_ x: Func<R, A>, _ f: @escaping (A) -> B) -> Func<R, B> {
    return Func<R, B> { r in
        f(x.apply(r))
    }
}
/*:
 8.) The nested type `[A]? = Optional<Array<A>>` is composed of two containers, each of which has their own `zip2` function. Can you define `zip2` on this nested container that somehow involves each of the `zip2`'s on the container types?
 */
// TODO
// ([A],    [B])    ->  [(A, B)]
// ([A]?,   [B]?)   ->  [(A, B)?]

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

func zip2<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
    var result: [(A, B)] = []
    (0..<min(xs.count, ys.count)).forEach { idx in
        result.append((xs[idx], ys[idx]))
    }
    return result
}

func zip2<A, B>(_ a: [A]?, _ b: [B]?) -> [(A, B)?] {
    guard let test: ([A], [B]) = zip2(a, b) else {
        return []
    }

    return zip2(test.0, test.1)
}
