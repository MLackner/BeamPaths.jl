module BeamPaths

import Base: @kwdef
using Luxor
using Printf

export BeamPath, BeamPathAttributes
export Component, Source, Mirror, Aperture, Filter, Lens, Shutter
export Label
export render

const COMPONENTS_DIR = joinpath(@__DIR__, "../assets/components/")

Base.@kwdef struct BeamPathAttributes
    hue::String = "red"
    linewidth::Float64 = 1.0
end

struct BeamPath{T}
    attributes::BeamPathAttributes
    components::Vector{T}
end
BeamPath(x::Vector{T}) where T = BeamPath(BeamPathAttributes(), x)

hue(x::BeamPath) = x.attributes.hue
linewidth(x::BeamPath) = x.attributes.linewidth

# ARRAY INTERFACE FOR THE BeamPath TYPE #
Base.iterate(x::BeamPath) = iterate(x.components)
Base.iterate(x::BeamPath, state) = iterate(x.components, state)
Base.length(x::BeamPath) = length(x.components)
Base.eachindex(x::BeamPath) = eachindex(x.components)
# Indexing
Base.getindex(x::BeamPath, i::Int) = getindex(x.components, i)
Base.setindex!(x::BeamPath, v, i::Int) = setindex!(x.components, v, i)
Base.firstindex(x::BeamPath) = x.components[begin]
Base.lastindex(x::BeamPath) = x.components[end]
# Abstract Arrays
Base.size(x::BeamPath) = size(x.components)
Base.getindex(x::BeamPath, I::Vararg{Int, N}) where N = getindex(x.components, I)
Base.setindex!(x::BeamPath, v, I::Vararg{Int, N}) where N = setindex!(x.components, v, I)
# Fitering
Base.filter(f::Function, x::BeamPath) = filter(f, x.components)


abstract type AbstractComponent end
abstract type AbstractMirror <: AbstractComponent end
abstract type AbstractFilter <: AbstractComponent end
abstract type AbstractShutter <: AbstractComponent end
abstract type AbstractAperture <: AbstractComponent end
abstract type AbstractSource <: AbstractComponent end

Base.@kwdef struct Label
    text::String = ""
    pos::Tuple{Float64,Float64} = (25, 0)
    halign="left"
    valign="bottom"
    angle=0
    markup=false
end

Base.@kwdef struct Component <: AbstractComponent
    pos::Tuple{Float64,Float64}=(0.0, 0.0)
    rot::Float64=0.0
    label::Label=Label()
end


Base.@kwdef struct Source <: AbstractSource
    pos::Tuple{Float64,Float64}=(0.0, 0.0)
    rot::Float64=0.0
    label::Label=Label()
end

Base.@kwdef struct Mirror <: AbstractMirror
    pos::Tuple{Float64,Float64}=(0.0, 0.0)
    rot::Float64=0.0
    label::Label=Label()
end

Base.@kwdef struct Aperture <: AbstractAperture
    pos::Tuple{Float64,Float64}=(0.0, 0.0)
    rot::Float64=0.0
    label::Label=Label()
end

Base.@kwdef struct Filter <: AbstractFilter
    pos::Tuple{Float64,Float64}=(0.0, 0.0)
    rot::Float64=0.0
    label::Label=Label()
end

abstract type AbstractLens <: AbstractComponent end

Base.@kwdef struct Lens <: AbstractLens
    pos::Tuple{Float64,Float64}=(0.0, 0.0)
    rot::Float64=0.0
    label::Label=Label()
    focallength::Float64=0.0
end

Base.@kwdef struct Shutter <: AbstractShutter
    pos::Tuple{Float64,Float64}=(0.0, 0.0)
    rot::Float64=0.0
    label::Label=Label()
end

assetpath(::C) where C <: AbstractComponent = joinpath(@__DIR__, "../assets/components/component.svg")
assetpath(::C) where C <: AbstractMirror = joinpath(@__DIR__, "../assets/components/mirror.svg")
assetpath(::C) where C <: AbstractFilter = joinpath(@__DIR__, "../assets/components/filter.svg")
assetpath(::C) where C <: AbstractLens = joinpath(@__DIR__, "../assets/components/lens.svg")
assetpath(::C) where C <: AbstractShutter = joinpath(@__DIR__, "../assets/components/shutter.svg")
assetpath(::C) where C <: AbstractAperture = joinpath(@__DIR__, "../assets/components/aperture.svg")
assetpath(::C) where C <: AbstractSource = joinpath(@__DIR__, "../assets/components/source.svg")

function render(filename::String, beampath::BeamPath; margin=100)
    x0, xE, y0, yE = dimensions(beampath)
    offset = Point(x0, y0) - Point(margin, margin)
    x = xE - x0 + 2margin
    y = yE - y0 + 2margin

    Drawing(x, y, filename)
    background("white")

    # add gridlines
    setopacity(0.2)
    setdash("dot")
    gridspace = 50
    for _y in gridspace:gridspace:y
        line(Point(0,_y), Point(x,_y), :stroke)
        y_original = _y + y0 - margin
        settext(@sprintf("%d", y_original), Point(0,_y))
    end
    for _x in 0:gridspace:x-gridspace
        line(Point(_x,0), Point(_x,y), :stroke)
        x_original = _x + x0 - margin
        settext(@sprintf("%d", x_original), Point(_x, 16); valign="bottom")
    end

    setopacity(1.0)
    setdash("solid")
    origin(0, 0)
    bpflat = flatten(beampath)
    for i in eachindex(bpflat)
        comp = bpflat[i]

        # draw component
        drawcomponent(comp, offset)

        # draw label
        sethue("black")
        rotate(0)
        origin(Point(comp.pos) - offset)
        l = comp.label
        p = Point(l.pos)
        kwargs = (
            markup=l.markup,
            halign=l.halign,
            angle=l.angle,
            valign=l.valign
        )
        settext(l.text, p; kwargs...)
    end

    origin(-offset)
    drawpath(beampath)

    finish()
    preview()
end


function draw(comp::T, offset) where T <: AbstractComponent
    origin(Point(comp.pos) - offset)
    rotate(deg2rad(comp.rot))
    asset = readsvg(assetpath(comp))
    w = asset.width
    h = asset.height
    placeimage(asset; centered=true)
    # draw center point of component (debug)
    # sethue("red")
    # circle(Point(0,0), 5, :fill)
    # draw rectangle around the image of the asset
    # r = rect(Point(-w/2,-h/2), w, h, :stroke)
    # @show BoundingBox(r)
end

drawcomponent(comp::T, offset) where T <: AbstractComponent = draw(comp, offset)

function drawcomponent(comp::T, offset) where T <: AbstractLens
    origin(Point(comp.pos) - offset)
    # draw focal length
    px = comp.focallength * cos(deg2rad(comp.rot))
    py = comp.focallength * sin(deg2rad(comp.rot))
    f1 = Point(px, py)
    f2 = -Point(px, py)
    for f in [f1, f2]
        polycross(f, 8, 4, 0.1, π/4, action=:fill, splay=0.5)
    end
    draw(comp, offset)
end

function drawpath(x::BeamPath; kwargs...)
    x_nosplit = filter(_x -> !(_x isa BeamPath), x)
    for i in 1:length(x_nosplit)-1
        x_nosplit[i]
        drawpath(x_nosplit[i], x_nosplit[i+1]; hue=hue(x), linewidth=linewidth(x))
    end
    # find and draw subpaths
    subpath_indices = Int[]
    for i in eachindex(x)
        x[i] isa BeamPath && push!(subpath_indices, i)
    end

    for i in eachindex(subpath_indices)
        j = subpath_indices[i] - 1
        while j ≥ 1 
            if !(j in subpath_indices)
                subpath = x[subpath_indices[i]]
                drawpath(BeamPath(subpath.attributes, [x[j], subpath...]); hue=hue(subpath), linewidth=linewidth(subpath))
                break
            end
            j -= 1
        end
    end
end

drawpath(c1, c2::BeamPath; kwargs...) = drawpath(c1, first(c2); kwargs...)

function drawpath(c1, c2; hue="purple", linewidth=1)
    sethue(hue)
    setline(linewidth)
    line(Point(c1.pos), Point(c2.pos), :stroke)
end

"""
Evaluate the height and width of a beampath in pixels.
"""
function dimensions(bp::BeamPath)
    # this flattening is kind of hacky since it does only
    # work for a certain depth of nested arrays
    bpflat = flatten(bp)

    # xmin, xmax, ymin, ymax
    p0 = position(bpflat[1])
    dims = [p0[1], p0[1], p0[2], p0[2]]

    for el in bpflat
        x, y = position(el)
        x < dims[1] && setindex!(dims, x, 1)
        x > dims[2] && setindex!(dims, x, 2)
        y < dims[3] && setindex!(dims, y, 3)
        y > dims[4] && setindex!(dims, y, 4)
    end

    dims
end

position(x::AbstractComponent) = x.pos

function flatten(x::BeamPath)
    xflat = Any[]

    for el in x
        flatten!(xflat, el)
    end

    xflat
end

flatten!(xflat, x::AbstractComponent) = push!(xflat, x)
flatten!(xflat, x::BeamPath) = for _x in x flatten!(xflat, _x) end

end
