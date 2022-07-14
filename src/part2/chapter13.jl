# ================== Free Monoids  ====================
# Monoids in category
import Catlab.Theories: MonoidalCategory


@instance MonoidalCategory{List, Morphism} begin
    dom(m::Morphism) = m.typechain.first
    codom(m::Morphism) = m.typechain.second
    compose(m1::Morphism, m2::Morphism) = m1 ∘ m2

    otimes(A::List, B::List) = @list [collect(A); collect(B)]
    otimes(f::Morphism, g::Morphism) = (List --> List)(xy -> (f.f ∘ g.f)(xy))  # what is this?
    munit(::Type{List}) = @list []
    id(l::List) = l
end


# Challengs
#=
1. consider the inverse morphism, then it is obvious.
2. e.g. Vec -> length(Vec), * -> +, [] -> 0
3. isomorphic to the natural number set.
=#
