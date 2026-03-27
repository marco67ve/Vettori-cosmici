' VC_qb64.BAS
' Vettori cosmici fra un secondo e una settimana rispetto alla CMBR
' Marco da Venezia, rev. 2008 per QB64 (da VC.BAS per QB 4.5)

DECLARE SUB SunEclipticLongitude (jd#, lambdaDeg!)
DECLARE SUB EclipticToEquatorial (lambdaDeg!, betaDeg!, arDeg!, decDeg!)
DECLARE FUNCTION JulianDay# (year%, month%, day%, hour!, minute!, second!)
DECLARE SUB SiderealTime (jd#, lon!, gst!, lst!)
DECLARE SUB ARDecToVector (arDeg!, decDeg!, speed!, vx!, vy!, vz!)
DECLARE SUB GalacticToEquatorial (lDeg!, bDeg!, arDeg!, decDeg!)
DECLARE SUB DrawVector (cx!, cy!, vx!, vy!, colore%, scale!)

Print
Input "Inserisci un tempo tra 1 e 604800 secondi (default = 1):"; t!
If t! < 1 Or t! > 604800 Then t! = 1
Input "Latitudine (in gradi, da -90 a +90): "; lat!
If lat! < -90 Or lat! > 90 Then lat! = 0
Input "Longitudine (in gradi, da -180 a +180): "; lon!
If lon! < -180 Or lon! > 180 Then lon! = 0


yDisplay = _DesktopHeight - 32
xDisplay = yDisplay * 16 / 9
Screen _NewImage(xDisplay, yDisplay, 256)
_ScreenMove 0, 0

' Centro dello schermo = nostra posizione "ora" a qualsiasi latitudine
cx = xDisplay / 2
cy = yDisplay / 2


' --- ROTAZIONE TERRESTRE REALISTICA ---

' Velocita' all'equatore (km/s)
vEquator! = 0.465

' Modulo reale alla latitudine scelta
v1! = vEquator! * Cos(lat! * _Pi / 180!)

' Data e ora del PC
year% = Val(Left$(Date$, 4))
month% = Val(Mid$(Date$, 6, 2))
day% = Val(Right$(Date$, 2))

hour! = Val(Left$(Time$, 2))
minute! = Val(Mid$(Time$, 4, 2))
second! = Val(Right$(Time$, 2))

' Giorno giuliano
jd# = JulianDay#(year%, month%, day%, hour!, minute!, second!)

' Tempo siderale
Call SiderealTime(jd#, lon!, gst!, lst!)

' Direzione della velocita' di rotazione (gradi)
' AR = LST + 90, Dec = 0
arRot! = lst! + 90!
If arRot! >= 360! Then arRot! = arRot! - 360!

decRot! = 0!

' Converti in vettore 3D
Call ARDecToVector(arRot!, decRot!, v1!, vx1!, vy1!, vz1!)


' --- ORBITA TERRESTRE REALISTICA ---

' Velocita' orbitale media (km/s)
v2! = 29.78

' Longitudine eclittica del Sole (lambda, in gradi)
Call SunEclipticLongitude(jd#, lambdaSun!)

' La Terra e' in opposizione al Sole: long. Terra = lambdaSun + 180
lambdaEarth! = lambdaSun! + 180!
If lambdaEarth! >= 360! Then lambdaEarth! = lambdaEarth! - 360!

' La velocita' e' tangente all'orbita: direzione = lambdaEarth + 90
lambdaVel! = lambdaEarth! + 90!
If lambdaVel! >= 360! Then lambdaVel! = lambdaVel! - 360!

' Beta = 0 (orbita nel piano eclittico)
betaVel! = 0!

' Converte (lambda, beta) eclittiche -> (AR,Dec) equatoriali
Call EclipticToEquatorial(lambdaVel!, betaVel!, arOrb!, decOrb!)

' Converte (AR,Dec, velocita') in vettore 3D
Call ARDecToVector(arOrb!, decOrb!, v2!, vx2!, vy2!, vz2!)


' --- MOTO DEL SOLE NELLA VIA LATTEA (APEX SOLARE) ---

' Direzione reale dell'Apex solare
arApex! = 270! ' 18h
decApex! = 30!

' Velocita' del Sole nella Via Lattea (km/s)
v3! = 217

' Converti in vettore 3D
Call ARDecToVector(arApex!, decApex!, v3!, vx3!, vy3!, vz3!)


' --- GRANDE ATTRATTORE CON COORDINATE REALI ---

lGA! = 307! ' longitudine galattica in gradi
bGA! = 9! ' latitudine galattica in gradi


' Converte galattiche -> equatoriali
Call GalacticToEquatorial(lGA!, bGA!, arGA!, decGA!)

' Velocita' verso il Grande Attrattore
v4! = 610

' Converte (AR,Dec, velocita') in vettore 3D
Call ARDecToVector(arGA!, decGA!, v4!, vx4!, vy4!, vz4!)


' --- RISULTANTE 3D ---

vxt! = vx1! + vx2! + vx3! + vx4!
vyt! = vy1! + vy2! + vy3! + vy4!
vzt! = vz1! + vz2! + vz3! + vz4!
vR! = Sqr(vxt! * vxt! + vyt! * vyt! + vzt! * vzt!)


' --- SCALA DINAMICA BASATA SUL GRANDE ATTRATTORE ---

' Modulo del vettore GA nel piano XY
modGA! = Sqr(vx4! * vx4! + vy4! * vy4!)

' Scala tale che il GA arrivi fino al bordo verticale
scale! = cy / modGA!


' --- DISEGNO DELLA TERRA CON CENTRO SPOSTATO SU Y PER METTERE IL PUNTO DI LATITUDINE AL CENTRO DEL DISPLAY ---
earthRadiusKm! = 6371!
earthRadiusPx! = earthRadiusKm! * scale! / t!

' Calcolo del centro verticale della Terra
latRad! = lat! * _Pi / 180
cyTerra! = cy + Sin(latRad!) * earthRadiusPx!

' Disegno della Terra
Circle (cx, cyTerra!), earthRadiusPx!, 1
Paint (cx, cyTerra!), _RGB(8, 16, 32), 1

' Equatore terrestre
Line (cx - earthRadiusPx!, cyTerra)-(cx + earthRadiusPx!, cyTerra), 1


' --- DISEGNO LUNA E SOLE SULL'ASSE DELL'EQUATORE TERRESTRE ---

' Raggi rispetto alla Terra
rLuna! = earthRadiusPx! / 3.66
rSole! = earthRadiusPx! * 109!

' Distanze in raggi terrestri
moonDistRe! = 60! ' Luna a ~60 R_terra
sunDistRe! = 23455! ' Sole a ~23455 R_terra (1 UA)

' Distanze in pixel
moonDistPx! = earthRadiusPx! * moonDistRe!
sunDistPx! = earthRadiusPx! * sunDistRe!

' Posizioni lungo l'equatore terrestre (asse orizzontale)
xLuna! = cx + moonDistPx!
yLuna! = cyTerra!

xSole = cx + sunDistPx!
ySole = cyTerra!

' Disegno Luna e Sole in scala 10x
Circle (xLuna!, yLuna!), 10 * rLuna!, 7 ' grigio/bianco
Circle (xSole, ySole), 10 * rSole!, 14 ' giallo


' --- DISEGNO MERCURIO, VENERE e MARTE SULL'ASSE DELL'EQUATORE TERRESTRE ---

' Raggi rispetto alla Terra
rMercurio! = earthRadiusPx! * 0.383
rVenere! = earthRadiusPx! * 0.949
rMarte! = earthRadiusPx! * 0.532

' Distanze medie in AU
mercuryAU! = 0.387 * sunDistPx!
venusAU! = 0.723 * sunDistPx!
marsAU! = 1.524 * sunDistPx!

' Posizioni lungo l'equatore terrestre (asse orizzontale)
xMercurio! = xSole - mercuryAU!
yMercurio! = cyTerra!
xVenere! = xSole - venusAU!
yVenere! = cyTerra!
xMarte! = xSole - marsAU!
yMarte! = cyTerra!

' Disegno pianeti in scala 100x
Circle (xMercurio!, yMercurio!), 100 * rMercurio!, 6 ' Mercurio (giallo scuro)
Circle (xVenere!, yVenere!), 100 * rVenere!, 15 ' Venere (bianco chiaro)
Circle (xMarte!, yMarte!), 100 * rMarte!, 12 ' Marte (rosso chiaro)


' DISEGNO DEI VETTORI
DrawVector cx, cy, vx1!, vy1!, 10, 50 * scale! ' rotazione in scala 50x
DrawVector cx, cy, vx2!, vy2!, 11, scale! ' orbita
DrawVector cx, cy, vx3!, vy3!, 12, scale! ' Via Lattea
DrawVector cx, cy, vx4!, vy4!, 13, scale! ' Grande Attrattore
DrawVector cx, cy, vxt!, vyt!, 14, scale! ' Risultante

' --- LEGENDA ---

mod1 = v1! * t!
mod2 = v2! * t!
mod3 = v3! * t!
mod4 = v4! * t!
modR = vR! * t!

Color 15: Locate 1, 1: Print "Terra con vettori cosmici relativi alla nostra posizione fra un secondo e una settimana"

Color 2: Locate 3, 1: Print Using "Verde   = Rotazione terrestre:     #.###        ######.###"; v1!; mod1!
Color 3: Locate 4, 1: Print Using "Ciano   = Orbita terrestre:       ##.##       ########.###"; v2!; mod2!
Color 4: Locate 5, 1: Print Using "Rosso   = Moto nella Via Lattea: ###         #########    "; v3!; mod3!
Color 5: Locate 6, 1: Print Using "Magenta = Grande Attrattore:     ###         #########    "; v4!; mod4!
Color 14: Locate 7, 1: Print Using "Giallo  = Risultante:            ###.###     #########.###"; vR!; modR!

' Ascensione retta (in gradi)
arRes! = _Atan2(vyt!, vxt!) * 180! / _Pi
If arRes! < 0! Then arRes! = arRes! + 360!
' Declinazione
decRes! = Atn(vzt! / Sqr(vxt! * vxt! + vyt! * vyt!)) * 180! / _Pi

' --- COORDINATE COSMICHE ATTUALI ---

' Rotazione terrestre
ar1! = _Atan2(vy1!, vx1!) * 180! / _Pi
If ar1! < 0! Then ar1! = ar1! + 360!
dec1! = Atn(vz1! / Sqr(vx1! * vx1! + vy1! * vy1!)) * 180! / _Pi

' Orbita terrestre
ar2! = _Atan2(vy2!, vx2!) * 180! / _Pi
If ar2! < 0! Then ar2! = ar2! + 360!
dec2! = Atn(vz2! / Sqr(vx2! * vx2! + vy2! * vy2!)) * 180! / _Pi

' Moto nella Via Lattea
ar3! = _Atan2(vy3!, vx3!) * 180! / _Pi
If ar3! < 0! Then ar3! = ar3! + 360!
dec3! = Atn(vz3! / Sqr(vx3! * vx3! + vy3! * vy3!)) * 180! / _Pi

' Grande Attrattore
ar4! = _Atan2(vy4!, vx4!) * 180! / _Pi
If ar4! < 0! Then ar4! = ar4! + 360!
dec4! = Atn(vz4! / Sqr(vx4! * vx4! + vy4! * vy4!)) * 180! / _Pi

Color 15: Locate 9, 1: Print "Coordinate cosmiche attuali (gradi)"
Color 2: Locate 11, 1: Print Using "AR rotazione:  ###.##   Dec: ###.##"; ar1!; dec1!
Color 3: Locate 12, 1: Print Using "AR orbita:     ###.##   Dec: ###.##"; ar2!; dec2!
Color 4: Locate 13, 1: Print Using "AR galattico:  ###.##   Dec: ###.##"; ar3!; dec3!
Color 5: Locate 14, 1: Print Using "AR attrattore: ###.##   Dec: ###.##"; ar4!; dec4!
Color 14: Locate 15, 1: Print Using "AR risultante: ###.##   Dec: ###.##"; arRes!; decRes!

Color 15
Locate 17, 1: Print "Data: "; Date$
Locate 18, 1: Print "Ora:  "; Time$
Locate 19, 1: Print "Secondi:"; t!
Locate 20, 1: Print "Latitudine: "; lat!
Locate 21, 1: Print "Longitudine:"; lon!

Sleep
End


Sub EclipticToEquatorial (lambdaDeg!, betaDeg!, arDeg!, decDeg!)
    Dim eps#, lambda#, beta#
    Dim x#, y#, z#, xe#, ye#, ze#
    Dim arRad#, decRad#

    ' Obliquita' dell'eclittica (gradi)
    eps# = 23.4392911#

    ' In radianti
    lambda# = lambdaDeg! * _Pi / 180#
    beta# = betaDeg! * _Pi / 180#
    eps# = eps# * _Pi / 180#

    ' Coordinate cartesiane nel sistema eclittico
    x# = Cos(beta#) * Cos(lambda#)
    y# = Cos(beta#) * Sin(lambda#)
    z# = Sin(beta#)

    ' Rotazione di eps attorno all'asse X: eclittico -> equatoriale
    xe# = x#
    ye# = y# * Cos(eps#) - z# * Sin(eps#)
    ze# = y# * Sin(eps#) + z# * Cos(eps#)

    ' AR e Dec
    arRad# = _Atan2(ye#, xe#)
    If arRad# < 0# Then arRad# = arRad# + 2# * _Pi

    decRad# = Atn(ze# / Sqr(xe# * xe# + ye# * ye#))

    arDeg! = arRad# * 180# / _Pi
    decDeg! = decRad# * 180# / _Pi
End Sub

Sub SunEclipticLongitude (jd#, lambdaDeg!)
    Dim T#, M#, L0#, C#, lambda#

    ' Secoli giuliani dal J2000
    T# = (jd# - 2451545#) / 36525#

    ' Longitudine media del Sole (gradi)
    L0# = 280.46646# + 36000.76983# * T# + 0.0003032# * T# * T#

    ' Anomalia media (gradi)
    M# = 357.52911# + 35999.05029# * T# - 0.0001537# * T# * T#

    ' Normalizza M in 0–360
    M# = M# - Int(M# / 360#) * 360#
    If M# < 0# Then M# = M# + 360#

    ' Equazione del centro (gradi)
    C# = (1.914602# - 0.004817# * T# - 0.000014# * T# * T#) * SIN(M# * _Pi / 180#) _
       + (0.019993# - 0.000101# * T#) * SIN(2# * M# * _Pi / 180#) _
       + 0.000289# * SIN(3# * M# * _Pi / 180#)

    ' Longitudine eclittica apparente del Sole (gradi)
    lambda# = L0# + C#

    ' Normalizza 0–360
    lambda# = lambda# - Int(lambda# / 360#) * 360#
    If lambda# < 0# Then lambda# = lambda# + 360#

    lambdaDeg! = lambda#
End Sub

Function JulianDay# (year%, month%, day%, hour!, minute!, second!)
    Dim y%, m%
    Dim a%, b%
    Dim jd#

    y% = year%
    m% = month%

    If m% <= 2 Then
        y% = y% - 1
        m% = m% + 12
    End If

    a% = y% \ 100
    b% = 2 - a% + (a% \ 4)

    jd# = Int(365.25 * (y% + 4716)) + Int(30.6001 * (m% + 1)) + day% + b% - 1524.5
    jd# = jd# + (hour! + minute! / 60! + second! / 3600!) / 24!

    JulianDay# = jd#
End Function

Sub SiderealTime (jd#, lon!, gst!, lst!)
    Dim T#, theta#

    ' Secoli giuliani dal J2000
    T# = (jd# - 2451545#) / 36525#

    ' Greenwich Mean Sidereal Time (in gradi)
    theta# = 280.46061837# + 360.98564736629# * (jd# - 2451545#) + 0.000387933# * T# * T# - T# * T# * T# / 38710000#

    ' Normalizza 0–360
    gst! = theta# - Int(theta# / 360#) * 360#
    If gst! < 0! Then gst! = gst! + 360!

    ' Local Sidereal Time
    lst! = gst! + lon!
    If lst! >= 360! Then lst! = lst! - 360!
    If lst! < 0! Then lst! = lst! + 360!
End Sub

Sub DrawVector (cx, cy, vx!, vy!, colore%, scale!)
    ' Sub per disegnare un vettore usando linea e freccia
    x2! = cx + vx! * scale!
    y2! = cy - vy! * scale! ' meno in quanto Y aumenta verso il basso

    If colore% = 10 Then stile = &B0101010101010101 Else stile = &B1111111111111111 ' tratteggiato solo per rotazione terrestre
    Line (cx!, cy!)-(x2!, y2!), colore%, , stile

    ' piccola freccia in punta
    dx! = x2! - cx
    dy! = y2! - cy
    L! = Sqr(dx! * dx! + dy! * dy!)
    If L! > 0 Then
        ux! = dx! / L!
        uy! = dy! / L!
        ' due segmentini laterali
        ax1! = x2! - 10 * ux! + 5 * uy!
        ay1! = y2! - 10 * uy! - 5 * ux!
        ax2! = x2! - 10 * ux! - 5 * uy!
        ay2! = y2! - 10 * uy! + 5 * ux!
        Line (x2!, y2!)-(ax1!, ay1!), colore%
        Line (x2!, y2!)-(ax2!, ay2!), colore%
    End If
End Sub

Sub ARDecToVector (arDeg!, decDeg!, speed!, vx!, vy!, vz!)
    arRad! = arDeg! * _Pi / 180!
    decRad! = decDeg! * _Pi / 180!

    ' Versore nella direzione (AR, Dec)
    cx! = Cos(decRad!) * Cos(arRad!)
    cy! = Cos(decRad!) * Sin(arRad!)
    cz! = Sin(decRad!)

    ' Scala col modulo (km/s)
    vx! = speed! * cx!
    vy! = speed! * cy!
    vz! = speed! * cz!
End Sub

Sub GalacticToEquatorial (lDeg!, bDeg!, arDeg!, decDeg!)
    Dim M(1 To 3, 1 To 3) As Double
    Dim vg(1 To 3) As Double
    Dim ve(1 To 3) As Double

    ' Matrice galattico -> equatoriale (J2000)
    ' Fonte: standard IAU, valori in doppia precisione
    M(1, 1) = -0.0548755604#: M(1, 2) = -0.8734370902#: M(1, 3) = -0.4838350155#
    M(2, 1) = 0.4941094279#: M(2, 2) = -0.4448296300#: M(2, 3) = 0.7469822445#
    M(3, 1) = -0.8676661490#: M(3, 2) = -0.1980763734#: M(3, 3) = 0.4559837762#

    ' Converte l,b in radianti
    lRad# = lDeg! * _Pi / 180#
    bRad# = bDeg! * _Pi / 180#

    ' Versore galattico
    vg(1) = Cos(bRad#) * Cos(lRad#)
    vg(2) = Cos(bRad#) * Sin(lRad#)
    vg(3) = Sin(bRad#)

    ' Moltiplicazione matrice M * vg = ve (versore equatoriale)
    For i% = 1 To 3
        ve(i%) = 0#
        For j% = 1 To 3
            ve(i%) = ve(i%) + M(i%, j%) * vg(j%)
        Next j%
    Next i%

    ' Da versore equatoriale a (AR, Dec)
    x# = ve(1)
    y# = ve(2)
    z# = ve(3)

    ' AR
    arRad# = _Atan2(y#, x#)
    If arRad# < 0# Then arRad# = arRad# + 2# * _Pi

    ' Dec
    decRad# = Atn(z# / Sqr(x# * x# + y# * y#))

    ' Conversione in gradi
    arDeg! = arRad# * 180# / _Pi
    decDeg! = decRad# * 180# / _Pi
End Sub


