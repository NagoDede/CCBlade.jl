export rotateAboutZ
export yawToWind, windToYaw
export hubToYaw, yawToHub
export  hubToAzimuth, azimuthToHub
export bladeToAzimuth, azimuthToBlade

using Printf

struct DirectionVector{T<:Float64}
    x::T
    y::T
    z::T
end

"""
    Compute direction vector expressed in its coordinate systems to 
    another coordinate system rotate of θ radians around z axis
Parameters defining the rotor (apply to all sections).  
"""
function rotateAboutZ(self::DirectionVector, xstring::Symbol, ystring::Symbol, zstring::Symbol, θ; reverse = false)
        x = getfield(self, xstring)
        y = getfield(self, ystring)
        z = getfield(self, zstring)

        if reverse
            θ = -θ
        end

        c = cos(θ)
        s = sin(θ)

        xnew = x * c + y*s
        ynew = -x*s+y*c
        return DirectionVector(xnew,ynew,z)
end

"""Rotates from yaw-aligned to wind-aligned
Parameters
----------
Psi : float (rad)
    yaw angle
Returns
-------
vector : DirectionVector
    a DirectionVector in the wind-aligned coordinate system
"""
function yawToWind(self::DirectionVector, Ψ)
    return rotateAboutZ(self, :x, :y, :z, Ψ, reverse=true)
end

"""Rotates from wind-aligned to yaw-aligned
Parameters
----------
Psi : float (rad)
    yaw angle
Returns
-------
vector : DirectionVector
    a DirectionVector in the yaw-aligned coordinate system
"""
function windToYaw(self::DirectionVector, Ψ)
    return rotateAboutZ(self, :x, :y, :z, Ψ)
end

"""Rotates from hub-aligned to yaw-aligned
Parameters
----------
Theta : float (rad)
    tilt angle
Returns
-------
vector : DirectionVector
    a DirectionVector in the hub-aligned coordinate system
"""
function hubToYaw(self::DirectionVector, Θ)
    return rotateAboutZ(self, :z, :x, :y, Θ, reverse= true)
end

"""Rotates from yaw-aligned to hub-aligned
Parameters
----------
Theta : float (rad)
    tilt angle
Returns
-------
vector : DirectionVector
    a DirectionVector in the yaw-aligned coordinate system
"""
function yawToHub(self::DirectionVector, Θ)
    return rotateAboutZ(self, :z, :x, :y, Θ)
end

"""Rotates from hub-aligned to Azimuth-aligned
Parameters
----------
Lambda : float (rad)
    azimuth angle
Returns
-------
vector : DirectionVector
    a DirectionVector in the azimuth-aligned coordinate system
"""
function hubToAzimuth(self::DirectionVector, Λ)
    return rotateAboutZ(self, :y, :z, :x, Λ)
end

"""Rotates from azimuth-aligned to hub-aligned
Parameters
----------
Lambda : float (rad)
    azimuth angle
Returns
-------
vector : DirectionVector
    a DirectionVector in the hub-aligned coordinate system
"""
function azimuthToHub(self::DirectionVector, Λ)
    return rotateAboutZ(self, :y, :z, :x, Λ, reverse = true)
end

"""Rotates from azimuth-aligned to blade-aligned
Parameters
----------
Phi : float (rad)
    precone angle
Returns
-------
vector : DirectionVector
    a DirectionVector in the blade-aligned coordinate system
"""
function azimuthToBlade(self::DirectionVector, Φ)
    return rotateAboutZ(self, :z, :x, :y, Φ, reverse = true)
end

"""Rotates from blade-aligned to azimuth-aligned
Parameters
----------
Phi : float (rad)
    precone angle
Returns
-------
vector : DirectionVector
    a DirectionVector in the azimuth-aligned coordinate system
"""
function bladeToAzimuth(self::DirectionVector, Φ)
    return rotateAboutZ(self, :z, :x, :y, Φ)
end

a = DirectionVector(1.0,0.0,0.0)
b=yawToWind(a,π/2)
b=windToYaw(a,π/2)
@printf("%f, %f, %f", b.x, b.y, b.z)