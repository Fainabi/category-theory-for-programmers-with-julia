export ret, ⊩, ≫

Catlab.@theory Monad{Ob} <: Applicative{Ob} begin 
    ⊩(ma::Ob, amb::Function)::Ob  # \Vdash
    ≫(ma::Ob, mb::Ob)::Ob  # \gg
    ret(a)::Ob
end

@instance Monad{AbstractVector} begin
    pure(::Type{AbstractVector}, a::Any) = [a]
    ⊛(fab::AbstractVector, fa::AbstractVector) = reduce(vcat, [
        f.(fa)
        for f in fab
    ])
    fmap(ab::Function, a::AbstractVector) = map(ab, a)

    ⊩(va::AbstractVector, avb::Function) = reduce(vcat, fmap(avb, va))
    ≫(va::AbstractVector, vb::AbstractVector) = reduce(vcat, [vb for _ in va])
    ret(::Type{AbstractVector}, a::Any) = [a]
end
