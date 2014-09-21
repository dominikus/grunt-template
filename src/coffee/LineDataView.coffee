lineView = (datasets) ->
	[provider, phone, from, to, lineName] = [undefined]
	[width, height, svg, datas, signalScale, lineScale, tooltip, xAxis] = [undefined]

	parseData = (source) ->
		provider = source[3]
		phone = source[4]
		lineName = source[5]
		from = source[6]
		to = source[7]

		# reduce to the logs:
		source = source.slice(8)

		if reverse
			source = source.reverse()

		# calculate the number of logs for a given streckenabschnitt
		logsBetweenStops = []
		currentLogsInBetween = 0
		currentStop = 0
		totalLogs = 0
		source.forEach (d) ->
			log = d.split(",")
			if log[0] == "DEPARTING"
				logsBetweenStops[currentStop] = currentLogsInBetween
				currentStop++
				currentLogsInBetween = 0
			else
				currentLogsInBetween++
				totalLogs++

		data = []
		stations = []
		positionOnLine = 0
		currentLogsInBetween = 0
		overallLogIndex = 0
		source.forEach (d) ->
			log = d.split(",")
			if log[0] == "DEPARTING"
				positionOnLine++
				currentLogsInBetween = 0
				stations.push({
					"name": log[1]
					"position": (overallLogIndex / totalLogs)
				})
			else
				dataEntry = {
					"signal": +log[0]
					"time": +log[1]
					"positionOnLine": positionOnLine
					"linePosition": (currentLogsInBetween / logsBetweenStops[positionOnLine])
					"absolutePosition": (overallLogIndex / totalLogs)
				}
				data.push(dataEntry)
				currentLogsInBetween++
				overallLogIndex++
		# add the final stop
		trackLine = window.app.data.trackLines[lineName]
		lastStop = trackLine[trackLine.length - 1]
		stations.push({
			"name": _.findWhere(window.app.data.masterStationList, {"code": lastStop}).stationName
			"position": 1
			})

		lineLength = 0
		lineLength += snip for snip in window.app.data.trackDistances[lineName]

		return data

	setup = () ->
		# parse the data
		datas = parseData(source)


		# create on-screen elements
		width = $("#vis").width()
		height = $("#vis").height()

		svg = d3.select("#vis").append("svg")
			.attr({
				"width": width
				"height": height
				})

		# tooltip
		tooltip = d3.select("#vis").append("div")
			.classed("ttip", true)

		lineScale = d3.scale.linear()
			.domain([0, 1])
			.range([80, width - 120])

		signalScale = d3.scale.linear()
			.domain(d3.extent(_.map(data, (d) -> +d.signal)))
			.range([120,20])


		# labels
		stationLabel = svg.selectAll(".stationLabel").data(stations)
		stationLabel.enter().append("text")
			.classed("stationLabel", true)
			.attr("transform", (d) -> "translate(#{lineScale(d.position)}, 130) rotate(-60)")
			.text((d) -> d.name)

		render()


	showTooltip = (s) ->
		e = d3.event
		tooltip.html(s)
		tooltip.style({
			"left": e.x + "px"
			"top": e.y + "px"
			"display": "block"
			})

	hideTooltip = () ->
		tooltip.style("display", "none")

	render = () ->
		# do stuff
		data = datas
		measurements = svg.selectAll(".measure").data(data)
		mEnter = measurements.enter()
		mEnter.append("circle")
			.classed("measure", true)
			.attr("cx", (d) ->
				lineScale(+d.absolutePosition)
			)
			.attr("cy", (d) ->
				signalScale(+d.signal)
			)
			.attr("r", 2)
			.on("mouseover", (d) ->
				showTooltip("<p><b>signal:</b> " + d.signal + "<br/><b>time:</b> " + new Date(+d.time * 1000) + "<br/><b>percentage of line:</b> " + (d.absolutePosition * 100).toFixed(2) + "%<br/><b>percentage between stops:</b> " + (d.linePosition * 100).toFixed(2) + "%</p>")
			)
			.on("mouseout", (d) ->
				hideTooltip()
			)

	setup()

$(window).on "____data-loaded", () ->
	# plot all lines
	for line in window.app.data.trackLines
		lineView(line)
