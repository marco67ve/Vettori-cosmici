' VC1.BAS
' Vettori cosmici fra un secondo e una settimana rispetto alla CMBR
' Per QuickBASIC con VGA
' By Marco da Venezia, 1991

DECLARE FUNCTION Atan2 (y, x)
DECLARE SUB SunEclipticLongitude (jd, lambdaDeg)
DECLARE SUB EclipticToEquatorial (lambdaDeg, betaDeg, arDeg, decDeg)
DECLARE FUNCTION JulianDay (year, month, day, hour, minute, second)
DECLARE SUB SiderealTime (jd, lon, gst, lst)
DECLARE SUB ARDecToVector (arDeg, decDeg, speed, vx, vy, vz)
DECLARE SUB GalacticToEquatorial (lDeg, bDeg, arDeg, decDeg)
DECLARE SUB DrawVector (cx, cy, vx, vy, colore, scale)

CONST Pi = 3.141593

PRINT
INPUT "Inserisci un tempo tra 1 e 604800 secondi (default = 1):"; T
IF T < 1 OR T > 604800 THEN T = 1
INPUT "Latitudine (in gradi, da -90 a +90): "; lat
IF lat < -90 OR lat > 90 THEN lat = 0
INPUT "Longitudine (in gradi, da -180 a +180): "; lon
IF lon < -180 OR lon > 180 THEN lon = 0

SCREEN 12 ' VGA (9 se EGA)

' Centro dello schermo = nostra posizione "ora" a qualsiasi latitudine
cx = 320
cy = 240 ' (175 se EGA)


' --- ROTAZIONE TERRESTRE REALISTICA ---

' Velocita' all'equatore (km/s)
vEquator = .465

' Modulo reale alla latitudine scelta
v1 = vEquator * COS(lat * Pi / 180)

' Data e ora del PC
year = VAL(LEFT$(DATE$, 4))
month = VAL(MID$(DATE$, 6, 2))
day = VAL(RIGHT$(DATE$, 2))

hour = VAL(LEFT$(TIME$, 2))
minute = VAL(MID$(TIME$, 4, 2))
second = VAL(RIGHT$(TIME$, 2))

' Giorno giuliano
jd = JulianDay(year, month, day, hour, minute, second)

' Tempo siderale
CALL SiderealTime(jd, lon, gst, lst)

' Direzione della velocita' di rotazione (gradi)
' AR = LST + 90, Dec = 0
arRot = lst + 90
IF arRot >= 360 THEN arRot = arRot - 360

decRot = 0

' Converti in vettore 3D
CALL ARDecToVector(arRot, decRot, v1, vx1, vy1, vz1)


' --- ORBITA TERRESTRE REALISTICA ---

' Velocita' orbitale media (km/s)
v2 = 29.78

' Longitudine eclittica del Sole (lambda, in gradi)
CALL SunEclipticLongitude(jd, lambdaSun)

' La Terra e' in opposizione al Sole: long. Terra = lambdaSun + 180
lambdaEarth = lambdaSun + 180
IF lambdaEarth >= 360 THEN lambdaEarth = lambdaEarth - 360

' La velocita' e' tangente all'orbita: direzione = lambdaEarth + 90
lambdaVel = lambdaEarth + 90
IF lambdaVel >= 360 THEN lambdaVel = lambdaVel - 360

' Beta = 0 (orbita nel piano eclittico)
betaVel = 0

' Converte (lambda, beta) eclittiche -> (AR,Dec) equatoriali
CALL EclipticToEquatorial(lambdaVel, betaVel, arOrb, decOrb)

' Converte (AR,Dec, velocita') in vettore 3D
CALL ARDecToVector(arOrb, decOrb, v2, vx2, vy2, vz2)


' --- MOTO DEL SOLE NELLA VIA LATTEA (APEX SOLARE) ---

' Direzione reale dell'Apex solare
arApex = 270 ' 18h
decApex = 30

' Velocita' del Sole nella Via Lattea (km/s)
v3 = 217

' Converti in vettore 3D
CALL ARDecToVector(arApex, decApex, v3, vx3, vy3, vz3)


' --- GRANDE ATTRATTORE CON COORDINATE REALI ---

lGA = 307 ' longitudine galattica in gradi
bGA = 9 ' latitudine galattica in gradi


' Converte galattiche -> equatoriali
CALL GalacticToEquatorial(lGA, bGA, arGA, decGA)

' Velocita' verso il Grande Attrattore
v4 = 610

' Converte (AR, Dec, velocita') in vettore 3D
CALL ARDecToVector(arGA, decGA, v4, vx4, vy4, vz4)


' --- RISULTANTE 3D ---

vxt = vx1 + vx2 + vx3 + vx4
vyt = vy1 + vy2 + vy3 + vy4
vzt = vz1 + vz2 + vz3 + vz4
vR = SQR(vxt * vxt + vyt * vyt + vzt * vzt)


' --- SCALA DINAMICA BASATA SUL GRANDE ATTRATTORE ---

' Modulo del vettore GA nel piano XY
modGA = SQR(vx4 * vx4 + vy4 * vy4)

' Scala tale che il GA arrivi fino al bordo verticale
scale = cy / modGA


' --- DISEGNO DELLA TERRA CON CENTRO SPOSTATO SU Y PER METTERE IL PUNTO DI LATITUDINE AL CENTRO DEL DISPLAY ---
earthRadiusKm = 6371
earthRadiusPx = earthRadiusKm * scale / T

' Calcolo del centro verticale della Terra
latRad = lat * Pi / 180
cyTerra = cy + SIN(latRad) * earthRadiusPx

' Disegno della Terra
CIRCLE (cx, cyTerra), earthRadiusPx, 1
PAINT (cx, cyTerra), 8, 1

' Equatore terrestre
LINE (cx - earthRadiusPx, cyTerra)-(cx + earthRadiusPx, cyTerra), 1


' --- DISEGNO LUNA E SOLE SULL'ASSE DELL'EQUATORE TERRESTRE ---

' Raggi rispetto alla Terra
rLuna = earthRadiusPx / 3.66
' rSole = earthRadiusPx * 109 ' non rappresentabile, imposteremo 10

' Distanze in raggi terrestri
moonDistRe = 60 ' Luna a ~60 R.terra
sunDistRe = 23455 ' Sole a ~23455 R.terra (1 UA)

' Distanze in pixel
moonDistPx = earthRadiusPx * moonDistRe
sunDistPx = earthRadiusPx * sunDistRe

' Posizioni lungo l'equatore terrestre (asse orizzontale)
xLuna = cx + moonDistPx
yLuna = cyTerra

xSole = cx + sunDistPx
ySole = cyTerra

' Disegno Luna e Sole
CIRCLE (xLuna, yLuna), rLuna, 7  ' grigio/bianco
CIRCLE (xSole, ySole), 10, 14 ' giallo


' --- DISEGNO MERCURIO, VENERE e MARTE SULL'ASSE DELL'EQUATORE TERRESTRE ---

' Raggi rispetto alla Terra
rMercurio = earthRadiusPx * .383
rVenere = earthRadiusPx * .949
rMarte = earthRadiusPx * .532

' Distanze medie in AU
mercuryAU = .387 * sunDistPx
venusAU = .723 * sunDistPx
marsAU = 1.524 * sunDistPx

' Posizioni lungo l'equatore terrestre (asse orizzontale)
xMercurio = xSole - mercuryAU
yMercurio = cyTerra
xVenere = xSole - venusAU
yVenere = cyTerra
xMarte = xSole - marsAU
yMarte = cyTerra

' Disegno pianeti
CIRCLE (xMercurio, yMercurio), rMercurio, 6  ' Mercurio (giallo scuro)
CIRCLE (xVenere, yVenere), rVenere, 15  ' Venere (bianco chiaro)
CIRCLE (xMarte, yMarte), rMarte, 12  ' Marte (rosso chiaro)


' DISEGNO DEI VETTORI
DrawVector cx, cy, vx1, vy1, 10, 50 * scale ' rotazione in scala 50x
DrawVector cx, cy, vx2, vy2, 11, scale ' orbita
DrawVector cx, cy, vx3, vy3, 12, scale ' Via Lattea
DrawVector cx, cy, vx4, vy4, 13, scale ' Grande Attrattore
DrawVector cx, cy, vxt, vyt, 14, scale ' Risultante

' --- LEGENDA ---

mod1 = v1 * T
mod2 = v2 * T
mod3 = v3 * T
mod4 = v4 * T
modR = vR * T

COLOR 15: LOCATE 1, 1: PRINT "Vettori cosmici relativi alla nostra posizione fra un secondo e una settimana"

COLOR 2: LOCATE 3, 1:  PRINT USING "Verde   = Rotazione:    #.###     ######.###"; v1; mod1
COLOR 3: LOCATE 4, 1:  PRINT USING "Ciano   = Orbita:      ##.##    ########.###"; v2; mod2
COLOR 4: LOCATE 5, 1:  PRINT USING "Rosso   = Via Lattea: ###      #########    "; v3; mod3
COLOR 5: LOCATE 6, 1:  PRINT USING "Magenta = Attrattore: ###      #########    "; v4; mod4
COLOR 14: LOCATE 7, 1: PRINT USING "Giallo  = Risultante: ###.###  #########.###"; vR; modR

' Ascensione retta (in gradi)
arRes = Atan2(vyt, vxt) * 180 / Pi
IF arRes < 0 THEN arRes = arRes + 360
' Declinazione
decRes = ATN(vzt / SQR(vxt * vxt + vyt * vyt)) * 180 / Pi

' --- COORDINATE COSMICHE ATTUALI ---

' Rotazione terrestre
ar1 = Atan2(vy1, vx1) * 180 / Pi
IF ar1 < 0 THEN ar1 = ar1 + 360
dec1 = ATN(vz1 / SQR(vx1 * vx1 + vy1 * vy1)) * 180 / Pi

' Orbita terrestre
ar2 = Atan2(vy2, vx2) * 180 / Pi
IF ar2 < 0 THEN ar2 = ar2 + 360
dec2 = ATN(vz2 / SQR(vx2 * vx2 + vy2 * vy2)) * 180 / Pi

' Moto nella Via Lattea
ar3 = Atan2(vy3, vx3) * 180 / Pi
IF ar3 < 0 THEN ar3 = ar3 + 360
dec3 = ATN(vz3 / SQR(vx3 * vx3 + vy3 * vy3)) * 180 / Pi

' Grande Attrattore
ar4 = Atan2(vy4, vx4) * 180 / Pi
IF ar4 < 0 THEN ar4 = ar4 + 360
dec4 = ATN(vz4 / SQR(vx4 * vx4 + vy4 * vy4)) * 180 / Pi

COLOR 15: LOCATE 9, 1:  PRINT "Coordinate cosmiche attuali (gradi)"
COLOR 2: LOCATE 11, 1:  PRINT USING "AR rotazione:  ###.##  Dec: ###.##"; ar1; dec1
COLOR 3: LOCATE 12, 1:  PRINT USING "AR orbita:     ###.##  Dec: ###.##"; ar2; dec2
COLOR 4: LOCATE 13, 1:  PRINT USING "AR galattico:  ###.##  Dec: ###.##"; ar3; dec3
COLOR 5: LOCATE 14, 1:  PRINT USING "AR attrattore: ###.##  Dec: ###.##"; ar4; dec4
COLOR 14: LOCATE 15, 1: PRINT USING "AR risultante: ###.##  Dec: ###.##"; arRes; decRes

COLOR 15
LOCATE 17, 1: PRINT "Data: "; DATE$
LOCATE 18, 1: PRINT "Ora:  "; TIME$
LOCATE 19, 1: PRINT USING "Secondi: ######"; T
LOCATE 20, 1: PRINT USING "Latitudine:  ###.####"; lat
LOCATE 21, 1: PRINT USING "Longitudine: ###.####"; lon

SLEEP
END

'
SUB ARDecToVector (arDeg, decDeg, speed, vx, vy, vz)
    arRad = arDeg * Pi / 180
    decRad = decDeg * Pi / 180

    ' Versore nella direzione (AR, Dec)
    cx = COS(decRad) * COS(arRad)
    cy = COS(decRad) * SIN(arRad)
    cz = SIN(decRad)

    ' Scala col modulo (km/s)
    vx = speed * cx
    vy = speed * cy
    vz = speed * cz
END SUB

'
FUNCTION Atan2 (y, x)
    IF x > 0 THEN
        Atan2 = ATN(y / x)
    ELSEIF x < 0 THEN
        IF y >= 0 THEN Atan2 = ATN(y / x) + Pi ELSE Atan2 = ATN(y / x) - Pi
    ELSE ' x zero
        IF y > 0 THEN
            Atan2 = Pi / 2
        ELSEIF y < 0 THEN
            Atan2 = -Pi / 2
        ELSE
            Atan2 = 0
        END IF
    END IF
END FUNCTION

'
SUB DrawVector (cx, cy, vx, vy, colore, scale)
    ' Sub per disegnare un vettore usando linea e freccia
    x2 = cx + vx * scale
    y2 = cy - vy * scale ' meno in quanto Y aumenta verso il basso

    IF colore = 10 THEN stile = &HFCFC ELSE stile = &HFFFF ' tratteggiato solo per rotazione terrestre
    LINE (cx, cy)-(x2, y2), colore, , stile

    ' piccola freccia in punta
    dx = x2 - cx
    dy = y2 - cy
    L = SQR(dx * dx + dy * dy)
    IF L > 0 THEN
        ux = dx / L
        uy = dy / L
        ' due segmentini laterali
        ax1 = x2 - 10 * ux + 5 * uy
        ay1 = y2 - 10 * uy - 5 * ux
        ax2 = x2 - 10 * ux - 5 * uy
        ay2 = y2 - 10 * uy + 5 * ux
        LINE (x2, y2)-(ax1, ay1), colore
        LINE (x2, y2)-(ax2, ay2), colore
    END IF
END SUB

'
SUB EclipticToEquatorial (lambdaDeg, betaDeg, arDeg, decDeg)
    DIM eps, lambda, beta
    DIM x, y, z, xe, ye, ze
    DIM arRad, decRad

    ' Obliquita' dell'eclittica (gradi)
    eps = 23.43929

    ' In radianti
    lambda = lambdaDeg * Pi / 180
    beta = betaDeg * Pi / 180
    eps = eps * Pi / 180

    ' Coordinate cartesiane nel sistema eclittico
    x = COS(beta) * COS(lambda)
    y = COS(beta) * SIN(lambda)
    z = SIN(beta)

    ' Rotazione di eps attorno all'asse X: eclittico -> equatoriale
    xe = x
    ye = y * COS(eps) - z * SIN(eps)
    ze = y * SIN(eps) + z * COS(eps)

    ' AR e Dec
    arRad = Atan2(ye, xe)
    IF arRad < 0 THEN arRad = arRad + 2 * Pi

    decRad = ATN(ze / SQR(xe * xe + ye * ye))

    arDeg = arRad * 180 / Pi
    decDeg = decRad * 180 / Pi
END SUB

'
SUB GalacticToEquatorial (lDeg, bDeg, arDeg, decDeg)
    DIM M(1 TO 3, 1 TO 3)
    DIM vg(1 TO 3)
    DIM ve(1 TO 3)

    ' Matrice galattico -> equatoriale (J2000)
    ' Fonte: standard IAU, valori in doppia precisione
    M(1, 1) = -.0548756: M(1, 2) = -.8734371: M(1, 3) = -.483835
    M(2, 1) = .4941094: M(2, 2) = -.4448296: M(2, 3) = .7469822
    M(3, 1) = -.8676661: M(3, 2) = -.1980764: M(3, 3) = .4559838

    ' Converte l,b in radianti
    lRad = lDeg * Pi / 180
    bRad = bDeg * Pi / 180

    ' Versore galattico
    vg(1) = COS(bRad) * COS(lRad)
    vg(2) = COS(bRad) * SIN(lRad)
    vg(3) = SIN(bRad)

    ' Moltiplicazione matrice M * vg = ve (versore equatoriale)
    FOR i = 1 TO 3
        ve(i) = 0
        FOR j = 1 TO 3
            ve(i) = ve(i) + M(i, j) * vg(j)
        NEXT j
    NEXT i

    ' Da versore equatoriale a (AR, Dec)
    x = ve(1)
    y = ve(2)
    z = ve(3)

    ' AR
    arRad = Atan2(y, x)
    IF arRad < 0 THEN arRad = arRad + 2 * Pi

    ' Dec
    decRad = ATN(z / SQR(x * x + y * y))

    ' Conversione in gradi
    arDeg = arRad * 180 / Pi
    decDeg = decRad * 180 / Pi
END SUB

'
FUNCTION JulianDay (year, month, day, hour, minute, second)
    DIM y, M
    DIM a, b
    DIM jd

    y = year
    M = month

    IF M <= 2 THEN
        y = y - 1
        M = M + 12
    END IF

    a = y \ 100
    b = 2 - a + (a \ 4)

    jd = INT(365.25 * (y + 4716)) + INT(30.6001 * (M + 1)) + day + b - 1524.5
    jd = jd + (hour + minute / 60 + second / 3600) / 24

    JulianDay = jd
END FUNCTION

'
SUB SiderealTime (jd, lon, gst, lst)
    DIM T, theta

    ' Secoli giuliani dal J2000
    T = (jd - 2451545) / 36525

    ' Greenwich Mean Sidereal Time (in gradi)
    theta = 280.4606 + 360.9856 * (jd - 2451545) + .000388 * T * T - T * T * T / 38710000

    ' Normalizza 0–360
    gst = theta - INT(theta / 360) * 360
    IF gst < 0 THEN gst = gst + 360

    ' Local Sidereal Time
    lst = gst + lon
    IF lst >= 360 THEN lst = lst - 360
    IF lst < 0 THEN lst = lst + 360
END SUB

'
SUB SunEclipticLongitude (jd, lambdaDeg)
    DIM T, M, L0, C, lambda

    ' Secoli giuliani dal J2000
    T = (jd - 2451545) / 36525

    ' Longitudine media del Sole (gradi)
    L0 = 280.4665 + 36000.77 * T + .0003032 * T * T

    ' Anomalia media (gradi)
    M = 357.5291 + 35999.05 * T - .0001537 * T * T

    ' Normalizza M in 0–360
    M = M - INT(M / 360) * 360
    IF M < 0 THEN M = M + 360

    ' Equazione del centro (gradi)
    C = (1.914602 - .004817 * T - .000014 * T * T) * SIN(M * Pi / 180) + (.019993 - .000101 * T) * SIN(2 * M * Pi / 180) + .000289 * SIN(3 * M * Pi / 180)

    ' Longitudine eclittica apparente del Sole (gradi)
    lambda = L0 + C

    ' Normalizza 0–360
    lambda = lambda - INT(lambda / 360) * 360
    IF lambda < 0 THEN lambda = lambda + 360

    lambdaDeg = lambda
END SUB

