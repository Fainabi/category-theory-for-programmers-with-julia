# Yoneda : a -> x -> F x ≅ F a
#= Challenges
1. phi $ psi fa  = (phi fa ) id  -- definition
                 = fmap id fa
                 = fa

psi $ phi alpha = psi alpha id
                = fmap id alpha = alpha

2. C(a, x) = (x == a) ? {id} : {}

α_x : C(a, x) -> F x
when x ≠ a, α_x is absurb, meaning we only consider α_a : C(a, a) -> F a, which is determined by a,
thus C(a, a) -> F a ≅ {id |> 𝐚 ∈ a} ≅ F a

3. 
α: id -> Int ≅ [()]
=#