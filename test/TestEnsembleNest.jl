module TestEnsembleNest

using Base.Test: @test_approx_eq_eps, @testset

using Ensemble
using .EnsembleNest

function test5DGaussian()
    nd = 5

    function logp(x)
        if any(x .> 1.0) || any(x .< 0.0)
            -Inf
        else
            0.0
        end
    end

    mu = 0.5*ones(nd) + 0.1*rand((nd,))
    sigma = 0.01*ones(nd)

    function logl(x)
        -0.5*nd*log(2.0*pi) - sum(log(sigma)) - 0.5*sum((x-mu).*(x-mu)./(sigma.*sigma))
    end

    nmcmc = 100
    nl = 1024
    xs = rand((nd, nl))
    ns = NestState(logl, logp, xs, nmcmc)

    run!(ns, 0.1)

    lZ, dlZ = logZ(ns)

    @testset "5D Gaussian tests" begin
        @test_approx_eq_eps lZ 0.0 1.0

        post, lnprobs = postsample(ns)
        npost = size(post, 2)

        for i in 1:nd
            smu = mean(post[i,:])
            @test_approx_eq_eps smu mu[i] 0.1*sigma[i]
        end
    end
end

function testall()
    @testset "EnsembleNest tests" begin
        test5DGaussian()
    end
end

end
