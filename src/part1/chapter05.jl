# the type of inputs in Julia function can be accessed by methods(f)[idx].sig
# while the return type can be opaque, since julia functions are not purexs.
# Base.return_type can work for inference the return type.
# Here we explicitly declare the type.

import Base: ∘

"""
    Morphism{S, T}

This morphism is for category works with types, and thus each object is a typed set.
These morphisms are concrete, and can not implement more general different arbitrary abstract type like in Haskell.
When we want a abstract more general Morphism, just use Any to replace S and T.

Julia functions are naturally morphisms, and the design pattern of Julia determines that
vague declaration of types are more compatible. Thus the morphism here is a concrete abstraction,
while best form is always about native parametric functions.
"""
struct Morphism{S, T} <: AbstractMorphism
    typechain::Pair{Type{S}, Type{T}}  # the input and output type for f
    f::Function
    Morphism(::Type{S}, ::Type{T}, f::Function) where {S, T} = new{S, T}(S => T, f)
    Morphism{S, T}(f::Function) where {S, T} = new{S, T}(S => T, f)
    function Morphism(pair::Pair, f::Function) 
        S, T = pair
        new{S, T}(S => T, f)
    end
end

# eval
function (m::Morphism{S, T})(x::S)::T where {S, T}
    m.f(x)
end

# one could modify it to Base.show(io::IO, t::Type{<:Morphism}),
# but this type could show the difference of 
# `(Int --> Int --> A) where A` and `(Int --> (Int --> A) where A)`
function Base.show(io::IO, t::Type{Morphism{S, T}}) where {S, T}
    types = typelist(t)
    for (idx, type) in enumerate(types)
        if !(type isa TypeVar) && type <: Morphism
            print(io, "(")
            show(io, type)
            print(io, ")")
        else
            print(io, type)
        end
        if idx < length(types)
            print(io, " --> ")
        end
    end
end
function Base.show(io::IO, ::MIME"text/plain", m::Morphism{S, T}) where {S, T}
    # print(io, m.f, ": ", S, " --> ", T)
    print(io, m.f, ": ")
    show(io, Morphism{S, T})
end
function Base.show(io::IO, m::Morphism{S, T}) where {S, T}
    show(io, MIME("text/plain"), m)
end

# with type declared, the composition is easy
function (∘)(g::Morphism{S, T}, f::Morphism{R, S})::Morphism{R, T} where {R, S, T}
    Morphism(R => T, g.f ∘ f.f)
end

# Julia has first and last method, the Pair type has first and second attributes
# first and last work for Pair
function fst(p::Pair{S, T})::S where {S,T}
    first(p)
end
function snd(p::Pair{S, T})::T where {S, T}
    last(p)
end

function factorizier(p::Morphism{C, A}, q::Morphism{C, B})::Morphism{C, Pair{A, B}} where {A, B, C}
    Morphism(C => Pair{A, B}, x -> Pair{A,B}(p(x), q(x)))
end


abstract type Partial end
struct Left{A} <: Partial
    a::A
end
struct Right{B} <: Partial
    a::B
end
Either{A, B} = Union{Left{A}, Right{B}}


function factorizier(i::Morphism{A, C}, j::Morphism{B, C})::Morphism{Either{A, B}, C} where {A, B, C}
    Morphism(Either{A, B} => C, x -> if x isa Left
        i(x.a)
    else
        j(x.a)
    end)
end

# Challenges
#=
2. (a, a -> a, a -> b) is the product of (a, b) in a Poset, if a -> b
3. (b, a -> b, b -> b) is the coproduct of (a, b), if a -> b
=#

# 5.
inj_i(n::Int)::Int = n
inj_j(b::Bool)::Int = ifelse(b, 0, 1)

# Get (Int, inj_i, inj_j) from (Int, Either{Int, Bool})
mor_m(e::Left{Int})::Int = e.a
mor_m(e::Right{Bool})::Int = ifelse(e.a, 0, 1)
# Int ->(Either) Left Int ->(mor_m) Int
# Bool ->(Either) Right Bool ->(mor_m) Int
# No morphism from Int to Either{Int, Bool}, it lost information. 


# 7.
mor_m_7(e::Left{Int})::Int = ifelse(e.a < 0, e.a, e.a + 2)
mor_m_7(e::Right{Bool})::Int = ifelse(e.a, 0, 1)

# 8.
Triplet{A, B, C} = Union{Left{A}, Right{B}, C}