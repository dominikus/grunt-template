
haversine = (gpsLoc1,gpsLoc2) ->
	R = 6371.0 # earthradius in km
	dLat = (gpsLoc2.lat-gpsLoc1.lat) * Math.PI/180
	dLon = (gpsLoc2.lon-gpsLoc1.lon) * Math.PI/180
	lat1 = gpsLoc1.lat * Math.PI/180
	lat2 = gpsLoc2.lat * Math.PI/180

	a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2)
	c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
	d = R * c

	return d

sign = (x) ->
	return 1 if x > 0
	return -1 if x < 0
	return 0
