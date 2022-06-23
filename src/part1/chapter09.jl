# From this chapter, we are gonna use pure morphism for description

# We may not abstract function object here, since
# `Morphism{A, B}(types, f::F)` with calling is isomorphic to `FunctionObject{Z, A, B}` with `eval`
# I mean, we could implement it.
FunctionObject{A, B} = Morphism{A, B}

function eval(f::FunctionObject{A, B}, a::A)::B where {A, B}
    f(a)
end

# 9.5.4
#= 
"""
Instead of writing one function definition
with a case statement, we usually split it into two (or more) functions
dealing with each type constructor separately. 
"""
is the key idea of julia methods with multiple dispatch
=#


# Here are some more extensions on Morphism{A, B}

# ======== Syntax sugar =====
# this makes (Int, Int) --> Int possible, rather than Tuple{Int, Int} --> Int
-->(as::Tuple, bs::Tuple) = Morphism{Tuple{as...}, Tuple{bs...}}
-->(as::Tuple, b::Union{Type, TypeVar}) = Morphism{Tuple{as...}, b}
-->(a::Union{Type, TypeVar}, bs::Tuple) = Morphism{a, Tuple{bs...}}


# ======== Curry-Howard Morphism =======
# these make A × B to (A, B)
×(a::Union{Type, TypeVar}, b::Union{Type, TypeVar}) = Tuple{a, b}
×(a::Union{Type, TypeVar}, b::Union{Type, TypeVar}...) = Tuple{a, b...}
×(a::Union{Type{<:Tuple}, TypeVar}, b::Union{Type{<:Tuple}, TypeVar}) = Tuple{a, b}
function ×(a::Union{Type{<:Tuple}, TypeVar}, b::Union{Type, TypeVar})
    typesa = hasfield(a, :body) ? a.body.types : a.types
    Tuple{typesa..., b}
end
function ×(a::Union{Type, TypeVar}, b::Union{Type{<:Tuple}, TypeVar})
    typesb = hasfield(b, :body) ? b.body.types : b.types
    Tuple{a, typesb...}
end

const ∧ = ×
