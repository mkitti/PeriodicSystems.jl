"""
    pclyap(A, C; K = 10, adj = false, solver, reltol, abstol) -> X

Solve the periodic Lyapunov differential equation

    .
    X(t) = A(t)X(t) + X(t)A(t)' + C(t) , if adj = false,

or 

     .
    -X(t) = A(t)'X(t) + X(t)A(t) + C(t) , if adj = true.               

The periodic matrices `A` and `C` must have the same type, the same dimensions and commensurate periods, 
and additionally `C` must be symmetric. The resulting symmetric periodic solution `X` has the period 
set to the least common commensurate period of `A` and `C` and the number of subperiods
is adjusted accordingly. 

The multiple-shooting method of [1] is employed to convert the (continuous-time) periodic differential Lyapunov equation 
into a discrete-time periodic Lyapunov equation satisfied by a multiple point generator of the solution. 
The keyword argument `K` specifies the number of grid points to be used
for the discretization of the continuous-time problem (default: `K = 10`). 
The multiple point generator is computed  by solving the appropriate discrete-time periodic Lyapunov 
equation using the periodic Schur method of [2]. 
The resulting periodic time-series matrix is finally converted to the appropriate periodic representation.

The ODE solver to be employed to convert the continuous-time problem into a discrete-time problem can be specified using the keyword argument `solver`, together with
the required relative accuracy `reltol` (default: `reltol = 1.e-4`) and 
absolute accuracy `abstol` (default: `abstol = 1.e-7`) (see [`tvstm`](@ref)). 
For large values of `K`, parallel computation of the matrices of the discrete-time problem can be alternatively performed 
by starting Julia with several execution threads. 
The number of execution threads is controlled either by using the `-t/--threads` command line argument 
or by using the `JULIA_NUM_THREADS` environment variable.  

_References_

[1] A. Varga. On solving periodic differential matrix equations with applications to periodic system norms computation. 
    Proc. IEEE CDC/ECC, Seville, 2005. 

[2] A. Varga. Periodic Lyapunov equations: some applications and new algorithms. 
    Int. J. Control, vol, 67, pp, 69-87, 1997.
    
"""
function pclyap(A::PeriodicFunctionMatrix, C::PeriodicFunctionMatrix; K::Int = 10, adj = false, solver = "non-stiff", reltol = 1.e-4, abstol = 1.e-7)
   convert(PeriodicFunctionMatrix,convert(HarmonicArray, pgclyap(A, C, K;  adj, solver, reltol, abstol)))
end
pclyap(A::PeriodicFunctionMatrix, C::AbstractMatrix; kwargs...) = pclyap(A, PeriodicFunctionMatrix(C, A.period; nperiod = A.nperiod); kwargs...)
function pclyap(A::PeriodicSymbolicMatrix, C::PeriodicSymbolicMatrix; K::Int = 10, adj = false, solver = "non-stiff", reltol = 1.e-4, abstol = 1.e-7)
   convert(PeriodicSymbolicMatrix, pgclyap(convert(PeriodicFunctionMatrix,A), convert(PeriodicFunctionMatrix,C), K;  adj, solver, reltol, abstol))
end
function pclyap(A::HarmonicArray, C::HarmonicArray; K::Int = 10, adj = false, solver = "non-stiff", reltol = 1.e-4, abstol = 1.e-7)
   convert(HarmonicArray, pgclyap(A,  C, K;  adj, solver, reltol, abstol))
end
function pclyap(A::FourierFunctionMatrix, C::FourierFunctionMatrix; K::Int = 10, adj = false, solver = "non-stiff", reltol = 1.e-4, abstol = 1.e-7)
   convert(FourierFunctionMatrix, pgclyap(A,  C, K;  adj, solver, reltol, abstol))
end
function pclyap(A::PeriodicTimeSeriesMatrix, C::PeriodicTimeSeriesMatrix; K::Int = 10, adj = false, solver = "non-stiff", reltol = 1.e-4, abstol = 1.e-7)
   pgclyap(convert(HarmonicArray,A), convert(HarmonicArray,C), K;  adj, solver, reltol, abstol)
end

for PM in (:PeriodicFunctionMatrix, :PeriodicSymbolicMatrix, :HarmonicArray, :FourierFunctionMatrix, :PeriodicTimeSeriesMatrix)
   @eval begin
      function prclyap(A::$PM, C::$PM; K::Int = 10, solver = "non-stiff", reltol = 1.e-4, abstol = 1.e-7) 
         pclyap(A, C; K, adj = true, solver, reltol, abstol)
      end
      function prclyap(A::$PM, C::AbstractMatrix; kwargs...)
               prclyap(A, $PM(C, A.period; nperiod = A.nperiod); kwargs...)
      end
      function pfclyap(A::$PM, C::$PM; K::Int = 10, solver = "non-stiff", reltol = 1.e-4, abstol = 1.e-7) 
         pclyap(A, C; K, adj = false, solver, reltol, abstol)
      end
      function pfclyap(A::$PM, C::AbstractMatrix; kwargs...)
         pfclyap(A, $PM(C, A.period; nperiod = A.nperiod); kwargs...)
      end
   end
end
"""
    pfclyap(A, C; K = 10, solver, reltol, abstol) -> X

Solve the periodic forward-time Lyapunov differential equation

    .
    X(t) = A(t)X(t) + X(t)A(t)' + C(t) .               

The periodic matrices `A` and `C` must have the same type, the same dimensions and commensurate periods, 
and additionally `C` must be symmetric. The resulting symmetric periodic solution `X` has the period 
set to the least common commensurate period of `A` and `C` and the number of subperiods
is adjusted accordingly. 

This function is merely an interface to [`pclyap`](@ref)) (see this function for the description of keyword parameters). 
"""
pfclyap(A::PeriodicFunctionMatrix, C::PeriodicFunctionMatrix; K::Int = 10, solver = "non-stiff", reltol = 1.e-4, abstol = 1.e-7)
"""
    prclyap(A, C; K = 10, solver, reltol, abstol) -> X

Solve the periodic reverse-time Lyapunov differential equation

     .
    -X(t) = A(t)'X(t) + X(t)A(t) + C(t).               

The periodic matrices `A` and `C` must have the same type, the same dimensions and commensurate periods, 
and additionally `C` must be symmetric. The resulting symmetric periodic solution `X` has the period 
set to the least common commensurate period of `A` and `C` and the number of subperiods
is adjusted accordingly. 

This function is merely an interface to [`pclyap`](@ref)) (see this function for the description of keyword parameters). 
"""
prclyap(A::PeriodicFunctionMatrix, C::PeriodicFunctionMatrix; K::Int = 10, solver = "non-stiff", reltol = 1.e-4, abstol = 1.e-7)

"""
    pgclyap(A, C[, K = 1]; adj = false, solver, reltol, abstol, dt) -> X

Compute periodic generators for the periodic Lyapunov differential equation

    .
    X(t) = A(t)X(t) + X(t)A(t)' + C(t) , if adj = false,

or 

     .
    -X(t) = A(t)'X(t) + X(t)A(t) + C(t) , if adj = true.
    
The periodic matrices `A` and `C` must have the same type, the same dimensions and commensurate periods, 
and additionally `C` must be symmetric. 
The resulting `X` is a collection of periodic generator matrices determined 
as a periodic time-series matrix with `N` components, where `N = 1` if `A` and `C` are constant matrices
and `N = K` otherwise. 
The period of `X` is set to the least common commensurate period of `A` and `C` and the number of subperiods
is adjusted accordingly. Any component matrix of `X` is a valid initial value to be used to generate the  
solution over a full period by integrating the appropriate differential equation. 
The multiple-shooting method of [1] is employed, first, to convert the continuous-time periodic Lyapunov into a discrete-time periodic Lyapunov equation satisfied by 
the generator solution in `K` time grid points and then to compute the solution by solving an appropriate discrete-time periodic Lyapunov 
equation using the periodic Schur method of [2]. 

The ODE solver to be employed to convert the continuous-time problem into a discrete-time problem can be specified using the keyword argument `solver`, 
together with the required relative accuracy `reltol` (default: `reltol = 1.e-4`),  
absolute accuracy `abstol` (default: `abstol = 1.e-7`) and stepsize `dt' (default: `dt = 0`, only used if `solver = "symplectic"`) (see [`tvstm`](@ref)). 

For large values of `K`, parallel computation of the matrices of the discrete-time problem can be alternatively performed 
by starting Julia with several execution threads. 
The number of execution threads is controlled either by using the `-t/--threads` command line argument 
or by using the `JULIA_NUM_THREADS` environment variable.  

_References_

[1] A. Varga. On solving periodic differential matrix equations with applications to periodic system norms computation. 
    Proc. IEEE CDC/ECC, Seville, 2005. 

[2] A. Varga. Periodic Lyapunov equations: some applications and new algorithms. 
    Int. J. Control, vol, 67, pp, 69-87, 1997.
    
"""
function pgclyap(A::PM1, C::PM2, K::Int = 1; adj = false, solver = "non-stiff", reltol = 1e-4, abstol = 1e-7, dt = 0) where
      {PM1 <: Union{PeriodicFunctionMatrix,HarmonicArray,FourierFunctionMatrix}, PM2 <: Union{PeriodicFunctionMatrix,HarmonicArray,FourierFunctionMatrix}} 
   period = promote_period(A, C)
   na = Int(round(period/A.period))
   nc = Int(round(period/C.period))
   nperiod = gcd(na*A.nperiod, nc*C.nperiod)
   n = size(A,1)
   Ts = period/K/nperiod
   solver == "symplectic" && dt == 0 && (dt = K >= 100 ? Ts : Ts*K/100/nperiod)
   
   if isconstant(A) && isconstant(C)
      X = adj ? lyapc(tpmeval(A,0)', tpmeval(C,0)) :  lyapc(tpmeval(A,0), tpmeval(C,0))
   else
      T = promote_type(eltype(A),eltype(C),Float64)
      Ka = isconstant(A) ? 1 : max(1,Int(round(A.period/A.nperiod/Ts)))
      Ad = Array{T,3}(undef, n, n, Ka) 
      Cd = Array{T,3}(undef, n, n, K) 
      Threads.@threads for i = 1:Ka
         @inbounds Ad[:,:,i] = tvstm(A, i*Ts, (i-1)*Ts; solver, reltol, abstol) 
      end
      if adj
         Threads.@threads for i = K:-1:1
            @inbounds Cd[:,:,i]  = tvclyap(A, C, (i-1)*Ts, i*Ts; adj, solver, reltol, abstol, dt) 
         end
         X = pslyapd(Ad, Cd; adj)
      else
         #Threads.@threads for i = 1:K
         for i = 1:K
               @inbounds Cd[:,:,i]  = tvclyap(A, C, i*Ts, (i-1)*Ts; adj, solver, reltol, abstol, dt) 
         end
         X = pslyapd(Ad, Cd; adj)
      end
   end
   return PeriodicTimeSeriesMatrix([X[:,:,i] for i in 1:size(X,3)], period; nperiod)
end
function tvclyap(A::PM1, C::PM2, tf, t0, W0::Union{AbstractMatrix,Missing} = missing; adj = false, solver = "", reltol = 1e-4, abstol = 1e-7, dt = 0) where
   {PM1 <: Union{PeriodicFunctionMatrix,HarmonicArray,FourierFunctionMatrix}, PM2 <: Union{PeriodicFunctionMatrix,HarmonicArray,FourierFunctionMatrix}} 
   """
      tvclyap(A, C, tf, to; adj, solver, reltol, abstol) -> W::Matrix

   Compute the solution at tf > t0 of the differential matrix Lyapunov equation 
            .
            W(t) = A(t)*W(t)+W(t)*A'(t)+C(t), W(t0) = 0, tf > t0, if adj = false

   or 
            .
            W(t) = -A(t)'*W(t)-W(t)*A(t)-C(t), W(t0) = 0, tf < t0, if adj = true. 

   The ODE solver to be employed to convert the continuous-time problem into a discrete-time problem can be specified using the keyword argument `solver`, 
   together with the required relative accuracy `reltol` (default: `reltol = 1.e-4`),  
   absolute accuracy `abstol` (default: `abstol = 1.e-7`) and stepsize `dt' (default: `dt = abs(tf-t0)/100`, only used if `solver = "symplectic"`) (see [`tvstm`](@ref)). 
   """
   n = size(A,1)
   n == size(A,2) || error("the periodic matrix A must be square")
   (n,n) == size(C) || error("the periodic matrix C must have same dimensions as A")
   T = promote_type(typeof(t0), typeof(tf))
   # using OrdinaryDiffEq
   ismissing(W0) ? u0 = zeros(T,div(n*(n+1),2)) : u0 = MatrixEquations.triu2vec(W0)
   tspan = (T(t0),T(tf))
   fclyap!(du,u,p,t) = adj ? muladdcsym!(du, u, -1, tpmeval(A,t)', tpmeval(C,t)) : muladdcsym!(du, u, 1, tpmeval(A,t), tpmeval(C,t))
   prob = ODEProblem(fclyap!, u0, tspan)
   if solver == "stiff" 
      if reltol > 1.e-4  
         # standard stiff
         sol = solve(prob, Rodas4(); reltol, abstol, save_everystep = false)
      else
         # high accuracy stiff
         sol = solve(prob, KenCarp58(); reltol, abstol, save_everystep = false)
      end
   elseif solver == "non-stiff" 
      if reltol > 1.e-4  
         # standard non-stiff
         sol = solve(prob, Tsit5(); reltol, abstol, save_everystep = false)
      else
         # high accuracy non-stiff
         sol = solve(prob, Vern9(); reltol, abstol, save_everystep = false)
      end
   elseif solver == "symplectic" 
      # high accuracy symplectic
      if dt == 0 
         sol = solve(prob, IRKGaussLegendre.IRKGL16(maxtrials=4); adaptive = true, reltol, abstol, save_everystep = false)
         #@show sol.retcode
         if sol.retcode == :Failure
            sol = solve(prob, IRKGaussLegendre.IRKGL16(); adaptive = false, reltol, abstol, save_everystep = false, dt = abs(tf-t0)/100)
         end
      else
           sol = solve(prob, IRKGaussLegendre.IRKGL16(); adaptive = false, reltol, abstol, save_everystep = false, dt)
      end
 else 
      if reltol > 1.e-4  
         # low accuracy automatic selection
         sol = solve(prob, AutoTsit5(Rosenbrock23()) ; reltol, abstol, save_everystep = false)
      else
         # high accuracy automatic selection
         sol = solve(prob, AutoVern9(Rodas5(),nonstifftol = 11/10); reltol, abstol, save_everystep = false)
      end
   end
   return MatrixEquations.vec2triu(sol[end], her=true)     
end
function muladdcsym!(y::AbstractVector, x::AbstractVector, isig, A::AbstractMatrix, C::AbstractMatrix)
   # A*X + X*A' + C
   n = size(A, 1)
   T1 = promote_type(eltype(A), eltype(x))
   # TO DO: eliminate building of X by using directly x
   X = MatrixEquations.vec2triu(convert(AbstractVector{T1}, x), her=true)
   @inbounds begin
      k = 1
      for j = 1:n
         for i = 1:j
            temp = C[i,j]
            for l = 1:n
               temp += A[i,l] * X[l,j] + X[i,l] * A[j,l]
            end
            y[k] = isig*temp
            k += 1
         end
      end
   end
   return y
end
# function tvcplyap(A::PM1, C::PM2, tf, t0, U0::Union{AbstractMatrix,Missing} = missing; adj = false, solver = "", reltol = 1e-4, abstol = 1e-7, dt = 0) where
#    {PM1 <: Union{PeriodicFunctionMatrix,HarmonicArray,FourierFunctionMatrix}, PM2 <: Union{PeriodicFunctionMatrix,HarmonicArray,FourierFunctionMatrix}} 
#    """
#       tvcplyap(A, C, tf, to; adj, solver, reltol, abstol) -> U::Matrix

#    Compute the upper triangular factor U(t) of the solution W(t) = U(t)U(t)' at tf > t0 of the differential matrix Lyapunov equation 
#             .
#             W(t) = A(t)*W(t)+W(t)*A'(t)+C(t)*C(t)', W(t0) = 0, tf > t0, if adj = false

#    or the upper triangular factor U(t) of the solution W(t) = U(t)'U(t) at tf < t0 of the differential matrix Lyapunov equation 
#             .
#             W(t) = -A(t)'*W(t)-W(t)*A(t)-C(t)'*C(t), W(t0) = 0, tf < t0, if adj = true,
            
#    where A(t) is a stable periodic matrix.           

#    The implicit differential-algebraic solver IDA() from the Sundials package is employed to convert the continuous-time problem 
#    into a discrete-time problem, for which the required relative accuracy can be specified via the keyword argument 
#    `reltol` (default: `reltol = 1.e-8`) and the  
#    absolute accuracy can be specified via the keyword argument `abstol` (default: `abstol = 1.e-8`). 
#    """
#    n = size(A,1)
#    n == size(A,2) || error("the periodic matrix A must be square")
#    (adj && n == size(C,2)) || error("the periodic matrix C must have same number of columns as A")
#    (!adj && n == size(C,1)) || error("the periodic matrix C must have same number of rows as A")
#    T = promote_type(typeof(t0), typeof(tf))
#    # using IDAfrom Sundials
#    N = div(n*(n+1),2)
#    ismissing(U0) && (U0 = 10*eps(T)*I(n))
#    tspan = (T(t0),T(tf))
#    Q = adj ? C'*C : C*C'
#    # ensure dU0'*U0+U0'*dU0 = p
#    dU0 = 0.5*(U0'\p)
#    dUl = tril(dU0/U0,-1)
#    z = -dUl+dUl'
#    dU0 = triu(dU0+z*U0)
#    u0 = MatrixEquations.triu2vec(U0)
#    du0 = MatrixEquations.triu2vec(dU0)
#    differential_vars = trues(N)

#    prob = DAEProblem(fcplyap, du0, u0, tspan, (A, C, adj); differential_vars)
#    sol = solve(prob, IDA(); abstol, reltol)


#    return MatrixEquations.vec2triu(sol[end], her=false)     
# end
# function fcplyap(out,du,u,p,t) 
#    A, C, adj = p
#    U = MatrixEquations.vec2triu(convert(AbstractVector{T1}, u), her=false)
#    dU = MatrixEquations.vec2triu(convert(AbstractVector{T1}, du), her=false)
#    dtU = adj ? dU'*U+U'*dU : dU*U'+ U*dU'
#    At = adj ? tpmeval(A,t)' : tpmeval(A,t)
#    Ct = tpmeval(C,t)
#    isig = adj ? -1 : 1
#    X = adj ? U'*U : U*U' 
#    @inbounds begin
#       k = 0
#       for j = 1:n
#          for i = 1:j
#             k += 1
#             temp = Ct[i,j] - dtU[i,j] 
#             for l = 1:n
#                temp += At[i,l] * X[l,j] + X[i,l] * At[j,l]
#             end
#             out[k] = isig*temp
#          end
#       end
#    end
# end
   