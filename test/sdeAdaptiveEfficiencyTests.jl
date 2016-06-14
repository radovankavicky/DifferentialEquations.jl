addprocs(32)

using DifferentialEquations, Plots, LaTeXStrings

probs = Vector{SDEProblem}(3)
p1 = Vector{Any}(3)
p2 = Vector{Any}(3)
p3 = Vector{Any}(3)
## Problem 1
probs[1] = linearSDEExample(α=1/10,β=1/20,u₀=1/2)
## Problem 2
probs[2] = waveSDEExample()
## Problem 3
probs[3] = additiveSDEExample()

for k in eachindex(probs)
  println("Problem $k")
  ## Setup
  prob = probs[k]
  N = 16
  msims = Vector{MonteCarloSimulation}(N)
  elapsed = Array{Float64}(N,3)
  medians = Array{Float64}(N,3)
  means   = Array{Float64}(N,3)
  tols    = Array{Float64}(N,3)

  #Compile
  adaptiveAlg = "RSwM1"
  monteCarloSim(prob::SDEProblem,Δt=1//2^(4),adaptive=true,numMonte=1000,abstol=2.0^(-1),reltol=0,adaptiveAlg=adaptiveAlg)

  println("RSwM1")
  adaptiveAlg = "RSwM1"
  @progress for i=1:N
    tols[i,1] = 2.0^(-i-1)
    msims[i] = monteCarloSim(prob::SDEProblem,Δt=1//2^(4),adaptive=true,numMonte=1000,abstol=2.0^(-i-1),reltol=0,adaptiveAlg=adaptiveAlg)
    elapsed[i,1] = msims[i].elapsedTime
    medians[i,1] = msims[i].medians["l2"]
    means[i,1]   = msims[i].means["l2"]
  end

  println("RSwM2")
  adaptiveAlg = "RSwM2"
  @progress for i=1:N
    tols[i,2] = 2.0^(-i-1)
    msims[i] = monteCarloSim(prob::SDEProblem,Δt=1//2^(4),adaptive=true,numMonte=1000,abstol=2.0^(-i-1),reltol=0,adaptiveAlg=adaptiveAlg)
    elapsed[i,2] = msims[i].elapsedTime
    medians[i,2] = msims[i].medians["l2"]
    means[i,2]   = msims[i].means["l2"]
  end

  println("RSwM3")
  adaptiveAlg = "RSwM3"
  @progress for i=1:N
    tols[i,3] = 2.0^(-i-1)
    msims[i] = monteCarloSim(prob::SDEProblem,Δt=1//2^(4),adaptive=true,numMonte=1000,abstol=2.0^(-i-1),reltol=0,adaptiveAlg=adaptiveAlg)
    elapsed[i,3] = msims[i].elapsedTime
    medians[i,3] = msims[i].medians["l2"]
    means[i,3]   = msims[i].means["l2"]
  end
  lw=3
  leg=String["RSwM1","RSwM2","RSwM3"]'
  p1[k] = plot(tols,means,xscale=:log10,yscale=:log10,  xguide="Absolute Tolerance",yguide="Mean $l2 Error",title="Example $k",linewidth=lw,grid=false,lab=leg,top_margin=50px,left_margin=100px,right_margin=50px,bottom_margin=50px,titlefont=font(24),legendfont=font(14),tickfont=font(16),guidefont=font(16))
  p2[k] = plot(tols,medians,xscale=:log10,yscale=:log10,xguide="Absolute Tolerance",yguide="Median $l2 Error",title="Example $k",linewidth=lw,grid=false,lab=leg,top_margin=50px,left_margin=100px,right_margin=50px,bottom_margin=50px,titlefont=font(24),legendfont=font(14),tickfont=font(16),guidefont=font(16))
  p3[k] = plot(tols,elapsed,xscale=:log10,yscale=:log10,xguide="Absolute Tolerance",yguide="Elapsed Time",title="Example $k",linewidth=lw,grid=false,lab=leg,top_margin=50px,left_margin=100px,right_margin=50px,bottom_margin=50px,titlefont=font(24),legendfont=font(14),tickfont=font(16),guidefont=font(16))
end

plot!(p1[1],margin=[20mm 0mm])
plot(p1[1],p1[2],p1[3],layout=(3,1),size=(1000,800),top_margin=50px,left_margin=100px,right_margin=50px)
savefig("meanvstol.png")
savefig("meanvstol.pdf")
plot(p3[1],p3[2],p3[3],layout=(3,1),size=(1000,800),top_margin=50px,left_margin=100px,right_margin=50px)
savefig("timevstol.png")
savefig("timevstol.pdf")
gui()