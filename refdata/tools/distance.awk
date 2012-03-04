#
# AWK script to calculate the distance between two geographical points.
# The data file should 
function pow (b, p) {
	return b^p
}

function azim (lat1, lon1, lat2, lon2) {
  M_PI = 4 * atan2 (1,1)
  rad = 180 / M_PI
  lat1 = $2 / rad
  lat2 = $4 / rad
  lon1 = $3 / rad
  lon2 = $5 / rad
  latdif = lat1 - lat2
  londif = lon1 - lon2
  meanlat = (lat1 + lat2)/2

  A = 2 * atan2 (londif * ((prcurt/mrcurt) * (cos(meanlat))), latdif)
  B = londif * (sin(meanlat))
  Az = (A-B)/2
  if (londif > 0 && latdif < 0) Az += M_PI
  if (londif < 0 && latdif < 0) Az += M_PI
  if (londif < 0 && latdif > 0) Az += 2*M_PI

  return Az*rad
}

#
BEGIN {
	M_PI = 4*atan2(1,1)
}

# Main
{
  rad = 180 / M_PI
  lat1 = $2 / rad
  lat2 = $4 / rad
  lon1 = $3 / rad
  lon2 = $5 / rad
  latdif = lat1 - lat2
  londif = lon1 - lon2
  meanlat = (lat1 + lat2)/2
  popularity = $6
  if (popularity == "") popularity = 1

  a = 6377276.345
  b = 6356075.4131
  e = sqrt ((a*a - b*b) / (a*a))
  mrcurt = ( a * (1 - (e*e))) / pow((1-((e*e) * pow(sin(meanlat),2))), 1.5)
  prcurt = a / sqrt (1-pow((e * sin(meanlat)), 2))
  distance = sqrt (pow(londif * prcurt * cos(meanlat), 2) + pow((latdif*mrcurt),2))

  printf ($1 "^%5.0f", distance/1000)
  printf ("^%9.0f", popularity)
  printf ("^%8.0f\n", popularity*distance/1000000)
}
