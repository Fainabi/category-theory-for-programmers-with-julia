Catlab.@theory Functor{Ob} begin
    Ob::TYPE
    fmap(ab::Function, a::Ob)::Ob
end

# @instance Functor{AbstractVector} begin
#     # (A -> B) -> [A] -> [B]
#     fmap(ab::Function, a::AbstractVector) = map(ab, a)
# end

# @instance Functor{Maybe} begin
#     fmap(ab::Function, a::Maybe) = isnothing(a) ? nothing : Just(ab(a.a))
# end
