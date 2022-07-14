# Representable, tabulate and index


# Challenges
#=
1. hom: Cᵒᵖ × C -> Set, hom(_, id) : hom(_, a) -> hom(_, a) ≅ id ∈ Set
2. Maybe{T} = Union{Nothing, Just{T}} ≅ Union{Tuple, Tuple{T}} ≅ List{T} with just one element
3. # Reader a x = a -> x
    Reader{A, T} == -->{A, T} == A --> T

Consider the functor Reader{A}, which is covariant.
Then it is representable, with `a` to represent.
=#

# 4. try implementing the lazy trait
mutable struct Stream{T}
    state::Int
    f::(Int --> T)
end

function next!(s::Stream)
    nowstate = copy(s.state)
    s.state = nowstate + 1
    s.f(nowstate)
end

function tabulate(f::(Int --> T)) where T
    Stream{T}(0, f)
end
function index(s::Stream, n)
    s.f(n)  # cheat here I know
end

square = (Int --> Int)(x -> x * x)



#=
5.
For non-negative numbers

index (tabulate f) n = index (Cons (f 0) (tabulate (f . (+1)))) n  -- definition
                     = if n == 0
                        then (f 0)  -- definition
                        else index (tabulate (f . (+1))) (n-1)
                    -- recursive and proved.

=#

#=
6. In Julia, Core types can not be modified.
=#
RepresentablePair{T} = Pair{T, T}  # ≅ Stream with length 1
RepresentablePair(a) = Pair(a, a)

(m::Morphism{Nothing, T})() where T = m.f()

function tabulate(f::(Nothing --> T))::RepresentablePair{T} where T
    RepresentablePair(f())
end
function index(t::RepresentablePair{T})::(Nothing --> T) where T
    () -> t.first
end
