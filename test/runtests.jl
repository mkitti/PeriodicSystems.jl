module Runtests

using Test, PeriodicSystems

@testset "Test PeriodicSystems" begin
# test constructors, basic tools
include("test_psutils.jl")
include("test_conversions.jl")
include("test_pslifting.jl")
include("test_psanalysis.jl")
include("test_pslyap.jl")
include("test_psclyap.jl")
end

end
