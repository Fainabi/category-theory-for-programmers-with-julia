# Kleisli Categories
Writer{T} = Tuple{T, AbstractString}

# no need to point out the input and return type of f, g
w_compose(f, g) = x -> begin
    (res_f, log_f) = f(x)
    (res_g, log_g) = g(res_f)
    (res_g, log_f * log_g)
end

w_id(x) = (x, "")



# Julia Strings value are immutable
toUpper(str::AbstractString) = Writer((uppercase(str), "toUpper "))
# it is same to toUpper(str::AbstractString) = (uppercase(str), "toUpper ")

toWords(str::AbstractString) = (split(str, " "), "toWords ")
process = w_compose(toUpper, toWords)

negate(b::Bool) = Writer((!b, "Not so! "))
isEven(n::Integer) = (n % 2 == 0, "isEven ")
isOdd = w_compose(isEven, negate)

# challenges

# Julia has `Some` type
abstract type AbstractOption end
struct Option{T} <: AbstractOption
    valid::Bool
    value::T
end

option_compose(f, g) = x -> begin
    opt_fx = f(x)
    opt_gx = g(opt_fx.value)
    Option(opt_fx.valid && opt_gx.valid, opt_gx.value)
end
option_id(x) = Option(true, x)

safe_reciprocal(x) = if iszero(x)
    Option(false, zero(x))
else
    Option(true, 1/x)
end

safe_root(x) = if x >= 0
    Option(true, sqrt(x))
else
    Option(false, zero(x))
end

safe_root_reciprocal = option_compose(safe_reciprocal, safe_root)