# Type `Any` is the union of all types, and thus `id` is the identity morphism over any type. 
id_type(x) = x

# Julia has built-in `∘` operator, which could be typed with `\circ`
# Inputs and outputs are regarded as tuples. 
compose_fun(f, g) = x -> g(f(x))


# One possible category for WWW, the morphism means connected in graph, which satisfies identity and composition law.
# Facebook is less like a category, under setting friendships are morphisms.

