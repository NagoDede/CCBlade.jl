import Pkg; 
#Pkg.add("CCBlade")
Pkg.add("Plots")
Pkg.add("FLOWMath")

include("CCBlade.jl")

using Printf
using Plots

Rtip = 1.95/2 # tip radius - MTV-18-195-56
Rhub =0.15  # hub radius. MTV-18 is 301mm

precone = 0.0 #precone set to 0
B = 3 # number of blades
rotor = CCBlade.Rotor(Rhub, Rtip, B)

chord = 0.15 
theta = 0.0
nbstation = 40 #number of section per blade
r = range(Rhub, Rtip, length=nbstation)

af = CCBlade.AlphaAF("data/naca0012.txt", radians=false)
function af2(alpha, Re, M)
    cl, cd = CCBlade.afeval(af, alpha, Re, M)
    return cl, cd+0.014  # drag addition per report for Reynolds number adjustment
end
sections = CCBlade.Section.(r, chord, theta, af2)

rho = 1.225
Omega = 2000*pi/30 #2000 RPM to rad/s
Vinf = 40.0 #speed in m/s 100kt ~ 50m/s

nP = 40
#assume a fixed pitch of 25deg
prop_pitch = 25*pi/180 # range(1e-4, 20*pi/180, length=nP) 

CT = zeros(nP)
CQ = zeros(nP)
FM = zeros(nP)
CT2 = zeros(nP)
CQ2 = zeros(nP)
FM2 = zeros(nP)

sigma = B * chord / (pi * Rtip)

#study per 10deg step
x = 0:10*pi/180:2*pi

locval = zeros(Float64, r.len, x.len)
op1 = CCBlade.simple_op.(Vinf, Omega, r, rho;  pitch=prop_pitch)
outputs1 = CCBlade.solve.(Ref(rotor), sections, op1)
T1, Q1 = CCBlade.thrusttorque(rotor, sections, outputs1)
#for i = 1:nP
for i = 1:x.len
    @printf("angle %f°\n",x[i]*180/pi)
    #simple propeller approach, aicraft yaw and pitch = 0
    #used for comparisons
    
    op2 = CCBlade.propeller_op.(Vinf, Omega, prop_pitch, r, rho, tilt = 10*pi/180, azimuth = x[i] )
    outputs2 = CCBlade.solve.(Ref(rotor), sections, op2)
    T2, Q2 = CCBlade.thrusttorque(rotor, sections, outputs2)
    @printf("T1 %f vs T2 %f \n", T1, T2)

    
    Npfull = outputs2.Np
    j = 1
    for np in Npfull
        locval[j,i] = np
        j = j+1
    end
    
   



    #FM[i], CT[i], CQ[i] = CCBlade.nondim(T, Q, Vinf, Omega, rho, rotor, "propeller")
    #FM2[i], CT2[i], CQ2[i] = CCBlade.nondim(T2, Q2, Vinf, Omega, rho, rotor, "propeller")
    #@printf("CT: %.3e - CQ: %.3ee - CT2: %.3e - CQ2: %.3e \n", CT[i], CQ[i], CT2[i], CQ2[i])
end



heatmap(x,r,locval, projection = :polar)