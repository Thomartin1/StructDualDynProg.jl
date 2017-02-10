function fulltest(m, num_stages, objval, solval, ws, wsσ)
    for K in [-1, 42]
        for maxncuts in [-1, 7]
            for newcut in [:AddImmediately, :InvalidateSolver]
                for cutmode in [:MultiCut, :AveragedCut]
                    for cutpruner in [AvgCutPruner(maxncuts), DecayCutPruner(maxncuts)]
                        root = model2lattice(m, num_stages, solver, cutpruner, cutmode, newcut)

                        μ, σ = waitandsee(root, num_stages, solver, K)
                        @test abs(μ - ws) / ws < (K == -1 ? 1e-6 : .03)
                        @test abs(σ - wsσ) / wsσ <= (K == -1 ? 1e-6 : 1.)

                        if K == -1
                            stopcrit = CutLimit(0)
                        else
                            stopcrit = Pereira()
                        end
                        stopcrit |= IterLimit(50)
                        sol = SDDP(root, num_stages, K = K, stopcrit = stopcrit, verbose = 0)
                        v11value = sol.sol[1:4]
                        @test sol.status == :Optimal
                        @test abs(sol.objval - objval) / objval < (K == -1 ? 1e-6 : .03)
                        @test norm(v11value - solval) / norm(solval) < (K == -1 ? 1e-6 : .3)

                        μ, σ = waitandsee(root, num_stages, solver, K)
                        @test abs(μ - ws) / ws < (K == -1 ? 1e-6 : .03)
                        @test abs(σ - wsσ) / wsσ <= (K == -1 ? 1e-6 : 1.)

                        SDDPclear(m)
                    end
                end
            end
        end
    end
end

@testset "Problem 5.2" begin
    include("prob5.2_2stages.jl")
    include("prob5.2_3stages.jl")
    include("prob5.2_3stages_serial.jl")
end
