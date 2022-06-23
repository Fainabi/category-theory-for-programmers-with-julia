## Functionality

# Similar to the implementation in Functors{T}, we create a type for abstract bifunctor and the existed ones 
Bifunctors{S, T} = Union{Either{S, T}, Tuple{S, T}, AbstractBifunctor{S, T}, Dict{S, T}}

# add unknown types checking to make inference
# Forget{T} = Union{UnknownType, T}
function (m::Morphism{Bifunctors{A, B}, Bifunctors{C, D}})(x::Bifunctors{<:A, <:B}) where {A, B, C, D}
    m.f(x)
end

function Base.show(io::IO, ::Type{Bifunctors{S, T}}) where {S, T}
    print(io, "Bifunctors{$S, $T)")
end

# regard tuple as a bifunctor product

# Such notation does not support the nested type for inputs, 
# meaning `Bifunctors{A, B} --> Bifunctors{C, D}` as inputs

# (-->)(F::Type, AB::Pair{TypeVar, TypeVar}) = ((A, B) = AB; Morphism{<:F{A}, <:F{B}})

# ====================== Bimap Curry =======================
function bimap(f::(A --> C), g::(B --> D))::(Bifunctors{A, B} --> Bifunctors{C, D}) where {A, B, C, D}
    (Bifunctors{A, B} --> Bifunctors{C, D})(ab -> bimap(f, g, ab))
end

# or more currying
function bimap(f::(A --> C)) where {A, C}
    # parsed to normal function in julia, since the types in Morphism are instances, and here needs parametric types
    function (g::Morphism)
        B, D = g.typechain
        (Bifunctors{A, B} --> Bifunctors{C, D})(ab -> bimap(f, g, ab))
    end
end

# to distinguish with native first method
function bifirst(f::(A --> C)) where {A, C}
    bimap(f, (Any --> Any)(identity))
end

function bisecond(g::(B --> D)) where {B, D}
    bimap((Any --> Any)(identity), g)
end

# ====================== Bimap Implementations =========================
function bimap(f::(A --> C), g::(B --> D), ab::Tuple{A, B})::Tuple{C, D} where {A, B, C, D}
    a, b = ab
    f(a), g(b)
end

function bimap(f::(A --> C), g::(B --> D), aorb::Either{<:A, <:B})::Either{<:C, <:D} where {A, B, C, D}
    if aorb isa Left
        Left(f(aorb.a))
    else
        Right(g(aorb.a))
    end
end


# 8.3
struct Identity{T} <: AbstractFunctor{T}
    a::T
end
TypeMaybe{T} = Either{MyConst{C, T} where C, Identity{T}}


BiComp{T, S} = Bifunctors{Functors{T}, Functors{S}}


function bimap(f::(A --> A′), g::(B --> B′), bf::BiComp{A, B})::BiComp{A′, B′} where {A, B, A′, B′}
    bimap(fmap(f), fmap(g), bf)
end

function play_with_bicomp()
    f_not = (Bool --> Bool)(x -> !x)
    f_upper = (String --> String)(uppercase)
    bf = Tuple{Maybe{Bool}, List{String}}(
        (Just(false), @list ["Category", "is", "fun"])
    )  # tuple
    
    bf => bimap(f_not, f_upper, bf)
end

# Deriving functors
# Recommend to read @functor in Flux.jl, or Functors.jl in FluxML community
# Here we extend structs taking one parametric type
macro functor(T)
    quote
        @eval (@__MODULE__) begin
            S = $T
            proptertyname = fieldname(S, 1)

            function Categories.fmap(f::(A --> B), a::S{<:A})::S{<:B} where {A, B}
                # a default constructor is needed, and only the first value taken
                S(f.f(getproperty(a, proptertyname)))
            end

            # could not make currying, since S may not be a subtype of Functors
            # unless this
            function (m::Morphism{Functors{<:A}, Functors{<:B}})(sa::S{T})::S where {A, B, T<:A}
                m.f(sa)
            end
        end 
    end
end

# Bifunctors could also be derivied, here we'd not do that

# 8.4
abstract type AbstractTree{T} <: AbstractFunctor{T} end  # abstract type does not have a constructor, here we wont use @functor
struct Leaf{A} <: AbstractTree{A}
    a::A
end
struct Node{A} <: AbstractTree{A}
    left::AbstractTree{A}
    right::AbstractTree{A}
end

function fmap(f::(A --> B), a::Leaf{<:A})::Leaf{<:B} where {A, B}
    Leaf(f.f(a.a))
end

function fmap(f::(A --> B), a::Node{<:A})::Node{<:B} where {A, B}
    Node(fmap(f, a.left), fmap(f, a.right))
end

# 8.5
# wirter functor, defined in chapter 04
# haskell said `>=>` its a fish, and we give a fish :D
# \:fish: -> 🐟
++(s1::AbstractString, s2::AbstractString) = s1 * s2
function 🐟(m1::(A --> Writer{B}), m2::(B --> Writer{C}))::(A --> Writer{C}) where {A, B, C}
    (A --> Writer{C})(x -> begin
        y, s1 = m1(x)
        z, s2 = m2(y)
        (z, s1 ++ s2)
    end)
end

function fmap(f::(A --> B), writer::Writer{A})::Writer{B} where {A, B}
    m3 = 🐟((A --> Writer{A})(w_id), (A --> Writer{B})(x -> w_id(f.f(x))))
    x, s1 = writer
    y, s2 = m3(x)
    (y, s1 ++ s2)
end

# 8.6
# reader functor
# Op takes the synonym, so we shape a similar identifier

# (<--){B, A} = Union{AbstractReader{A, B}, Morphism{A, B}}
struct (<--){B, A} <: AbstractReader{A, B} 
    f::Morphism
end

function fmap(f::(A --> B), op::(<--){A, R})::(<--){B, R} where {A, B, R}
    op.f ∘ f
end

# Of course such syntax can extends morphism definition, as what we did in -->
(<--)(B, A) = A --> B


# covariant and contravariant functor
function contramap(f::(B --> A))::(Functors{<:A} --> Functors{<:B}) where {A, B}
    (Functors{<:A} --> Functors{<:B})(x -> contramap(f, x))
end

function contramap(f::(B --> A), op::(<--){A, R})::(<--){B, R} where {A, B, R}
    op.f ∘ f
end

# to implement flip, we could use curry and uncurry
function uncurry(f::(A --> B --> C))::(Tuple{A, B} --> C) where {A, B, C}
    (Tuple{A, B} --> C)(
        xy -> begin
            x, y = xy
            f(x)(y)
        end
    )
end

function curry(f::(Tuple{A, B} --> C))::(A --> B --> C) where {A, B, C}
    (A --> B --> C)(
        a -> (B --> C)(
            b -> f((a, b))
        )
    )
end

function flip(f::(A --> B --> C))::(B --> A --> C) where {A, B, C}
    (B --> A --> C)(
        b -> (A --> C)(
            a -> f(a)(b)
        )
    )
end

# suit for testing
function typelist(t::Type{<:Morphism})
    lst = Union{Type, TypeVar}[]

    if hasproperty(t, :body)
        t = t.body
    end
    if hasproperty(t, :body)
        t = t.body
    end
    a, b = t.parameters

    push!(lst, a)
    if !(b isa TypeVar) && b <: Morphism
        append!(lst, typelist(b))
    else
        push!(lst, b)
    end

    lst
end

# due to the construction of Morphism{..}(..) = new{S, T}(..)
# the chain_def can not handle the parametric types
function chain_def(::Type{Morphism{A, B}}, f) where {A, B}
    if B <: Morphism
        (A --> B)(x -> chain_def(B, (y...) -> f(x, y...)))
    else
        (A --> B)(f)
    end
end

"""
    @morphism type_chain f

This macro is for building Morphism or function obejcts chain from the given f.
Thus does not support parametric types.

Example:
---
```
julia> @morphism Int --> Int --> Int (a, b) -> a+b
```
"""
macro morphism(type_chain, f)
    # types can be A --> B --> C --> D
    # corresponding to f with (a, b, c) -> e
    fname = f.args[1].args[1]
    if !Meta.isexpr(fname, :call)
        # return the anonymous function
        :(chain_def($type_chain, $f))
    else
        # give the function name a morphism
        name = fname.args[1]
        fname.args = fname.args[2:end]
        fname.head = :tuple
        :(global $name = chain_def($type_chain, $f))
    end
end




# profunctors
# Similar to contrafunctors, the profunctors and bifunctors take same input types,
# and form similar mappings, which means we could regard a Tuple as Bifunctor and 
# profunctor.
#
# we could still define Profunctors = Union{...},
Profunctors{S, T} = Bifunctors{S, T}  # same

# To keep the same form, we using regular functions, rather than pure morphism

function dimap(::(A --> B), ::(C --> D), ::Profunctors{B, C})::Profunctors{A, D} where {A, B, C, D} end

function lmap(f::(A --> B), p::Profunctors{B, C})::Profunctors{A, C} where {A, B, C}
    dimap(f, (C --> C)(identity), p)
end

function rmap(g::(B --> C), p::Profunctors{A, B})::Profunctors{A, C} where {A, B, C}
    dimap((A --> A)(identity), g, p)
end

# we are not gonna implement the profunctor for -->

# Challenges
#=
1. Pair{A, B} ≅ Tuple{A, B}
2. Nothing ≅ Tuple{} -> Either (Const () a) (Identity a) ≅ Either (Nothing + a) (Identity a) ≅ Either Nothing a ≅ Maybe
=#

PreList{A, B} = Union{Nil, Cons{A, B}}

function bimap(f::(A --> C), g::(B --> D), prelist::PreList{A, B})::PreList{C, D} where {A, B, C, D}
    if isnothing(maybeTail(prelist))
        nil
    else
        a = prelist.a
        cons = prelist.cons
        PreList(f(a), g(cons))
    end
end

struct K2{C, A, B} <: AbstractBifunctor{A, B} 
    c::C
end
struct Fst{A, B} <: AbstractBifunctor{A, B}
    a::A
end
struct Snd{A, B} <: AbstractBifunctor{A, B}
    b::B
end

function bimap(::(A --> C), ::(B --> D), k2::K2{R, A, B})::K2{R, C, D} where {A, B, C, D, R}
    K2(k2.c)
end
function bimap(f::(A --> C), ::(B --> D), fst::Fst{A, B})::Fst{C, D} where {A, B, C, D}
    fst(f(fst.a))
end
function bimap(::(A --> C), g::(B --> D), snd::Snd{A, B})::Snd{C, D} where {A, B, C, D}
    snd(g(snd.b))
end

# In julia, Dict is used for `std::map` in cpp
function bimap(f::(A --> C), g::(B --> D), dict::Dict{A, B})::Dict{C, D} where {A, B, C, D}
    new_dict = Dict{C, D}()
    for (k, v) in dict
        new_dict[f(k)] = g(v)
    end

    new_dict
end
