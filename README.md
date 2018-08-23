# LightPath

---TECHNICAL PROJECT SETUP---


Hardware wiring:

Sensors  --(XLR cable)-->  Sensor controllers  --(ethernet cable)-->  PoE Switch  --(ethernet cable)-->  Router  --(ethernet cable)-->  Mac


Software "wiring":

Sensor controllers --(UDP)--> Processing --(OSC)--> MaxMSP --(Syphon)--> MadMapper



--------MAX/MSP SETUP------------

Download CNMAT externals (OSC objects for MAX/MSP) og Syphon (for jitter) packages:

CNMAT: http://cnmat.berkeley.edu/downloads
SYPHON: https://github.com/Syphon/Jitter/releases/

Place the downloaded folders in your MAX/MSP Packages folder
