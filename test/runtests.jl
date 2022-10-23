using Test
using Categories
import Random

Categories.compile_chapter02()

@testset "Tests from chapter01, composition" begin
    for _ in 1:10
        randvec = rand(100);

        id_sum = sum ∘ identity
        sum_id = identity ∘ sum

        id_min = minimum ∘ identity
        min_id = identity ∘ minimum

        @test sum_id(randvec) ≈ id_sum(randvec)
        @test min_id(randvec) ≈ id_min(randvec)
    end
end

@testset "Tests from chapter02, memoize" begin
    @testset "Challenge 2, random number" begin
        clear_memoize()
        first_rand = memoize(rand)
        for _ in 1:10
            @test first_rand ≈ memoize(rand)
        end
    end

    @testset "Challenge 3, random with seed" begin
        clear_memoize()
        for seed in 1:10
            memoize(Random.seed!, seed)
            rand1 = rand()

            memoize(Random.seed!, seed)
            @test rand1 ≉ rand()
        end
    end

    @testset "Challenge 4, pure functions" begin
        # factorial
        clear_memoize()
        factorials = memoize.(factorial, 1:10)
        @test factorials == factorial.(1:10)

        origin = f_int(0)
        for idx in 1:5
            inputs = collect(1:10)
            for i in 1:length(inputs)
                @test memoize(f_int, inputs[i]) == origin + sum(inputs[1:i])
            end
        end
    end
end

import Categories: Chapter03
@testset "Tests from chapter03, monoids" begin
    @testset "Challenge 3, bool monoids" begin
        # Julia && and || are not identifiers
        AND = Chapter03.MonoidOperation(Chapter03.Monoid{Bool}, &)
        OR = Chapter03.MonoidOperation(Chapter03.Monoid{Bool}, |)
        m_true = Chapter03.Monoid(false)
        m_false = Chapter03.Monoid(false)
        m_bool = [m_true, m_false]

        # (m_bool, AND) and (m_bool, OR) are two monoids
        for x1 in m_bool, x2 in m_bool
            @test AND(x1, x2) in m_bool
            @test OR(x1, x2) in m_bool
        end

        # unit of && is true, unit of || is false
        @test OR(m_false, m_false) == m_false
        @test OR(m_false, m_true) == m_true
        @test AND(m_true, m_false) == m_false
        @test AND(m_true, m_true) == m_true
    end
end

@testset "Tests from chapter04, Kleisli category" begin
    rs = rand(-5:10, 20)
    for r in rs
        if r > 0
            @test sqrt(1/r) == safe_root_reciprocal(r).value
        else
            @test !safe_root_reciprocal(r).valid
        end
    end
end

@testset "Tests from chapter07, Functors" begin
    maybe_id = x -> fmap(Morphism(Int => Int, identity), Just(x))
    for x in rand(1:100, 10)
        @test maybe_id(x) == Just(x)
    end

    # test on compose of functors
    origin_list = @list 1:10
    square_list = @list (1:10).^2
    just_list = @list Just.(1:10)
    just_square_list = @list map(x -> Just(x^2), 1:10)

    f_square = Morphism(Int => Int, x -> x^2)
    
    @test fmap(f_square, origin_list) == square_list
    @test fmap(fmap(f_square), just_list) == just_square_list
    @test (fmap ∘ fmap)(f_square)(just_list) == just_square_list

    #=
    1. fmap _ _ = Nothing, does not build a functor, because Maybe is not trivial
    =#
    function trivial_fmap(::Morphism{A, B}, ::Maybe{A})::Maybe{B} where {A, B}
        nothing
    end
    for _ in 1:10
        r1, r2 = rand(2)
        @test trivial_fmap(Morphism(Float64 => Float64, identity), Just(r1)) != Just(r2)
    end

end

@testset "Tests from chapter10, natural transformation" begin
    add10 = (Float64 --> Float64)(x -> x + 10)
    for _ in 1:10
        lst = @list rand(10)
        val = rand()
        @test fmap(add10, safeHead(lst)) == safeHead(fmap(add10, lst))
        @test fmap(add10, safeWrap(Just(val))) == safeWrap(fmap(add10, Just(val)))
    end

end