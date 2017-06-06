# See https://web.stanford.edu/~lcambier/fast/demo.php
@testset "Optimize Stock with $solver" for solver in lp_solvers
    # With min ⟨[1, 1], [x, θ]⟩ s.t. no constraint with x >= 0, θ free
    # Clp is unable to return the unbounded ray which should be [0, -1]
    isclp(solver) && continue
    numScen = 2
    C = 1
    P = 2
    d = [2, 3]

    m1 = StructuredModel(num_scenarios=numScen)
    @variable(m1, x >= 0)
    @objective(m1, Min, C * x)

    for ξ in 1:numScen
        m2 = StructuredModel(parent=m1, prob=1/2, id=ξ)
        @variable(m2, s >= 0)
        @constraints m2 begin
            s <= d[ξ]
            s <= x
        end
        @objective(m2, Max, P * s)
    end

    num_stages = 2
    cutmode = :AveragedCut
    K = 2
    pereiracoef = 0.1

    # detectlb should change anything here since m2 is min -2s and s is bounded above by x with is unknown so it is unbounded
    for detectlb in [false, true]
        lattice = model2lattice(m1, num_stages, solver, AvgCutPruningAlgo(-1), cutmode, detectlb)
        @test numberofpaths(lattice, 1) == 1
        @test numberofpaths(lattice, 2) == 2
        @test numberofpaths(lattice, 3) == 2
        @test sprint(show, lattice.root) == "Root node of 1 variables and outdegree of 2 with proba: [0.5, 0.5]\n" || sprint(show, lattice.root) == "Root node of 1 variables and outdegree of 2 with proba: [0.5,0.5]\n" # No space on Julia v0.5
        sol = SDDP(lattice, num_stages, K = K, stopcrit = Pereira(0.1) | IterLimit(10), verbose = 0)

        # K = 10 is a multiple of 2 so with ProbaPathSampler(true), the sampling is deterministic
        # therefore we can test for sol.attrs[:niter]
        #
        # Iteration | Status    |  LB  |  UB  | #OC |
        #     1     | Unbounded | -Inf |  0.0 |  1  |
        #     2     | Unbounded | -Inf | -5.0 |  1  |
        #     3     | Optimal   | -2.5 | -2.0 |  1  |
        #     4     | Optimal   | -2.0 | -2.0 |  0  |
        @test sol.attrs[:niter] == 4
        @test sol.status == :Optimal
        @test sol.objval == -2.0
        SDDPclear(m1)
    end
end
