function swap(p::Pair{A, B})::Pair{B, A} where {A, B}
    a, b = p
    b => a
end

function alpha(p::Pair{Pair{A, B}, C})::Pair{A, Pair{B, C}} where {A, B, C}
    (a, b), c = p
    a => b => c
end

function alpha_inv(p::Pair{A, Pair{B, C}})::Pair{Pair{A, B}, C} where {A, B, C}
    a, (b, c) = p
    (a => b) => c
end

# () is the singleton of Tuple{}
function rho(p::Pair{A, Tuple{}})::A where A
    p.first
end

function rho_inv(a::A)::Pair{A, Tuple{}} where A
    a => ()
end

Stmt = Pair{String, Bool}

struct Just{T}; a::T end

# nothing is the singleton of Nothing, and thus () is isomorphic to nothing
Maybe{T} = Union{Nothing, Just{T}}

Base.show(io::IO, m::Just{T}) where T = print(io, string("Just(", m.a, ")"))
Base.string(j::Just{T}) where T = string("Just(", j.a, ")")

# Julia Struct attributes are all public, thus no need for getter
struct Element
    name::String
    symbol::String
    atomicNumber::Int
end
startsWithSymbol(e::Element)::Bool = startswith(e.name, e.symbol)

# A definition of List. In julia, Vector is always used.
abstract type AbstractList{T} end
abstract type AbstractCons{T, S} <: AbstractList{T} end
struct Nil end
const nil = Nil()

## Note from chapter08. The cons is constructed with two parametric types, in order for bifunctor.
struct Cons{T, S} <: AbstractCons{T, S}
    a::T
    cons::S
end

List{T} = Union{Nil, AbstractList{T}}
function list_to_string(l::List{T}, nowlen=0) where T
    if nowlen > 10
        "..."
    elseif isnothing(maybeTail(l)) 
        "nil"
    else
        string("(", string(l.a), " ", list_to_string(l.cons, nowlen+1), ")")
    end
end
function Base.show(io::IO,  l::List{T}) where T
    print(io, list_to_string(l))
end

from_vec(v::AbstractVector) = isempty(v) ? nil : Cons(first(v), from_vec(v[2:end]))  # if len == 2, v[2:end] = []

"""
    @list

From a abstract vector construct a list.
"""
macro list(v)
    :(from_vec($(esc(v))))
end


# using multiple dispatch is better thant input a Union type
# function maybeTail(::List{T})::Maybe{List{T}} where T end
maybeTail(::Nil) = nothing
maybeTail(c::Cons) = Just(c.cons)

# Either is constrcuted as Union, and thus the function is better to use multiple dispatch
function prodToSum(a::A, b::Left{B})::Left{Tuple{A, B}} where {A, B}
    Left((a, b.a))
end
function prodToSum(a::A, c::Right{C})::Left{Tuple{A, C}} where {A, C}
    Right((a, c.a))
end
function prodToSum(abc::Tuple{A, Either})::Either where A
    prodToSum(abc...)
end

# or work with sum/coproduct, but no parametric type. Because when we enter Left, we would not know the right type.
function prodToSum2(a, bc::Either)::Either{<:Tuple, <:Tuple}
    if bc isa Left
        Left((a, bc.a))
    else
        Right((a, bc.a))
    end
end

#=
    One note for the paradiam difference on "better" in the book. The book says
`Either` is a better coproduct. Here we have

        A  -> Left{A}  ->  Either{A, B}  <- Right{B}  <- B
        |       |               ||             |         |
        |       |               ||             |         |
        |       |               ||             |         |
        |       |               ||             |         |
        |       |               \/             |         |
        ------->--------------> Either<---------<---------
                                ||
                                ||
                                ||
                                ||
                                \/
                                D

The Middle Eihter here is `better` than D with (A -> D) and (B -> D), is a better abstraction.
However, in Julia, its better to produce multiple dispatch, which is `isomorphic` to the unioned Either type.
That means we need to balence between the completely pure abstraction, and the computation needed.

What is better in Julia, is to work more with products, or concrete defined types, with common methods. For example:
```julia
    function mysimilar(p::Partial, val) end
    function mysimilar(::Left{T}, val::T)::Left{T}
        Left(val)
    end
    function mysimilar(::Right{T}, val::T)::Right{T}
        Right(val)
    end

    function prodToSum(a::A, bc::Partial)::Partial
        mysimilar((a, bc.a))
    end
```

That's why `abstract type` is always used, it is essentially a rather good coproduct. 
Also, the `Partial` type is not `better` than `Tuple{Left, Right}` in the book.
Compromise is needed.
=#

function sumToProd(ab::Left{Tuple{A, B}})::Tuple{A, Left{B}} where {A, B}
    a, b = ab.a
    (a, Left(b))
end
function sumToProd(ac::Right{Tuple{A, C}})::Tuple{A, Right{C}} where {A, C}
    a, c = ac.a
    (a, Right(c))
end
function sumToProd2(ab_ac::Either{Tuple, Tuple})::Tuple{Any, Either}
    if ab_ac isa Left
        a, b = ab_ac.a
        (a, Left(b))
    else
        a, c = ab_ac.a
        (a, Right(c))
    end
end

# Challenges
# Nothing ≅ () -> Maybe a ≅ Either () a

# Defining abstract super type is usually better than union type
abstract type Shape end
struct Circle <: Shape
    r::Real
end
struct Rect <: Shape
    a::Real
    b::Real
end

function area(::Shape)::Real end
area(c::Circle) = π * c.r^2
area(rect::Rect) = rect.a * rect.b

function circ(::Shape)::Real end
circ(c::Circle) = 2π * c.r
circ(rect::Rect) = 2 * (rect.a + rect.b)

struct Square <: Shape
    a::Real
end
area(s::Square) = s.a^2
circ(s::Square) = 4s.a
