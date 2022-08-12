export mempty, mappend

Catlab.@theory Monoid{Ob} <: Semigroup{Ob} begin
    mempty()::Ob
    mappend(a::Ob, b::Ob)::Ob
end
mconcat(va::AbstractVector{T}) where T = reduce(mappend, va)

@instance Monoid{AbstractVector} begin
    mempty(::Type{AbstractVector}) = []
    mappend(a::AbstractVector, b::AbstractVector) = vcat(a, b)
    sconcat(a::AbstractVector, b::AbstractVector) = vcat(a, b)  # why need redefining
end

