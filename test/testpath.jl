shutter = Shutter(
    pos=(650, 375), 
    label=Label(
        text="Shutter\n<i>Thorlabs SH05/M</i>", 
        pos=(-20,-25),
        markup=true
    )
)

beampath = BeamPath(
    BeamPathAttributes(linewidth=3), 
    [
        Source(pos=(200, 100)),
        Mirror(pos=(300, 100), rot=-45),
        # ND Filter Wheel
        Filter(
            pos=(300, 325),
            label=Label(
                text="ND Filter Wheel",
            ),
            rot=90,
        ),
        BeamPath([
            Component(pos=(295, 175), label=Label(text="Beam Block\n<span font='8'>(for reflection from\nND filter wheel)</span>", markup=true)),
        ]),
        # MOTOR
        BeamPath(
            BeamPathAttributes(linewidth=0.0),
            [
                Component(
                    pos=(260, 325),
                    label=Label(
                        text="Motor",
                        pos=(-70, 0)
                    )
                )
            ]
        ),
        Mirror(pos=(300, 375), rot=-45),
        Aperture(pos=(400, 375)),
        Filter(
            pos=(435, 375),
            rot=45,
            label=Label(
                text="""Beamsplitter
                (~33 % passes)
                """
            )
        ),
        BeamPath([
            Filter(pos=(435,280), rot=90, label=Label(text="OD 0.3")),
            Filter(pos=(435,265), rot=90, label=Label(text="OD 0.2")),
            Filter(pos=(435,250), rot=90, label=Label(text="OD 0.1")),
            Lens(pos=(435, 200), focallength=150, rot=90),
            Component(pos=(435, 100), label=Label(text="Power Meter\n<i>Ophir</i>", markup=true)),
        ]),
        Aperture(pos=(600, 375)),
        shutter,
        Lens(pos=(700, 375), focallength=150),
        Mirror(pos=(800,375), rot=0, label=Label(pos=(-50,60), text="mirror directing the\nbeam straight down")),
        Component(
            pos=(850, 375),
            label=Label(text="E-Cell"),
        ),
    ]
)

render(joinpath(@__DIR__, "testpath.svg"), beampath; margin=100)