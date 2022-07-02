import Catlab: @theory, @instance, @signature, @present
import Catlab.Theories: Category
import Catlab

#=
The main content in part1, is about the category basics, functors, Set, and transformations.
=#

# ========================== Chapter 01 ================================
#=
@theory Category{Ob, Hom} begin
    # alias for operation
    @op begin
        (→) := Hom
        (⋅) := compose
    end

    # type constructors
    Ob::TYPE
    Hom(dom::Ob, codom::Ob)::TYPE

    # term constructros
    id(A::Ob)::(A → A)
    compose(f::(A → B), g::(B → C))::(A → C) ⊣ (A::Ob, B::Ob, C::Ob)

    # rules
    (f ⋅ g) ⋅ h == f ⋅ (g ⋅ h) ⊣ (A::Ob, B::Ob, C::Ob, D::Ob,
                                f::(A → B), g::(B → C), h::(C → D))
    f ⋅ id(B) == f ⊣ (A::Ob, B::Ob, f::(A → B))
    id(A) ⋅ f == f ⊣ (A::Ob, B::Ob, f::(A → B))
end
=#
Catlab.Theories.Category


# ========================== Chapter 02 ================================
# regard types as sets

TypeSet = Union{Type, TypeVar}
@instance Category{TypeSet, Morphism} begin
    dom(m::Morphism) = m.typechain.first
    codom(m::Morphism) = m.typechain.second

    id(T::TypeSet) = Morphism(T => T, identity)
    compose(f::Morphism, g::Morphism) = f ∘ g
end

# or
Catlab.CategoricalAlgebra.Categories.TypeCat

# ========================= Chapter 03 ================================
# @theory ThinCategory{Ob, Hom} <: Category{Ob, Hom} begin
#     f == g ⊣ (A::Ob, B::Ob, f::Hom(A,B), g::Hom(A,B))
# end
Catlab.Theories.ThinCategory

#=
@theory Preorder{Ob, Hom} <: ThinCategory{Ob, Hom} begin
    @op begin
        El := Ob
        Leq := Hom
        (≤) := Hom
        reflexive := id
        transive := compose
    end

    # reflexive(A::El)::(A≤A)
    # transive(f::(A≤B), g::(B≤C))::(A≤C) ⊣ (A::El, B::El, C::El)
end
=#
# While in Catlab.jl, Preorder is a standard theory separated from Category
# Thus in the source file, the author says there is an isomorphism between Preorder and ThinCategory
Catlab.Theories.Preorder

#=
@theory PartialOrder{El, Leq} <: Preorder{El, Leq} begin
    A == B ⊣ (A::El, B::El, f::(A≤B), g::(B≤A))
end
=#
Catlab.Theories.Poset

# Monoid is a category within a single object
#=
@theory MonoidThoery{Ob, Hom} <: Category{Ob, Hom} begin
    A == B ⊣ (A::Ob, B::Ob)
end
=#
Catlab.Theories.MonoidalCategory

# ========================= Chapter 04 =============================
# Kleisli is defined with monad, thus here pass it

# ========================= Chapter 05 =============================
# To define product and coproduct in Catlab.jl needs limit and colimit.
# Leave it for part2.

# ========================= Chapter 07 =============================
# Functors in categorical algebra
import Catlab.CategoricalAlgebra.Categories: FunctorCallable, TypeCat

# The `Morphism` here can change to `Function`, leaving type check to multiple dispatch
MaybeCat{T} = TypeCat{Maybe{T}, Maybe{T} --> Maybe{T}}
MaybeFunctor{T} = FunctorCallable{TypeCat{T, T --> T}, MaybeCat{T}}

function MaybeFunctor{T}() where T
    MaybeFunctor{T}(
        Just,
        f -> x -> isnothing(x) ? nothing : Just(f(x.a)),  # fmap
        TypeCat(T, T --> T),
        MaybeCat{T}(),
    )
end

# more generally
function functorize(t::Type{<:Functors{T}}, ob_map) where T
    Catlab.CategoricalAlgebra.Categories.Functor(
        ob_map isa Function ? ob_map : x -> ob_map(x),
        fmap,
        TypeCat(T, T --> T),
        TypeCat(t, t --> t),
    )
end

functorize(t::Type{<:Functors{T}}) where T = functorize(t, t)

# ========================= Chapter 10 ===========================
# 2-Categories
Catlab.CategoricalAlgebra.Categories.Category2
# or
Catlab.Theories.Category2

# natural transformation
Catlab.CategoricalAlgebra.Categories.Transformation

