from pyspinw import *

unit_cell = UnitCell(1, 1, 1)

# define a spin in z direction
only_site = LatticeSite(0, 0, 0, 0, 0, -1, name="X")

s = Structure([only_site], unit_cell=unit_cell)

view(s)
