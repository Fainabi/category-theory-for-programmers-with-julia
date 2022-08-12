export ++, sconcat, stimes

Catlab.@theory Semigroup{Ob} begin
    @op begin
        (++) := sconcat
    end

    Ob::TYPE

    sconcat(a::Ob, b::Ob)::Ob
end
stimes(b::Integer, a) = reduce(sconcat, fill(a, b))

# @instance Semigroup{AbstractVector} begin
#     sconcat(a::AbstractVector, b::AbstractVector) = vcat(a, b)
# end

# @instance Semigroup{Maybe} begin
#     function sconcat(a::Maybe, b::Maybe)
#         if isnothing(a) || isnothing(b)
#             nothing
#         else
#             Just(sconcat(a.a, b.a))
#         end
#     end
# end

