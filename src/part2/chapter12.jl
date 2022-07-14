# =========================== Limits and Colimits ========================

# Limits and Colimits in Catlab
Catlab.CategoricalAlgebra.Limit

import Catlab.CategoricalAlgebra: FinFunctor, FinTransformation, Diagram

trivial_cone = let 
    # cats
    @present 𝟐(FreeCategory) begin
        (𝟙, 𝟚)::Ob
    end

    @present 𝐂(FreeCategory) begin
        (a, b, c)::Ob
        p::Hom(c, a)
        q::Hom(c, b)
    end

    # functors
    Δcₒ = Dict(:𝟙 => :c, :𝟚 => :c)
    Δcₕ = Dict()
    Δc = FinFunctor(Δcₒ, Δcₕ, 𝟐, 𝐂)

    Dₒ = Dict(:𝟙 => :a, :𝟚 => :b)
    Dₕ = Dict()
    D = FinFunctor(Dₒ, Dₕ, 𝟐, 𝐂)
    
    # cone
    cone = FinTransformation(Dict(:𝟙 => :p, :𝟚 => :q), Δc, D)
    (𝟐, 𝐂, Δc, D, cone)
end
# Catlab.CategoricalAlgebra.is_natural(trivial_cone) == true

ItoC = let 
    @present 𝐈(FreeCategory) begin
        (I1, I2, I3)::Ob
        m12::Hom(I1, I2)
        m13::Hom(I1, I3)
        m23::Hom(I2, I3)
    end

    @present 𝐂(FreeCategory) begin
        (c, e, f, g)::Ob
        mce::Hom(c, e)
        mcf::Hom(c, f)
        mcg::Hom(c, g)
        mef::Hom(e, f)
        mfg::Hom(f, g)
        meg::Hom(e, g)
        idc::Hom(c, c)
    end

    # diagrams
    Δc = FinFunctor(
        Dict(:I1 => :c, :I2 => :c, :I3 => :c),
        Dict(:m12 => :idc, :m13 => :idc, :m23 => :idc),
        𝐈,
        𝐂,
    )

    D = FinFunctor(
        Dict(:I1 => :e, :I2 => :f, :I3 => :g),
        Dict(:m12 => :mef, :m23 => :mfg, :m13 => :meg),
        𝐈,
        𝐂,
    )

    cone = FinTransformation(
        Dict(:I1 => :mce, :I2 => :mcf, :I3 => :mcg),
        Δc,
        D,
    )

    (𝐈, 𝐂, Δc, D, cone)
end

# calling is_hom_equal(ItoC) fails, because during comparation
# `is_hom_equal` directly compares two compose function, which fails at `args` attribute for different components

# terminal object is the limit of empty category
# at Catlab.CategoricalAlgebra.Limits.jl 
# terminal(T::Type; kw...) = limit(EmptyDiagram{T}(); kw...)


cospan = let 
    @present 𝟑(FreeCategory) begin
        (𝟙, 𝟚, 𝟛)::Ob
        from1::Hom(𝟙, 𝟚)
        from3::Hom(𝟛, 𝟚)
    end

    @present Pullback(FreeCategory) begin
        (a, b, c, d)::Ob
        f::Hom(a, b)
        g::Hom(c, b)
        p::Hom(d, a)
        q::Hom(d, c)
        r::Hom(d, b)
    end

    cospan = Diagram(FinFunctor(
        Dict(:𝟙 => :a, :𝟚 => :b, :𝟛 => :c),
        Dict(:from1 => :f, :from3 => :g),
        𝟑,
        Pullback,
    ))
end

# diamond
abstract type TypeA end
abstract type TypeB <: TypeA end
abstract type TypeC <: TypeA end
TypeD = Union{TypeB, TypeC}  # <: TypeA
TypeE = Union{TypeB, TypeC}  # == TypeD, thus (<: TypeD)

abstract type TypeF <: TypeC end
TypeG = Union{TypeB, TypeF}  # <: TypeD

#
#   Challenges
#

# 1. pushout in julia types can be done the function:
typejoin  # T -> S -> Pushout{T, S}
# if the arrow shows a supertype, A -> supertype(A)

# 2. Only initial objects have transformations to any other object in category 𝐂
# And they are isomorphic.

# 3. pullback is the common part of subsets, and pushout is the union
# ø as the initial, and whole set the terminal

# 4. the colimit such that (s . f) == (s . g), thus the union of solution of f, and g.
# thus (fg = 0). The multiplication of two equations is the union.

# 5. pullback must towards terminal, and it is a universal cone, thus producing the limits which is a product 