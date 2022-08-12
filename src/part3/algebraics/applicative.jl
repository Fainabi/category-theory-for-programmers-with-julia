export pure, ⊛

Catlab.@theory Applicative{Ob} <: Functor{Ob} begin
    pure(a)::Ob
    ⊛(fab::Ob, fa::Ob)::Ob  # \circledast 
end

# @instance Applicative{AbstractVector} begin
#     pure(::Type{AbstractVector}, a::Any) = [a]
#     ⊛(fab::AbstractVector, fa::AbstractVector) = reduce(vcat, [
#         f.(fa)
#         for f in fab
#     ])
#     fmap(ab::Function, a::AbstractVector) = map(ab, a)
# end
