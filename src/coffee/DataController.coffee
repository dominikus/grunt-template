# DataController.coffee

dataPath = 'data'

$(window).on "app-ready", () ->

	parseLogData = (data) ->
		source = data.split("|")

		log = {
			provider: source[3]
			phone: source[4]
			lineName: source[5]
			from: source[6]
			to: source[7]
			logs: source.slice(8)
			firstStation: -1
			lastStation: -1
		}

		# detect direction and first and last stations
		currentTrackStations = window.app.data.trackStationNames[log.lineName]

		# find first station
		for station,i in currentTrackStations
			if station.stationName == log.from
				log.firstStation = i
				break

		# find last proper station entry (i.e., either ARRIVING or DEPARTING)
		allStationsInLogs = _.filter(
			log.logs
			,
			(d) ->
				firstBlock = d.split(",")[0]
				return firstBlock == "DEPARTING" || firstBlock == "ARRIVING"
		)

		lastStationName = allStationsInLogs[allStationsInLogs.length - 1].split(",")[1]
		isLastStationDeparting = allStationsInLogs[allStationsInLogs.length - 1].split(",")[0] == "DEPARTING"

		# find last station
		for station,i in currentTrackStations
			if station.stationName == lastStationName
				log.lastStation = i
				break

		if isLastStationDeparting
			if log.lastStation > log.firstStation and log.lastStation < (currentTrackStations.length - 1)
				log.lastStation++
			if log.lastStation < log.firstStation and log.lastStation > 0
				log.lastStation--

		return log

	calculateTrackDistances = () ->
		stationList = window.app.data.masterStationList
		trackLines = window.app.data.trackLines

		trackDistances = {}
		for trackKey in _.keys(trackLines)
			console.log trackKey
			lastStation = ""
			distances = []
			for station in trackLines[trackKey]
				if lastStation
					# calculate distance
					s1 = _.findWhere(stationList, {code: lastStation })
					s2 = _.findWhere(stationList, {code: station })
					dist = haversine(s1, s2)
					distances.push(dist)
				lastStation = station

			trackDistances[trackKey] = distances

		return trackDistances

	problem = (error) ->
		console.log 'error loading data:'
		console.log error

	q = queue()

	psv = d3.dsv('|', 'text/plain')

	q
		.defer(d3.xhr, dataPath + '/trackLines.txt')
		.defer(psv, dataPath + '/masterStationList.txt')
		.defer(d3.xhr, dataPath + '/loggedData_.txt')
		# .defer(d3.xhr, dataPath + '/8thAve-Canarsie.csv')
		# .defer(d3.xhr, dataPath + '/Canarsie-8thAve.csv')

	q.awaitAll(
		(error, results) ->
			if error?
				problem(error)

			# parse results:
			[
				trackLines
				masterStationList
				loggedDataFiles
			] = results

			# parse track lines
			lines = trackLines.response.split("\n")
			parsedLines = {}
			parsedStationNames = {}
			lines.forEach (d) ->
				d = d.split("|")
				lineName = d.shift()
				d.pop()
				parsedLines[lineName] = d if lineName

				parsedStationNames[lineName] = []
				parsedStationNames[lineName].push(_.findWhere(masterStationList, {code:stop})) for stop in d


			window.app.data.trackLines = parsedLines
			window.app.data.trackStationNames = parsedStationNames
			window.app.data.masterStationList = masterStationList


			# parse log data
			log_q = queue()
			for logFile in loggedDataFiles.response.split("\n")
				if logFile
					log_q.defer(d3.xhr, dataPath + "/" + logFile)

			log_q.awaitAll(
				(err2, logs) ->
					parsedLogs = []
					parsedLogs.push(parseLogData(l.response)) for l in logs

					window.app.data.logs = parsedLogs

					# calculate track distances
					window.app.data.trackDistances = calculateTrackDistances()

					$(window).trigger "data-loaded"
			)
	)



