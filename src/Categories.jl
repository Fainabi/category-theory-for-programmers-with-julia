module Categories

include("part1/part1.jl")
include("part2/part2.jl")
include("part3/part3.jl")

function __init__()
    if !isfile(joinpath(@__DIR__, "part1/chapter02.dll"))
        @info "Compile c functions"
        try
            compile_chapter02()
        catch e
        end
    end
end

end # module
