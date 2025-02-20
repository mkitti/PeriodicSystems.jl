module Test_pslifting

using PeriodicSystems
using DescriptorSystems
using Symbolics
using Test
using LinearAlgebra
using ApproxFun

println("Test_liftings")

# # selected sequence to illustrate failure of BlockMatrices.jl v0.16.16
# using LinearAlgebra
# using ApproxFun
# Af = Fun(t -> [0 1; -10*cos(t) -24-10*sin(t)],Fourier(0..2π));
# D = Derivative(domain(Af));
# ND = [D 0I; 0I D];
# Aop = Af - ND;
# NA = 322
# RW = Aop[1:NA,1:NA]

@testset "test_liftings" begin

# using Floquet based approach
At = PeriodicFunctionMatrix(t -> [0 1; -10*cos(t) -24-10*sin(t)],2pi);
@time ev = psceig(At; reltol = 1.e-10)
@time ev = psceig(At,500; reltol = 1.e-10)
@test sort(ev) ≈ sort([0;-24])

# using Fourier series
Afun = FourierFunctionMatrix(Fun(t -> [0 1; -10*cos(t) -24-10*sin(t)],Fourier(0..2π)))
ev1 = psceigfr(Afun,50)
@test isapprox(sort(real(ev)),sort(real(ev1)),rtol=1.e-6) && norm(imag(ev1)) < 1.e-10

ev3 = psceigfr(Afun,60)
@test isapprox(sort(real(ev)),sort(real(ev3)),rtol=1.e-6) && norm(imag(ev3)) < 1.e-10

# using Toeplitz operator truncation
Ahr = convert(HarmonicArray,PeriodicFunctionMatrix(t -> [0 1; -10*cos(t) -24-10*sin(t)],2pi));
ev2 = psceighr(Ahr,50)
@test sort(ev) ≈ sort(real(ev2[sortperm(imag(ev2),by=abs)][1:2]))


# example Zhou, Hagiwara SCL 2002 period pi/2 and pi
# using Floquet based approach
At = PeriodicFunctionMatrix(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],pi/2);
At2 = PeriodicFunctionMatrix(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],pi);
@time ev = psceig(At; reltol = 1.e-10)
@time ev = psceig(At,500; reltol = 1.e-10) # complex characteristic exponents
@test sort(real(ev)) ≈ sort([-1;-2]) && sort(imag(ev)) ≈ [2;2]
@time ev2 = psceig(At2; reltol = 1.e-10)
@time ev2 = psceig(At2,500; reltol = 1.e-10) # real characteristic exponents
@test sort(ev2) ≈ sort([-1;-2])

# using Fourier series
Afun = FourierFunctionMatrix(Fun(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],Fourier(0..π/2)))
ev3 = psceigfr(Afun)
@test sort(real(ev3)) ≈ sort([-1;-2]) && sort(imag(ev3)) ≈ [2;2] 


# using Toeplitz operator truncation period pi/2
Ahr = convert(HarmonicArray,PeriodicFunctionMatrix(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],pi/2));
Asym = convert(PeriodicSymbolicMatrix,Ahr); Asym.F
ev3 = psceighr(Ahr,5)
@test sort(real(ev3)) ≈ sort([-1;-2]) && sort(imag(ev3)) ≈ [2;2] 

# simple period
ev4 = psceighr(Ahr,50)
@test sort(real(ev4)) ≈ sort([-1;-2]) && sort(imag(ev4)) ≈ [2;2] 

# double period
ev5 = psceighr(Ahr,50; P = 2)
@test sort(real(ev5)) ≈ sort([-1;-2]) && norm(imag(ev5)) < 1.e-10 


# using Fourier series truncation period pi
ev4 = psceigfr(Afun,P = 2)
@test sort(real(ev4)) ≈ sort([-1;-2]) && norm(imag(ev4)) < 1.e-10 


# using Toeplitz operator truncation period pi
Ahr2 = convert(HarmonicArray,PeriodicFunctionMatrix(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],pi));
Asym2 = convert(PeriodicSymbolicMatrix,Ahr2); Asym2.F
ev3 = psceighr(Ahr2,5)
@test sort(real(ev3)) ≈ sort([-1;-2]) && norm(imag(ev3)) < 1.e-10 

ev4 = psceighr(Ahr,50; P = 2)
@test sort(real(ev4)) ≈ sort([-1;-2]) && norm(imag(ev4)) < 1.e-10 

# constant matrix case
Q = convert(HarmonicArray,PeriodicFunctionMatrix([-1 0; 0 -2],pi/2));
N = 5; ev1 = psceighr(Q,N)
@test sort(real(ev1)) ≈ sort([-1;-2]) && norm(imag(ev1)) < 1.e-10

QF = convert(FourierFunctionMatrix,Q)
N = 5; ev2 = psceigfr(QF,N)
@test sort(real(ev2)) ≈ sort([-1;-2]) && norm(imag(ev2)) < 1.e-10



# Floquet approach
A = PeriodicFunctionMatrix(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],pi/2);
@time ev = psceig(A; reltol = 1.e-10)
@time ev = psceig(A,50; reltol = 1.e-10)

# Fourier approach
Afun = FourierFunctionMatrix(Fun(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],Fourier(0..π)))
ev1 = psceigfr(Afun)
@test sort(real(ev)) ≈ sort(real(ev1)) && norm(imag(ev1)) < 1.e-10

ev2 = psceigfr(Afun,5)
@test sort(real(ev)) ≈ sort(real(ev2)) && norm(imag(ev2)) < 1.e-10

ev3 = psceigfr(Afun,20)
@test sort(real(ev)) ≈ sort(real(ev3)) && norm(imag(ev3)) < 1.e-10


# # lossy Mathieu differential equation
# k = -1.; ξ = 0.05; β =0.2; ωh = 2; # unstable feedback
# k = -.5; ξ = 0.05; β =0.2; ωh = 2; # stable feedback
# Ahr = convert(HarmonicArray,PeriodicFunctionMatrix(t -> [0 1; k*(1-2β*cos(ωh*t)) -2*ξ],2pi));
# Asym = convert(PeriodicSymbolicMatrix,Ahr); Asym.F
# N = 5; ev = eigvals(hr2bt(Ahr,N)-phasemat(Ahr,N))
# ev[sortperm(imag(ev),by=abs)][1:2]

# Bitanti-Colaneri's book p.26 
a = PeriodicFunctionMatrix(t -> [-1+sin(t) 0; 1-cos(t) -3],2*pi);
b = PeriodicFunctionMatrix(t ->  [-1-cos(t);2-sin(t)], 2*pi); 
c = [0 1]; d = [0];

# using Harmonic Array based lifting
psyschr = ps(HarmonicArray,a,b,c,d)
ev = psceighr(psyschr.A,20)

syshr = ps2fls(psyschr,20)
p = gpole(syshr,atol=1.e-7);  p = p[sortperm(imag(p),by=abs)][1:2];
@test sort(real(p)) ≈ sort(real(ev))  && norm(imag(p)) < 1.e-10

z = gzero(syshr,atol=1.e-7); z = z[isfinite.(z)]; # Question: How to handle infinite zeros?
ζ = z[sortperm(imag(z),by=abs)][1]

Z = convert(HarmonicArray,PeriodicFunctionMatrix(t -> [(-2+3*sin(t))/(2-sin(t))],2*pi))
ρ = real(Z.values[:,:,1])[1,1]
@test real(ζ) ≈ ρ

# using Fourier Function Matrix based lifting
psysc = ps(FourierFunctionMatrix,a,b,c,d);
ev1 = psceigfr(psysc.A,30)

sys = ps2frls(psysc,20);
p = gpole(sys,atol=1.e-7);  p = p[sortperm(imag(p),by=abs)][1:4]; 
@test minimum(abs.(p.-ev1[1])) < 1.e-10 && minimum(abs.(p.-ev1[2])) < 1.e-10 

z = gzero(sys,atol=1.e-7); z = z[isfinite.(z)]; # Question: How to handle infinite zeros?
z = z[sortperm(imag(z),by=abs)][1:4];
@test minimum(abs.(z.-ρ)) < 1.e-10  


# Zhou-Hagiwara Automatica 2002 
β = 0.5
a1 = PeriodicFunctionMatrix(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],pi);
#γ(t) = mod(t,pi) < pi/2 ? sin(2*t) : 0 
γ = chop(Fun(t -> mod(t,pi) < pi/2 ? sin(2*t) : 0, Fourier(0..pi)),1.e-7);
b1 = PeriodicFunctionMatrix(t ->  [0; 1-2*β*(mod(t,float(pi)) < pi/2 ? sin(2*t) : 0 )], pi); 
b1 = PeriodicFunctionMatrix(t ->  [0; 1-2*β*γ(t)], pi); 
c = [1 1]; d = [0];

# using Harmonic Array based lifting
psyschr = ps(HarmonicArray,a1,b1,c,d);
ev = psceighr(psyschr.A)

syshr = ps2fls(psyschr,60);
p = gpole(syshr,atol=1.e-7);  p = p[sortperm(imag(p),by=abs)][1:2]
@test sort(real(p)) ≈ sort(real(ev))  && norm(imag(p)) < 1.e-10

z = gzero(syshr,atol=1.e-7); z = z[isfinite.(z)]; #  Question: How to handle infinite zeros?
ζ = z[sortperm(imag(z),by=abs)][1]
@test ζ ≈ -3.5


# using Fourier Function Matrix based lifting
psysc = ps(FourierFunctionMatrix,a1,b1,c,d);
ev = psceigfr(psysc.A)

sys = ps2frls(psysc,60);
p = gpole(sys,atol=1.e-7);  p = p[sortperm(imag(p),by=abs)][1:2]
@test sort(real(p)) ≈ sort(real(ev))  && norm(imag(p)) < 1.e-10

z = gzero(sys,atol=1.e-7); z = z[isfinite.(z)]; #  Question: How to handle infinite zeros?
z = z[sortperm(imag(z),by=abs)][1]
@test z[1] ≈ -3.5

# # Ziegler's column

# β = 2pi; η =0.5; λ = 0.5; 
# M = [1 3/8; 3/2 1];
# K0 = [3/8 3/16; -3/4 3/4]; K1 = λ*[-1 η; 0 4η-4];
# A = PeriodicFunctionMatrix(τ -> [eye(2) zeros(2,2); zeros(2,2) -M\(K0+cos(β*τ).*K1)],2*pi/β)

# # Mathieu equation: determination of minimum eigenvalue
# q = 2; a = 2; a = -1.513956885056448; a = -1
# Ahr = convert(HarmonicArray,PeriodicFunctionMatrix(t -> [0 1; a-2*q*cos(2*t) 0],pi));
# Asym = convert(PeriodicSymbolicMatrix,Ahr); Asym.F
# ev = psceig(Ahr)
# N = 20; ev = eigvals(hr2bt(Ahr,N)-phasemat(Ahr,N))
# ev[sortperm(imag(ev),by=abs)][1:2]

# N = 5; ev1 = eigvals(hr2bt1(Ahr,N,2)-phasemat1(Ahr,N,2))
# ev1[sortperm(imag(ev1),by=abs)][1:2]

# discrete liftings
Ad = PeriodicMatrix([[1. 0; 0 0], [1 1;1 1], [0 1; 1 0]], 6, nperiod = 2);
Bd = PeriodicMatrix( [[ 1; 0 ], [ 1; 1]] ,2);
Cd = PeriodicMatrix( [[ 1 1 ], [ 1 0]] ,2);
Dd = PeriodicMatrix( [[ 1 ]], 1);
psys = PeriodicStateSpace(Ad,Bd,Cd,Dd); 
sys = ps2ls(psys)
sys1 = ps2ls(psys, 7, ss = true)
@test iszero(sys-sys1)

Ad = PeriodicMatrix([[1. 0], [1;1]],2);
Bd = PeriodicMatrix( [[ 1 ], [ 1; 1]] ,2);
Cd = PeriodicMatrix( [[ 1 1 ], [ 1 ]] ,2);
Dd = PeriodicMatrix( [[ 1 ]], 1); 
psys = PeriodicStateSpace(Ad,Bd,Cd,Dd);
sys = ps2ls(psys)
sys1 = ps2ls(psys, 7, ss = true)
@test iszero(sys-sys1)

sys = ps2ls(psys, 2)
sys1 = ps2ls(psys, 8, ss = true)
@test iszero(sys-sys1)

sys = ps2ls(psys, cyclic = true)
sys1 = ps2ls(psys, 3, cyclic = true)
@test iszero(sys-sys1)


Ad = PeriodicArray(rand(Float32,2,2,10),10);
Bd = PeriodicArray(rand(2,1,2),2);
Cd = PeriodicArray(rand(1,2,3),3);
Dd = PeriodicArray(rand(1,1,1), 1);
psys = PeriodicStateSpace(Ad,Bd,Cd,Dd); 
sys = ps2ls(psys)
sys1 = ps2ls(psys, ss = true)
@test iszero(sys-sys1)

sys = ps2ls(psys, 2)
sys1 = ps2ls(psys, 2, ss = true)
@test iszero(sys-sys1)

sys = ps2ls(psys, cyclic = true)
sys1 = ps2ls(psys, 31, cyclic = true)
@test iszero(sys-sys1)

end # test

end # module