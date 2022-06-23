# abstract type AbstractNaturalTransformation end

NaturalTransformation{T} = (FT --> GT) where {FT<:Functors{T}, GT<:Functors{T}}


function safeHead(lst::List{T})::Maybe{T} where T
    if isnothing(maybeTail(lst))
        nothing
    else
        Just(lst.a)
    end
end

function listLength(lst::List{T}) where T
    if isnothing(maybeTail(lst))
        MyConst{0}
    else
        MyConst{1 + unConst(listLength(lst.cons))}
    end
end

unConst(::Type{<:MyConst{C}}) where C = C 

scam(::Type{<:MyConst{x}}) where x = nothing


# challenges
function safeWrap(m::Maybe{T})::List where T
    if isnothing(m)
        nil
    else
        @list T[m.a]
    end
end

