#=
    Here we implement some basic concepts of category for abstraction.
The complete category system is not supposed to be implemented, here is a existing pacakge:
Catlab.jl, which implemented this. 
    Instead, we are focusing on the julia itself in the category pattern, not to create a library.
=#

abstract type AbstractCategory end
abstract type AbstractMonoid{T} <: AbstractCategory end
abstract type AbstractAlgebraicOperation <: Function end


function append(::AbstractMonoid, ::AbstractMonoid) end
append(m::AbstractMonoid) = Base.Fix1(append, m)  # a simple implementation of currying
(++)(m1::AbstractMonoid, m2::AbstractMonoid) = append(m1, m2)
(++)(m::AbstractMonoid) = append(m)

# Monoid with parametric type 

struct Monoid{T} <: AbstractMonoid{T}
    x::T
end
emptyof(M::Type{Monoid{T}}) where T = M()  # Base has empty function

struct MonoidOperation{T} <: AbstractAlgebraicOperation
    f::Function
    MonoidOperation{T}(f::Function) where T = new(f)
    MonoidOperation(::Type{Monoid{T}}, f::Function) where T = new{T}(f)
end
(op::MonoidOperation{T})(m1::Monoid{T}, m2::Monoid{T}) where T = Monoid{T}(op.f(m1.x, m2.x))
(op::MonoidOperation{T})(m::Monoid{T}) where T = Base.Fix1(op, m)  # curry

## Monoid String
# In the book, it says the haskell implementation
# ```haskell
#   class Monoid m where
#       mempty:: m
#       mappend:: m -> m -> m 
# ```
# Since Julia is not an OO programming language, we do not have static methods here for structure
# but only call with the instances. The only one that take parametric type not in the parameters is the constructor.
Monoid{T}() where T <: AbstractString = Monoid("")
append(m1::Monoid{T}, m2::Monoid{T}) where T <: AbstractString = Monoid(m1.x * m2.x)

## Monoid Numbers, julia numbers inlcude Bool
Monoid{T}() where T <: Number = Monoid(zero(T))


## Challenges
abstract type AbstractFreeCategory{T} <: AbstractCategory end

mutable struct FreeCategory{T} <: AbstractFreeCategory{T}
    points::AbstractVector{T}
    arrows::AbstractVector{Tuple{T, T}}
    FreeCategory{T}() where T = new(T[], Tuple{T, T}[])
end
mutable struct NamedFreeCategory{T} <: AbstractFreeCategory{T}
    points::AbstractVector{T}
    arrows::AbstractVector{Tuple{T, T, AbstractString}}
    NamedFreeCategory{T}() where T = new(T[], Tuple{T, T, AbstractString}[])
end

addpoint!(𝒞::AbstractFreeCategory{T}, point::T) where T = push!(𝒞.points, point)
addarrow!(𝒞::FreeCategory{T}, arrow::Tuple{T, T}) where T = push!(𝒞.arrows, arrow)
addarrow!(𝒞::NamedFreeCategory{T}, arrow::Tuple{T, T}, name="") where T = push!(𝒞.arrows, (arrow..., name))

function one_node_no_edge_graph()
    𝒞 = FreeCategory{Int}()
    addpoint!(𝒞, 0)
    𝒞
end
function one_node_one_edge_graph() 
    𝒞 = FreeCategory{Int}()
    addpoint!(𝒞, 0)
    addarrow!(𝒞, (0, 0))
    𝒞
end
function two_nodes_one_edge_graph()
    𝒞 = FreeCategory{Int}()
    addpoint!(𝒞, 0)
    addpoint!(𝒞, 1)
    addarrow!(𝒞, (0, 1))
    𝒞
end
function one_node_26_edges_graph()
    𝒞 = NamedFreeCategory{Int}()
    addpoint!(𝒞, 0)
    for name in 'a':'z'
        addarrow!(𝒞, (0, 0), string(name))
    end
    𝒞
end

function bool_category()
    𝒞_bool = NamedFreeCategory{Bool}()
    addpoint!(𝒞_bool, true)
    addpoint!(𝒞_bool, false)

    
    addarrow!(𝒞_bool, (true, true), "&&(true)")
    addarrow!(𝒞_bool, (true, false), "&&(false)")
    addarrow!(𝒞_bool, (false, false), "&&(true)")
    addarrow!(𝒞_bool, (false, false), "&&(false)")

    𝒞_bool
end


# Monoid Category
abstract type AbstractMonoidCategory{T} <: AbstractCategory end
mutable struct MonoidCategory{T} <: AbstractMonoidCategory{T}
    points::AbstractVector{Monoid{T}}
    arrows::AbstractVector{Tuple{Monoid{T}, Monoid{T}, Function}}
    op::MonoidOperation{T}
    MonoidCategory{T}() where T = new(Monoid{T}[], Tuple{Monoid{T}, Monoid{T}, Function}[], MonoidOperation{T}(id))
end
addpoint!(𝒞::AbstractMonoidCategory{T}, point::Monoid{T}) where T = push!(𝒞.points, point)
addarrow!(𝒞::AbstractMonoidCategory{T}, arrow::Tuple{Monoid{T}, Monoid{T}, Function}) where T = push!(𝒞.arrows, arrow)

function add_mod_3()
    points = Monoid{Int}.([0, 1, 2])
    𝒞 = MonoidCategory{Int}()
    op = MonoidOperation{Int}((x, y) -> mod(x+y, 3))
    foreach(p -> addpoint!(𝒞, p), points)
    𝒞.op = op
    for a in points
        add_a = 𝒞.op(a)
        for p in points
            addarrow!(𝒞, (p, add_a(p), add_a))
        end
    end

    𝒞
end
