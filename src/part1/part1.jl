include("types.jl")

include("chapter01.jl")
export id_type, compose_fun

include("chapter02.jl")
export ⊥, bottom, unit, 
        TRUE, FALSE, EnumBool, TypeBool, TypeFalse, TypeTrue, True, False, memoize, clear_memoize,
        f_bool, f_int, getchar, test_getchar, test_fbool, pure_bool2bools


module Chapter03
include("chapter03.jl")
export emptyof, append, Monoid, ++,
        MonoidOperation, MonoidCategory
        FreeCategory, NamedFreeCategory, addpoint!, addarrow!
end

include("chapter04.jl")
export Writer, w_compose, w_id,
        toUpper, toWords, process, negate, isEven, isOdd,
        Option, option_compose, option_id, safe_root, safe_reciprocal, safe_root_reciprocal

include("chapter05.jl")
export Morphism, factorizier, fst, snd, Left, Right, Either

include("chapter06.jl")
export swap, alpha, alpha_inv, rho, rho_inv, Element, startsWithSymbol,
        List, nil, Nil, Cons, from_vec, @list, Maybe, Just, maybeTail, prodToSum, prodToSum2, sumToProd, sumToProd2,
        circ, area, Square, Circle, Rect

include("chapter07.jl")
export fmap, MyConst, Functors, -->

include("chapter08.jl")
export bimap, bifirst, bisecond, Identity, TypeMaybe, Bifunctors, BiComp, @functor, play_with_bicomp,
        Leaf, Node, 🐟, <--, flip, collect_types, @morphism, PreList, curry, uncurry

include("chapter09.jl")
export ×, ∧

include("chapter10.jl")
export NaturalTransformation, safeHead, listLength, unConst, safeWrap
