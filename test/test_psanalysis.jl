module Test_psanalysis

using PeriodicSystems
using DescriptorSystems
using Symbolics
using Test
using LinearAlgebra
using ApproxFun

println("Test_analysis")


@testset "test_analysis" begin

# using Floquet based approach
At = PeriodicFunctionMatrix(t -> [0 1; -10*cos(t) -24-10*sin(t)],2pi);
psys = ps(At,HarmonicArray(rand(2,1),2*pi),rand(1,2))
@time ev = pspole(psys,500)
@test sort(ev) ≈ sort([0;-24])

# using Fourier series
Afun = FourierFunctionMatrix(Fun(t -> [0 1; -10*cos(t) -24-10*sin(t)],Fourier(0..2π)))
psys = ps(Afun,FourierFunctionMatrix(rand(2,1),2*pi),rand(1,2))
@time ev1 = pspole(psys,200)
@test isapprox(sort(real(ev)),sort(real(ev1)),rtol=1.e-6) && norm(imag(ev1)) < 1.e-10


# using Toeplitz operator truncation
Ahr = convert(HarmonicArray,PeriodicFunctionMatrix(t -> [0 1; -10*cos(t) -24-10*sin(t)],2pi));
psys = ps(Ahr,rand(2,1),rand(1,2))
@time ev2 = pspole(psys,100)
@test norm(sort(ev) - sort(real(ev2[sortperm(imag(ev2),by=abs)][1:2]))) < 1.e-6


# example Zhou, Hagiwara SCL 2002 period pi/2 and pi
# using Floquet based approach
At = PeriodicFunctionMatrix(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],pi/2);
At2 = PeriodicFunctionMatrix(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],pi);
psys = ps(At,rand(2,1),rand(1,2))
psys2 = ps(At2,rand(2,1),rand(1,2))
@time ev = pspole(psys; reltol = 1.e-10)
@test sort(real(ev)) ≈ sort([-1;-2]) && sort(imag(ev)) ≈ [2;2]
@time ev = pspole(psys, 500; reltol = 1.e-10)
@test sort(real(ev)) ≈ sort([-1;-2]) && sort(imag(ev)) ≈ [2;2]
@time ev2 = pspole(psys2; reltol = 1.e-10)
@test sort(ev2) ≈ sort([-1;-2])
@time ev2 = pspole(psys2,500; reltol = 1.e-10)
@test sort(ev2) ≈ sort([-1;-2])


# using Toeplitz operator truncation period pi/2
Ahr = convert(HarmonicArray,PeriodicFunctionMatrix(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],pi/2));
psys = ps(Ahr,rand(2,0),rand(0,2))
ev3 = pspole(psys,5)
@test sort(real(ev3)) ≈ sort([-1;-2]) && sort(imag(ev3)) ≈ [2;2] 

# simple period
ev4 = pspole(psys,50)
@test sort(real(ev4)) ≈ sort([-1;-2]) && sort(imag(ev4)) ≈ [2;2] 

# double period
ev5 = pspole(psys,50; P = 2)
@test sort(real(ev5)) ≈ sort([-1;-2]) && norm(imag(ev5)) < 1.e-10 


# using Fourier series
Afun = FourierFunctionMatrix(Fun(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],Fourier(0..π/2)))
psys = ps(Afun,rand(2,1),rand(1,2))
ev3 = pspole(psys)
@test sort(real(ev3)) ≈ sort([-1;-2]) && sort(imag(ev3)) ≈ [2;2] 

# using Fourier series truncation period pi
ev4 = pspole(psys, P = 2)
@test sort(real(ev4)) ≈ sort([-1;-2]) && norm(imag(ev4)) < 1.e-10 


# using Toeplitz operator truncation period pi
Ahr2 = convert(HarmonicArray,PeriodicFunctionMatrix(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],pi));
psys2 = ps(Ahr2,rand(2,0),rand(0,2))
ev3 = pspole(psys2,5)
@test sort(real(ev3)) ≈ sort([-1;-2]) && norm(imag(ev3)) < 1.e-10 

ev4 = pspole(psys2,50; P = 2)
@test sort(real(ev4)) ≈ sort([-1;-2]) && norm(imag(ev4)) < 1.e-10 

# constant system case
Q = convert(HarmonicArray,PeriodicFunctionMatrix([-1 0; 0 -2],pi/2));
psys = ps(Q,rand(2,0),rand(0,2))
ev1 = pspole(psys,5)
@test sort(real(ev1)) ≈ sort([-1;-2]) && norm(imag(ev1)) < 1.e-10

QF = convert(FourierFunctionMatrix,Q)
#psys = ps(QF,rand(2,0),rand(0,2)) # null dimensions not supported in ApproxFun
psys = ps(QF,rand(2,1),rand(1,2))
ev2 = pspole(psys,5)
@test sort(real(ev2)) ≈ sort([-1;-2]) && norm(imag(ev2)) < 1.e-10



# Floquet approach
A = PeriodicFunctionMatrix(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],pi);
psys = ps(A,rand(2,1),rand(1,2))
@time ev = pspole(psys; reltol = 1.e-10)
@time ev = pspole(psys,50; reltol = 1.e-10)

# Fourier approach
Afun = FourierFunctionMatrix(Fun(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],Fourier(0..π)))
psys1 = ps(Afun,rand(2,1),rand(1,2))
ev1 = pspole(psys1)
@test sort(real(ev)) ≈ sort(real(ev1)) && norm(imag(ev1)) < 1.e-10

ev2 = pspole(psys1,5)
@test sort(real(ev)) ≈ sort(real(ev2)) && norm(imag(ev2)) < 1.e-10

ev3 = pspole(psys1,20)
@test sort(real(ev)) ≈ sort(real(ev3)) && norm(imag(ev3)) < 1.e-10


# # lossy Mathieu differential equation
# k = -1.; ξ = 0.05; β =0.2; ωh = 2; # unstable feedback
# k = -.5; ξ = 0.05; β =0.2; ωh = 2; # stable feedback
# Ahr = convert(HarmonicArray,PeriodicFunctionMatrix(t -> [0 1; k*(1-2β*cos(ωh*t)) -2*ξ],2pi));
# Asym = convert(PeriodicSymbolicMatrix,Ahr); Asym.F
# N = 5; ev = eigvals(hr2bt(Ahr,N)-phasemat(Ahr,N))
# ev[sortperm(imag(ev),by=abs)][1:2]

# zeros example: infinite zeros present but not for the averaged system
a = PeriodicFunctionMatrix(t -> [sin(t)],2*pi);
b = PeriodicFunctionMatrix(t ->  [cos(t)], 2*pi); 
c = PeriodicFunctionMatrix(t ->  [cos(t)+sin(t)], 2*pi); 
d = [0];
psys = ps(HarmonicArray,a,b,c,d);
z = pszero(psys,atol=1.e-7)
@test z[1] == Inf
psys1 = ps(FourierFunctionMatrix,a,b,c,d)
z1 = pszero(psys1,30,atol=1.e-7)
@test any(isinf.(z1)) 

psys2 = ps(a,b,c,d); 
z2 = pszero(psys2,30,atol=1.e-7)
@test any(isinf.(z2)) 


# Bitanti-Colaneri's book p.26 
a = PeriodicFunctionMatrix(t -> [-1+sin(t) 0; 1-cos(t) -3],2*pi);
b = PeriodicFunctionMatrix(t ->  [-1-cos(t);2-sin(t)], 2*pi); 
c = [0 1]; d = [0];

psys = ps(a,b,c,d)
evref = pspole(psys,100)
@test sort(real(evref)) ≈ sort([-1,-3])  && norm(imag(evref)) < 1.e-10

# using Harmonic Array based computation
psyschr = ps(HarmonicArray,a,b,c,d)
ev = pspole(psyschr,20)
@test sort(real(evref)) ≈ sort(real(ev))  && norm(imag(ev)) < 1.e-10

Z = convert(HarmonicArray,PeriodicFunctionMatrix(t -> [(-2+3*sin(t))/(2-sin(t))],2*pi))
ρ = real(Z.values[:,:,1])[1,1]

z = pszero(psyschr,atol=1.e-7)
@test z ≈ [ρ;Inf]


# using Fourier Function Matrix based computation
psysc = ps(FourierFunctionMatrix,a,b,c,d);
ev1 = pspole(psysc,30)
@test sort(real(evref)) ≈ sort(real(ev1))  && norm(imag(ev1)) < 1.e-10

z1 = pszero(psysc,atol=1.e-7)
@test minimum(abs.(z1.-ρ)) < 1.e-10  && any(isinf.(z1))

psys2 = ps(a,b,c,d); 
z2 = pszero(psys2,30,atol=1.e-7)
@test z2 ≈ [ρ;Inf]


# Zhou-Hagiwara Automatica 2002 
β = 0.5
a1 = PeriodicFunctionMatrix(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],pi);
#γ(t) = mod(t,pi) < pi/2 ? sin(2*t) : 0 
γ = chop(Fun(t -> mod(t,pi) < pi/2 ? sin(2*t) : 0, Fourier(0..pi)),1.e-7);
#b1 = PeriodicFunctionMatrix(t ->  [0; 1-2*β*(mod(t,float(pi)) < pi/2 ? sin(2*t) : 0 )], pi); 
b1 = PeriodicFunctionMatrix(t ->  [0; 1-2*β*γ(t)], pi); 
c = [1 1]; d = [0];

# using Harmonic Array based lifting
psyschr = ps(HarmonicArray,a1,b1,c,d);
ev = pspole(psyschr)
@test sort([-1,-2]) ≈ sort(real(ev))  && norm(imag(ev)) < 1.e-10

z = pszero(psyschr,atol=1.e-7)
@test z ≈ [-3.5;Inf]


# using Fourier Function Matrix based lifting
psysc = ps(FourierFunctionMatrix,a1,b1,c,d);
ev = pspole(psysc)
@test sort([-1,-2]) ≈ sort(real(ev))  && norm(imag(ev)) < 1.e-10

z = pszero(psysc,30,atol=1.e-7)
@test z ≈ [-3.5;Inf]

psys2 = ps(a1,b1,c,d); 
z2 = pszero(psys2,30,atol=1.e-7)
@test z2 ≈  [-3.5;Inf]


# Zhou IEEE TAC 2009 
β = 0.5
a1 = PeriodicFunctionMatrix(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],pi);
b1 = PeriodicFunctionMatrix(t ->  [0; 1-2*β*cos(2*t)], pi); 
c = [0 1]; d = [0];

# using Harmonic Array based lifting
psyschr = ps(HarmonicArray,a1,b1,c,d);
ev = pspole(psyschr)
@test sort([-1,-2]) ≈ sort(real(ev))  && norm(imag(ev)) < 1.e-10

z = pszero(psyschr,atol=1.e-7)
@test z ≈ [-1.5;Inf]

psysc = ps(FourierFunctionMatrix,a1,b1,c,d);
ev = pspole(psysc)
@test sort([-1,-2]) ≈ sort(real(ev))  && norm(imag(ev)) < 1.e-10

z = pszero(psysc,30,atol=1.e-7)
@test z ≈ [-1.5;Inf]

psys2 = ps(a1,b1,c,d); 
z2 = pszero(psys2,30,atol=1.e-7)
@test z2 ≈  [-1.5;Inf]

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

# discrete systems
Ad = PeriodicMatrix([[8. 0; 0 0], [1 1;1 1], [0 1; 1 0]], 6, nperiod = 2);
Bd = PeriodicMatrix( [[ 1; 0 ], [ 1; 1]] ,2);
Cd = PeriodicMatrix( [[ 1 1 ], [ 1 0]] ,2);
Dd = PeriodicMatrix( [[ 1 ]], 1);
psys = PeriodicStateSpace(Ad,Bd,Cd,Dd); 
ev = pspole(psys)
ev1 = pspole(psys,7)
@test sort(ev) ≈ sort([2,0]) ≈ sort(ev1) ≈ sort(gpole(ps2ls(psys))).^(1/6)

z = pszero(psys)
z1 = gzero(ps2ls(psys))
@test all(abs.(z[isfinite.(z)].^6-z1[isfinite.(z1)]) .< 1.e-8) && length(z[isinf.(z)]) == length(z1[isinf.(z1)])


Ad = PeriodicMatrix([[4. 0], [1;1], [2 0;0 1]],3);
Bd = PeriodicMatrix( [[ 1 ], [ 1; 1], [1;2]] ,3);
Cd = PeriodicMatrix( [[ 1 1 ], [ 1 ], [1 0]] ,3);
Dd = PeriodicMatrix( [[ 1 ]], 1); 
psys = PeriodicStateSpace(Ad,Bd,Cd,Dd);
ev = pspole(psys)
@test sort(ev) ≈ sort([2,0])
ev1 = pspole(psys,2)
@test ev1 ≈ [2] ≈ gpole(ps2ls(psys,2)).^(1/3)
@test !isstable(psys)


z = pszero(psys)
z1 = gzero(ps2ls(psys))
@test all(abs.(z[isfinite.(z)].^3-z1[isfinite.(z1)]) .< 1.e-8) && length(z[isinf.(z)]) == length(z1[isinf.(z1)])

Ad = PeriodicMatrix([[1. 2], [7;8]],2);
Bd = PeriodicMatrix( [[ 3 ], [ 9; 10]] ,2);
Cd = PeriodicMatrix( [[ 4 5 ], [ 11 ]] ,2);
Dd = PeriodicMatrix( [[ 0 ]], 1); 
psys = PeriodicStateSpace(Ad,Bd,Cd,Dd);

z = pszero(psys)
z1 = gzero(ps2ls(psys))
@test all(abs.(z[isfinite.(z)].^2-z1[isfinite.(z1)]) .< 1.e-8) && length(z[isinf.(z)]) == length(z1[isinf.(z1)])

z = pszero(psys,2)
z1 = gzero(ps2ls(psys,2))
@test all(abs.(z[isfinite.(z)].^2-z1[isfinite.(z1)]) .< 1.e-8) && length(z[isinf.(z)]) == length(z1[isinf.(z1)])

psysa = convert(PeriodicStateSpace{PeriodicArray},psys)
za = pszero(psysa)
za1 = gzero(ps2ls(psysa))
@test all(abs.(za[isfinite.(za)].^2-za1[isfinite.(za1)]) .< 1.e-8) && length(za[isinf.(za)]) == length(za1[isinf.(za1)])

za = pszero(psysa,2)
za1 = gzero(ps2ls(psysa,2))
@test all(abs.(za[isfinite.(za)].^2-za1[isfinite.(za1)]) .< 1.e-8) && length(za[isinf.(za)]) == length(za1[isinf.(za1)])


# periodic array representation
Ad = PeriodicArray(rand(Float32,2,2,10),10);
Bd = PeriodicArray(rand(2,1,2),2);
Cd = PeriodicArray(rand(1,2,3),3);
Dd = PeriodicArray(zeros(1,1,1), 1);
psys = PeriodicStateSpace(Ad,Bd,Cd,Dd); 
ev = pspole(psys)
ev1 = pspole(psys; fast = true)
@test norm(sort(real(ev)) - sort(real(ev1))) < 1.e-7  && norm(sort(imag(ev))-sort(imag(ev1))) < 1.e-7

z = pszero(psys,atol=1.e-7)
z1 = gzero(ps2ls(psys),atol=1.e-7)
@test all(abs.(z[isfinite.(z)].^30-z1[isfinite.(z1)]) .< 1.e-8) && length(z[isinf.(z)]) == length(z1[isinf.(z1)])


# Pitelkau's example
ω = 0.00103448
period = 2*pi/ω
a = [  0            0     5.318064566757217e-02                         0
       0            0                         0      5.318064566757217e-02
       -1.352134256362805e-03   0             0    -7.099273035392090e-02
       0    -7.557182037479544e-04     3.781555288420663e-02             0 
];
b = t->[0; 0; 0.1389735*10^-6*sin(ω*t); -0.3701336*10^-7*cos(ω*t)];
c = [1 0 0 0;0 1 0 0];
d = zeros(2,1);
psysc = ps(a,PeriodicFunctionMatrix(b,period),c,d);
@time evc = pspole(psysc)
@test all(abs.(real(evc)) .< 1.e-10)
@test !isstable(psysc)

zc = pszero(psysc)
@test all(isinf.(zc))


K = 120;
@time psys = psc2d(psysc,period/K,reltol = 1.e-10);
@time evd = pspole(psys)
@test all(abs.(evd) .≈ 1)
@test !isstable(psys)

zd = pszero(psys,atol=1.e-7)
@test all(isinf.(zd))


# discrete-time H2 norm

# PeriodicArray
n = 5; nu = 2; ny = 3; pa = 3; pb = 6; pc = 2; pd = 1;   
Ad = 0.1*PeriodicArray(rand(Float64,n,n,pa),pa);
Bd = PeriodicArray(rand(Float64,n,nu,pb),pb);
Cd = PeriodicArray(rand(Float64,ny,n,pc),pc);
Dd = PeriodicArray(rand(Float64,ny,nu,pd),pd);
psys = ps(Ad,Bd,Cd,Dd)

@time n1 = psh2norm(psys)
@time n2 = psh2norm(psys, fast = true)
@time n1a = psh2norm(psys, adj = true) 
@time n2a = psh2norm(psys, adj = true, fast = true)
@test n1 ≈ n2 ≈ n1a ≈ n2a

psys1 = convert(PeriodicStateSpace{PeriodicMatrix},psys);
@time n1 = psh2norm(psys1)
@time n2 = psh2norm(psys1,fast = true)
@time n1a = psh2norm(psys1, adj = true) 
@time n2a = psh2norm(psys1, adj = true, fast = true)
@test n1 ≈ n2 ≈ n1a ≈ n2a



# Example Bitanti & Colaneri
A1 = [0 1; -0.1 0]; B1 = [0;1;;];
C1 = [-0.25 -0.1 ]; C2 = [-1.2 0.3 ];
D1 = [0;;]
Ad = PeriodicArray(reshape(A1,2,2,1),1)
Bd = PeriodicArray(reshape(B1,2,1,1),1)
Cd = PeriodicArray(reshape([C1 C2],1,2,2),2)
Dd = PeriodicArray(reshape(D1,1,1,1),1)
psys = ps(Ad,Bd,Cd,Dd)

@time n1 = psh2norm(psys)
@time n2 = psh2norm(psys,fast = true)
@time n1a = psh2norm(psys, adj = true)
@time n2a = psh2norm(psys, adj = true, fast = true)
@test n1 ≈ n2 ≈ n1a ≈ n2a

psys1 = convert(PeriodicStateSpace{PeriodicMatrix},psys);
@time n1 = psh2norm(psys1)
@time n2 = psh2norm(psys1,fast = true)
@time n1a = psh2norm(psys1, adj = true) 
@time n2a = psh2norm(psys1, adj = true, fast = true)
@test n1 ≈ n2 ≈ n1a ≈ n2a



# PeriodicMatrix
p = 5; na = [10, 8, 6, 4, 2]; ma = circshift(na,-1); nu = 2; ny = 3; 
period = 10;
Ad = 0.001*PeriodicMatrix([rand(ma[i],na[i]) for i in 1:p],period);
Bd = PeriodicMatrix([rand(ma[i],nu) for i in 1:p],period);
Cd = PeriodicMatrix([rand(ny,na[i]) for i in 1:p],period);
Dd = PeriodicMatrix(rand(ny,nu),period; nperiod = rationalize(Ad.period/Ad.Ts).num);
psys = ps(Ad,Bd,Cd,Dd)

@time n1 = psh2norm(psys)
@time n2 = psh2norm(psys,fast = true)
@time n1a = psh2norm(psys, adj = true)
@time n2a = psh2norm(psys, adj = true, fast = true)
@test n1 ≈ n2 ≈ n1a ≈ n2a

# continuous-time H2 norm
A = [-1 -0.5; -3 -5]; B = [3;1;;]; C = [1. 2.]; D = [0.;;];
sys = dss(A,B,C,D)
nh2 = gh2norm(sys)

psysc = ps(sys,2*pi)

nh2pc = psh2norm(psysc)
@test nh2 ≈ nh2pc

period = π; ω = 2. ;

P1 = PeriodicFunctionMatrix(t->[cos(ω*t) sin(ω*t); -sin(ω*t) cos(ω*t)],period); 
PM = PeriodicFunctionMatrix
for PM in (PeriodicFunctionMatrix, HarmonicArray, FourierFunctionMatrix, PeriodicSymbolicMatrix, PeriodicTimeSeriesMatrix)
#for PM in (HarmonicArray, )
        println("type = $PM")
    K = PM == PeriodicTimeSeriesMatrix ? 128 : 200

    P = convert(PM,P1);

    Ap = derivative(P)*inv(P)+P*A*inv(P);
    Bp = P*B
    Cp = C*inv(P); Dp = D; 
    psys = ps(Ap,Bp,Cp,Dp);
    solver = "non-stiff"
    for solver in ("non-stiff", "stiff", "symplectic", "noidea")
        println("solver = $solver")
        @time nh2p = psh2norm(psys,K; solver, reltol=1.e-10, abstol = 1.e-10)
        @time nh2pq = psh2norm(psys,K; solver, reltol=1.e-10, abstol = 1.e-10, quad = true)
        @time nh2pa = psh2norm(psys,K; adj = true, solver, reltol=1.e-10, abstol = 1.e-10)
        @time nh2paq = psh2norm(psys,K; adj = true, solver, reltol=1.e-10, abstol = 1.e-10, quad = true)
        @time nt1=sqrt.(tr(pmaverage(psys.C*pfclyap(psys.A, psys.B*psys.B'; K,solver,reltol=1.e-10,abstol=1.e-10)*psys.C')))[1]
        @time nt1a=sqrt.(pmaverage(tr(psys.C*pfclyap(psys.A, psys.B*psys.B'; K,solver,reltol=1.e-10,abstol=1.e-10)*psys.C')))[1]
        @time nt2=sqrt.(tr(pmaverage(psys.B'*prclyap(psys.A, psys.C'*psys.C; K,solver,reltol=1.e-10,abstol=1.e-10)*psys.B)))[1]
        @time nt2a=sqrt.(pmaverage(tr(psys.B'*prclyap(psys.A, psys.C'*psys.C; K,solver,reltol=1.e-10,abstol=1.e-10)*psys.B)))[1]
        @test nh2pc ≈ nh2p ≈ nh2pa ≈ nh2pq ≈ nh2paq     
        @test abs(nh2pc - nt1) < 1.e-5 &&  abs(nh2pc - nt1a) < 1.e-5 &&  abs(nh2pc - nt2) < 1.e-5 &&  abs(nh2pc - nt2a) < 1.e-5 
    end
end


# modified Zhou-Hagiwara Automatica 2002 
β = 0.5
a1 = PeriodicFunctionMatrix(t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2],pi);
γ = t -> mod(t,float(pi)) < pi/2 ? sin(2*t) : 0 
b = t -> [0; 1-2*β*γ(t)]
b1 = PeriodicFunctionMatrix(b, pi); 
b1t = PeriodicFunctionMatrix(t -> [0 1-2*β*γ(t)], pi);
c = [1 1]; d = [0];
psys = ps(PeriodicFunctionMatrix,a1,b1,b1',d);

@time n1 = psh2norm(psys,1; reltol=1.e-10, abstol = 1.e-10);
@time n100 = psh2norm(psys,100, reltol=1.e-10, abstol = 1.e-10);
@time n100q = psh2norm(psys,300, reltol=1.e-10, abstol = 1.e-10, quad=true);
@time n200 = psh2norm(psys,100, reltol=1.e-9, abstol = 1.e-9);
@test n1 ≈ n100 ≈ n200  && abs(n1-n100q) < 0.001  

@time n1a = psh2norm(psys,1; adj = true, reltol=1.e-10, abstol = 1.e-10);
@time n100a = psh2norm(psys,100; adj = true, reltol=1.e-10, abstol = 1.e-10);
@time n200a = psh2norm(psys,200; adj = true, reltol=1.e-14, abstol = 1.e-14);
@time n100aq = psh2norm(psys,300, adj = true, reltol=1.e-10, abstol = 1.e-10, quad=true);
@test n100a ≈ n200a && n1a ≈ n100a && n1a ≈ n1 && abs(n1-n100aq) < 0.001


# compare with Zhou-Hagiwara Automatica 2002 and Peng-Wu IJC 2011 
psys = ps(PeriodicFunctionMatrix,a1,b1,c,d);
for β in 0.1 .* (0:5)
    psys = ps(PeriodicFunctionMatrix,a1,PeriodicFunctionMatrix(t -> [0; 1-2*β*γ(t)], pi),c,d);
    @time n100 = psh2norm(psys,100, reltol=1.e-10, abstol = 1.e-10);
    @time nt100=sqrt.(tr(pmaverage(psys.C*pfclyap(psys.A, psys.B*psys.B';K = 100,reltol=1.e-10,abstol=1.e-10)*psys.C')))[1]
    @test nt100 ≈ n100
    println("β = $β norm = $n100")
end

nt = psh2norm(psys,200, adj = true, reltol=1.e-10, abstol = 1.e-10) 
solver = "non-stiff"
for solver in ("non-stiff", "stiff", "symplectic", "noidea")
    println("solver = $solver")
    @time n1 = psh2norm(psys,100; solver, adj = false, reltol=1.e-10, abstol = 1.e-10)
    @time n2 = psh2norm(psys,100; solver, adj = true, reltol=1.e-10, abstol = 1.e-10)
    @test n1 ≈ nt ≈ n2
end


# Peng-Wu IJC 2011 
a = 1; b = 0.2; 
ω = [1, 2, 3, 4, 5]; ϵ = [0.001, 0.001, 0.01, 0.1]
i = 1; j = 1;
period = 2*pi/ω[j]
a1 = PeriodicFunctionMatrix(t -> [0 1; -1-2*ϵ[i]*cos(ω[j]*t) -2*b],period); 
b1 = [0;1;;]; c = [1 0]; d = [0];
psys = ps(PeriodicFunctionMatrix,a1,b1,c,d);
@time n1 = psh2norm(psys,1; reltol=1.e-10, abstol = 1.e-10);
@time n100 = psh2norm(psys,100);
@time n200 = psh2norm(psys,200);
@test n100 ≈ n200 && n1 ≈ n100

# compare with Peng-Wu IJC 2011 
nrm = zeros(4,5);
for i = 1:4
    for j = 1:5
       period = 2*pi/ω[j]
       psys = ps(PeriodicFunctionMatrix,PeriodicFunctionMatrix(t -> [0 1; -1-2*ϵ[i]*cos(ω[j]*t) -2*b], period), b1, c,d);
       @time nrm[i,j] = psh2norm(psys,100; adj = true);
       #println("ϵ[$i] = $(ϵ[i]) ω[$j] = $(ω[j]) norm = $(nrm[i,j])")
    end
end
@show nrm   


# Pitelkau's example - infinite norm
ω = 0.00103448
period = 2*pi/ω
β = 0.0; 
a = [  0            0     5.318064566757217e-02                         0
       0            0                         0      5.318064566757217e-02
       -1.352134256362805e-03   0             0    -7.099273035392090e-02
       0    -7.557182037479544e-04     3.781555288420663e-02             0
];
b = t->[0; 0; 0.1389735*10^-6*sin(ω*t); -0.3701336*10^-7*cos(ω*t)];
c = [1 0 0 0;0 1 0 0];
d = zeros(2,1);
psys = ps(a-β*I,PeriodicFunctionMatrix(b,period),c,d);

@time n1 = psh2norm(psys,1; reltol=1.e-10, abstol = 1.e-10); 
@time n2 = psh2norm(psys,1; adj = true, reltol=1.e-10, abstol = 1.e-10); 

@test n1 == Inf == n2

β = 0.01
psys = ps(a-β*I,PeriodicFunctionMatrix(b,period),c,d);

@time n1 = psh2norm(psys,100; reltol=1.e-10, abstol = 1.e-10); 
@time n2 = psh2norm(psys,100; adj = true, reltol=1.e-10, abstol = 1.e-10); 
@test abs(n1 - n2) < 1.e-10

@time n1 = psh2norm(psys,100; reltol=1.e-10, abstol = 1.e-10, quad = true); 
@time n2 = psh2norm(psys,100; adj = true, reltol=1.e-10, abstol = 1.e-10, quad = true); 
@test abs(n1 - n2) < 1.e-10

β = 0.01
psys = ps(a-β*I,copy(c'),PeriodicFunctionMatrix(b,period)',copy(d'));
@time n1 = psh2norm(psys,100; reltol=1.e-10, abstol = 1.e-10); 
@time n2 = psh2norm(psys,100; adj = true, reltol=1.e-10, abstol = 1.e-10); 
@test abs(n1 - n2) < 1.e-10


# # test example for symplectic solver failure
# using IRKGaussLegendre
# function muladdcsymt!(y::AbstractVector, x::AbstractVector, A::AbstractMatrix, C::AbstractMatrix)
#     n = size(A, 1)
#     X = reshape(x,n,n)
#     # A*X + X*A' + C
#     y[:] .= (A*X+X*A'+C)[:]
#     return nothing
# end
# A = t -> [-1-sin(2*t)^2 2-0.5*sin(4*t); -2-0.5*sin(4*t) -1-cos(2*t)^2]
# γ = t -> mod(t,float(pi)) < pi/2 ? sin(2*t) : 0 
# B = t -> [0; 1-2*0.5*γ(t)]
# K = 100
# Ts = pi/K
# dt = Ts/100
# ftclyap!(du,u,p,t) = muladdcsymt!(du, u, A(t), B(t)*B(t)')
# i1 = 1; i2 = K  # for all cases
# #i1 = 2; i2 = 2 # an error case on my machine
# for i = i1:i2
#     u0 = zeros(2*2) 
#     tspan = ((i-1)*Ts,i*Ts)
#     prob = ODEProblem(ftclyap!, u0, tspan)
#     #sol = solve(prob, IRKGaussLegendre.IRKGL16(); adaptive = true, reltol=1.e-10, abstol=1.e-10, save_everystep = false) # occasionally fails
#     sol = solve(prob, IRKGaussLegendre.IRKGL16(); dt, adaptive = true, reltol=1.e-10, abstol=1.e-30, save_everystep = false) # this works
#     # @show sol.retcode
#     if sol.retcode == :Failure
#        @show i
#        sol = solve(prob, IRKGaussLegendre.IRKGL16(); adaptive = false, reltol=1.e-10, abstol=1.e-10, save_everystep = false, dt)
#     end
#     #@show sol[end] # solution must be symmetric
# end


end # test

end # module