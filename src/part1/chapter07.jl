# `Maybe` in Haskell is a type constructor, and the former chapter we defined as 
# Maybe{T} = Union{Nothing, Just{T}} 
# The parametric type is isomorphic to what haskell did
#
# Better not do `Maybe(T::DataType) = Union{Nothing, Just{T}}`, but keep julia fashion here.

# One can inspect the fmap implementation in Flux.jl, which is more general on structs
# The Morphism used here are for type clearation. One should always use julia fasion methods.


# Here we construct a coproduct type, since we have defined Maybe and List with different abstract type, 
# so we can not construct their common super type other than `Any`. But the following types then can be concluded in AbstractFunctor.
Functors{T} = Union{Maybe{T}, List{T}, Morphism{T, C where C}, AbstractFunctor{T}, Writer{T}}
function Base.show(io::IO, ::MIME"text/plain", ::Type{Functors})
    print(io, "Functors")
end

## fmap :: (a -> b) -> F a -> F b
function fmap(f::Morphism{A, B})::Morphism{Functors{<:A}, Functors{<:B}} where {A, B}
    Morphism(Functors{<:A} => Functors{<:B}, x -> fmap(f, x))
end

## implementations
# Maybe
function fmap(f::Morphism{A, B}, x::Maybe{A})::Maybe{B} where {A, B}
    isnothing(x) ? nothing : Just(f(x.a))
end

# List
function fmap(f::Morphism{A, B}, x::List{A})::List{B} where {A, B}
    if isnothing(maybeTail(x))
        nil
    else
        Cons(f(x.a), fmap(f, x.cons))
    end
end

# Const, differ from Core.Const
struct MyConst{C, A} <: AbstractFunctor{A} end
function fmap(::Morphism{A, B}, ::MyConst{C, A})::MyConst{C, B} where {A, B, C}
    MyConst{C, B}()
end

# fmap over functions
function fmap(f::Morphism{A, B}, g::Morphism{R, A})::Morphism{R, B} where {A, B, R}
    Morphism(R => B, f.f∘g.f)
end

## the general difinition can not work on Morphism{A, B}, since it has two parametric types
## Unless we define such extension
function (f::Morphism{Functors{A}, Functors{B}})(g::Morphism{C, A}) where {A, B, C}
    f.f(g)
end
## Such function is needed for every multiple-type structs, which kind of destroys the design or Morphism
## Thus `MyConst` and `-->` takes one parametric type.

# normal implementations
fmap(f, x::Maybe) = isnothing(x) ? nothing : Just(f(x.a))
fmap(f, lst::List) = isnothing(maybeTail(lst)) ? nil : Cons(f(lst.a), fmap(f, lst.cons))
fmap(f, vec::AbstractVector) = map(f, vec)  # julia native implementation on Iterators


## Challenges
#=
2. Reader Functor

`->` in Julia is also function mapping, but is not an identifier, thus could not just define new methods
Let's just use `-->`. 

Make `-->` as a constructor of Morphism.
=#

abstract type AbstractReader{A, B} <: AbstractBifunctor{A, B} end

"""
Implies `A => B` function type.

Constructor `(-->)` for Morphism
---
`T --> S` will give a `Morphism` type constructor, e.g. `(Int --> Bool)(iseven)` constructs `Morphism(Int => Bool, iseven)`.
Chain is supported, in julia, the infix operator packs tails first.
"""
struct (-->){A, B} <: AbstractReader{A, B}
    f::Morphism
end

function fmap(f::Morphism{A, B}, reader::(-->){R, A})::(-->){R, B} where {R, A, B}
    f ∘ reader.f
end

# ============ Morphism Constructor ============
function (-->)(A::Union{TypeVar, Type}, B::Union{Type, TypeVar}) 
    Morphism{A, B}
end


