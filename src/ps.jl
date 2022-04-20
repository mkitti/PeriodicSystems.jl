const APMorVM = Union{AbstractPeriodicArray, AbstractVecOrMat}
"""
    ps([PMT::Type,] A::PM1, B::PM2, C::PM3, D::PM4) -> psys::PeriodicStateSpace

Construct a `PeriodicStateSpace` object from a quadruple of periodic matrix objects. 

The periodic matrix objects `A`, `B`, `C`, `D` specifies the periodic matrices
`A(t)`, `B(t)`, `C(t)` and `D(t)` of a linear periodic time-varying state space model
in the continuous-time form

     dx(t)/dt = A(t)x(t) + B(t)u(t) ,
     y(t)     = C(t)x(t) + D(t)u(t) ,

or in the discrete-time form

     x(t+1)  = A(t)x(t) + B(t)u(t) ,
     y(t)    = C(t)x(t) + D(t)u(t) , 

where `x(t)`, `u(t)` and `y(t)` are the system state vector, 
system input vector and system output vector, respectively, 
and `t` is the continuous or discrete time variable. 
The system matrices satisfy `A(t) = A(t+T₁)`, `B(t) = B(t+T₂)`, `C(t) = C(t+T₃)`, `D(t) = D(t+T₄)`,  
i.e., are periodic with periods `T₁`, `T₂`, `T₃` and `T₄`, respectively. 
The different periods must be commensurate (i.e., their ratios must be rational numbers with
numerators and denominators up to at most 4 decimal digits). 
The periodic matrix objects `A`, `B`, `C`, `D` can have different types `PM1`, `PM2`, `PM3`, `PM4`, respectively,
where for a contiuous-time system 
`PM1`, `PM2`, `PM3`, `PM4` must be one of the supported continuous-time periodic matrix types, i.e., 
[`PeriodicFunctionMatrix`](@ref), [`PeriodicSymbolicMatrix`](@ref),
[`HarmonicArray`](@ref), [`FourierFunctionMatrix`](@ref) or [`PeriodicTimeSeriesMatrix`](@ref),
while for a discrete-time system  `PM1`, `PM2`, `PM3`, `PM4` must be one of the supported discrete-time periodic matrix types, i.e., 
[`PeriodicMatrix`](@ref) or [`PeriodicArray`](@ref).  
Any of the objects `A`, `B`, `C`, `D` can be also specified as a real matrix or vector of appropriate size. 

If `PMT` is not specified, the resulting `psys` has periodic matrices of the same type `PT`, such that `PT` is either the common type
of all matrix objects or `PT = PeriodicFunctionMatrix` for a continuous-time system or  `PT = PeriodicMatrix` for a discrete-time system. 
If `PMT` is specified, the resulting `psys` has periodic matrices of the same type `PMT`. 

Other convenience constructors are implemented as follows: 

    ps([PMT::Type,] A, B, C) -> psys::PeriodicStateSpace

to construct a `PeriodicStateSpace` object for a quadruple of the form `(A,B,C,0)`;

    ps(D) -> psys::PeriodicStateSpace

to construct a `PeriodicStateSpace` object for a quadruple of the form `([],[],[],D)`;

    ps([PMT::Type,] A, B, C, D, period) -> psys::PeriodicStateSpace

to construct a `PeriodicStateSpace` object with a desired `period` for a quadruple `(A,B,C,D)`;
all objects `A`, `B`, `C`, `D` can be also specified as real matrices or vectors of appropriate sizes. 

   
    ps([PMT::Type,] A, B, C, period) -> psys::PeriodicStateSpace

to construct a `PeriodicStateSpace` object with a desired `period` for a quadruple `(A,B,C,0)`;
all objects `A`, `B`, `C` can be also specified as real matrices or vectors of appropriate sizes. 
   
    ps(sys::DescriptorStateSpace, period) -> psys::PeriodicStateSpace

to construct a `PeriodicStateSpace` object with a desired `period` for a quadruple `(sys.A,sys.B,sys.C,sys.D)`
(`sys.E = I` is assumed).
"""
function ps(A::APMorVM, B::APMorVM, C::APMorVM, D::APMorVM) 
   cont = nothing 
   PMT = (typeof(A),typeof(B),typeof(C),typeof(D)) 
   PMTM = trues(4)
   nmat = 0
   npmat = 0
   for i = 1:4
       if PMT[i] <: AbstractVecOrMat 
          nmat += 1
       else
          PMTM[i] = false
          npmat += 1
          t = PMT[i].parameters[1] == :c
          if isnothing(cont) 
             cont = t
          else
             cont == t ||  error("all matrix objects must be either continuous or discrete")
          end
       end
   end
   all(PMTM) && error("period and sample time must be specified in the case of only matrix inputs")
   PMTA = PMT[1].name.wrapper
   if !any(PMTM) 
      # all inputs are periodic matrices
      if all(PMT[2:4] .<: PMTA)
         return PeriodicStateSpace(A,B,C,D)
      elseif cont 
         return PeriodicStateSpace(convert(PeriodicFunctionMatrix,A), convert(PeriodicFunctionMatrix,B), 
                  convert(PeriodicFunctionMatrix,C), convert(PeriodicFunctionMatrix,D))
      else 
         return PeriodicStateSpace(convert(PeriodicMatrix,A), convert(PeriodicMatrix,B), 
                                 convert(PeriodicMatrix,C), convert(PeriodicMatrix,D));
      end
   else
      # some inputs are matrices to be appropriately converted to periodic matrix objects
      period = promote_period(A,B,C,D)
      if cont
         return PeriodicStateSpace(PMTM[1] ? PeriodicFunctionMatrix(A,period) : convert(PeriodicFunctionMatrix,A), 
                                   PMTM[2] ? PeriodicFunctionMatrix(B,period) : convert(PeriodicFunctionMatrix,B),
                                   PMTM[3] ? PeriodicFunctionMatrix(C,period) : convert(PeriodicFunctionMatrix,C),
                                   PMTM[4] ? PeriodicFunctionMatrix(D,period) : convert(PeriodicFunctionMatrix,D))
      else 
         return PeriodicStateSpace(PMTM[1] ? PeriodicMatrix(A,period) : convert(PeriodicMatrix,A), 
                                   PMTM[2] ? PeriodicMatrix(B,period) : convert(PeriodicMatrix,B),
                                   PMTM[3] ? PeriodicMatrix(C,period) : convert(PeriodicMatrix,C),
                                   PMTM[4] ? PeriodicMatrix(D,period) : convert(PeriodicMatrix,D))
      end
   end
end
function ps(PMT::Type, A::APMorVM, B::APMorVM, C::APMorVM, D::APMorVM)
    period = promote_period(A,B,C,D)
    ps(typeof(A) <: AbstractVecOrMat ? PMT(A,period) : convert(PMT,A), 
       typeof(B) <: AbstractVecOrMat ? PMT(B,period) : convert(PMT,B), 
       typeof(C) <: AbstractVecOrMat ? PMT(C,period) : convert(PMT,C), 
       typeof(D) <: AbstractVecOrMat ? PMT(D,period) : convert(PMT,D))
end
ps(A::APMorVM, B::APMorVM, C::APMorVM, D::APMorVM, period::Real) =
    ps(set_period(A,period), set_period(B,period), set_period(C,period), set_period(D,period))
ps(PMT::Type, A::APMorVM, B::APMorVM, C::APMorVM, D::APMorVM, period::Real) =
    ps(typeof(A) <: AbstractVecOrMat ? A : convert(PMT,set_period(A,period)), 
       typeof(B) <: AbstractVecOrMat ? B : convert(PMT,set_period(B,period)), 
       typeof(C) <: AbstractVecOrMat ? C : convert(PMT,set_period(C,period)), 
       typeof(D) <: AbstractVecOrMat ? D : convert(PMT,set_period(D,period)))

ps(A::APMorVM, B::APMorVM, C::APMorVM) = ps(A,B,C,zeros(Float64,size(C,1)[1],size(B,2)[1]))
function ps(PMT::Type, A::APMorVM, B::APMorVM, C::APMorVM)
   period = promote_period(A,B,C)
   ps(typeof(A) <: AbstractVecOrMat ? PMT(A,period) : convert(PMT,A), 
      typeof(B) <: AbstractVecOrMat ? PMT(B,period) : convert(PMT,B), 
      typeof(C) <: AbstractVecOrMat ? PMT(C,period) : convert(PMT,C),
      PMT(zeros(Float64,size(C,1)[1],size(B,2)[1]),period))
end
ps(A::APMorVM, B::APMorVM, C::APMorVM, period::Real) =
    ps(set_period(A,period), set_period(B,period), set_period(C,period), zeros(size(C,1),size(B,2)))
ps(PMT::Type, A::APMorVM, B::APMorVM, C::APMorVM, period::Real) =
    ps(PMT, set_period(A,period), set_period(B,period), set_period(C,period))

function ps(D::PM) where {PM <: AbstractPeriodicArray}
    p, m = size(D,1), size(D,2)
    PMT = typeof(D).name.wrapper
    ps(convert(PMT,PeriodicFunctionMatrix(zeros(0,0),D.period)),
       convert(PMT,PeriodicFunctionMatrix(zeros(0,m),D.period)), 
       convert(PMT,PeriodicFunctionMatrix(zeros(p,0),D.period)), D)
end
function ps(sys::DST, period::Real) where {DST <: DescriptorStateSpace}
    sys.E == I || error("only standard state-spece models supported")
    Ts = sys.Ts
    if Ts == 0
       ps(PeriodicFunctionMatrix(sys.A,period), PeriodicFunctionMatrix(sys.B,period),
          PeriodicFunctionMatrix(sys.C,period),PeriodicFunctionMatrix(sys.D,period))
    else
      r = rationalize(period/abs(Ts))
      denominator(r) == 1 || error("incommensurate period and sample time")
      d = Ts == -1 ? 1 : numerator(r)
      ps(PeriodicMatrix(sys.A, period; nperiod = d), PeriodicMatrix(sys.B,period; nperiod = d), 
         PeriodicMatrix(sys.C,period; nperiod = d), PeriodicMatrix(sys.D,period; nperiod = d))
    end
end
islti(psys::PeriodicStateSpace) = isconstant(psys.A) && isconstant(psys.B) && isconstant(psys.C) && isconstant(psys.D) 

function ps(A::AbstractVecOrMat, B::AbstractVecOrMat, C::AbstractVecOrMat, D::AbstractVecOrMat, period::Real; Ts::Union{Real,Missing} = missing) 
    if ismissing(Ts)
       ps(PeriodicFunctionMatrix(A,period), PeriodicFunctionMatrix(B,period), 
          PeriodicFunctionMatrix(C,period), PeriodicFunctionMatrix(D,period))
    else
       Ts == -1 || Ts > 0 || error("sampling time must be -1 or positive")
       r = rationalize(period/abs(Ts))
       denominator(r) == 1 || error("incommensurate period and sample time")
       d = numerator(r)
       ps(PeriodicMatrix(A, period; nperiod = d), PeriodicMatrix(B,period; nperiod = d), 
          PeriodicMatrix(C,period; nperiod = d), PeriodicMatrix(D,period; nperiod = d))
    end
end
ps(A::AbstractVecOrMat, B::AbstractVecOrMat, C::AbstractVecOrMat, period::Real; Ts::Union{Real,Missing} = missing) =
   ps(A, B, C, zeros(size(C,1),size(B,2)), period; Ts)
