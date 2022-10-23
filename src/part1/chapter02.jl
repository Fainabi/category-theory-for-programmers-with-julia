import Libdl

# Base.Bottom <: Union{}
struct Bottom end

const ⊥ = Bottom()
const bottom = ⊥


# Cant give a concrete not `Nothing` parametric return type, could we?
function absurb end

# In Julia, no return value means `nothing` returns, thus it essentially equal to
# `function unit(_) end`. Single pair of `()` in julia is `Tuple{}`, while function call has form `f()`, 
# with no space inside, thus here we still consider `Nothing` inputs, rather than inputs causing `f(())`.
function unit(_::Any)::Nothing end

# `Bool` is a type in julia, similar to bool in cpp, it has intrisinc value of 0, and 1.
# However, Julia is a strong type language, thus
# ```
#   if 1
#       ...
#   end
# ```
# is not legal.
@enum EnumBool begin
    FALSE   # equals 0
    TRUE    # equals 1
end

abstract type TypeBool end
struct TypeTrue <: TypeBool end
struct TypeFalse <: TypeBool end
const True = TypeTrue()
const False = TypeFalse()

# Challenges
MemoizedTable = Dict()

function memoize(f, args...)
    key = (nameof(f), args...)
    if !haskey(MemoizedTable, key)
        MemoizedTable[key] = f(args...)
    end

    MemoizedTable[key]
end

clear_memoize() = empty!(MemoizedTable)

extfile = joinpath(@__DIR__, "chapter02." * Libdl.dlext)

# for cpp like codes
# Cxx.jl is still under fixing and updating, thus here use c codes
function compile_chapter02()
    if isfile(extfile)
        return
    end

    C_code = raw"""
// Cxx.jl is still under fixing, here use C codes
#include <stdbool.h>
#include <stdio.h>

bool f_bool() {
    puts("Hello!\n");
    return true;
}

int f_int(int x) {
    static int y = 0;
    y += x;
    return y;
}
"""
    open(`gcc -xc -shared -o $(extfile) -`, "w") do f
        print(f, C_code)
    end
end

getchar() = ccall(:getchar, Cchar, ())
f_int(x::Int) = ccall((:f_int, extfile), Cint, (Cint, ), x)
f_bool() = ccall((:f_bool, extfile), Bool, ())

pure_bool2bools = [
    (x::Bool) -> id(x),
    (_::Bool) -> true,
    (_::Bool) -> false,
    (x::Bool) -> !x, 
]


# user interactive test units
function test_getchar()
    clear_memoize()
    @info "Testing `getchar()` now, enter two characters: "
    char1 = memoize(getchar)
    @info string("First one: ", char1, ", second one: ", memoize(getchar))
end

function test_fbool()
    clear_memoize()
    @info "Run `memoize(f_bool)` for 10 times, and there should be only one \"Hello!\" to print."
    map(1:10) do _
        memoize(f_bool)
    end
end


