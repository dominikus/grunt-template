lineView = (lineData, lineName, logs) ->
	[width, height, svg, data, signalScale, lineScale, tooltip, xAxis] = [undefined]

	setup = () ->
		stationNames = _.map(
			lineData,
			(d,i) -> {
				"name": _.findWhere(window.app.data.masterStationList, {code:d}).stationName
				"position": +i/+lineData.length
			}
		)

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
			.domain([0,100])
			.range([120,20])


		# labels
		stationLabel = svg.selectAll(".stationLabel").data(stationNames)
		stationLabel.enter().append("text")
			.classed("stationLabel", true)
			.attr("transform", (d) -> "translate(#{lineScale(d.position)}, 130) rotate(-60)")
			.text((d) -> d.name)

		# line name
		svg.append("circle")
			.classed("line-name-circle", true)
			.attr("cx", 55)
			.attr("cy", 55)
			.attr("r", 20)

		svg.append("text")
			.classed("line-name", true)
			.attr("x", 55)
			.attr("y", 62)
			.text(lineName)

		render()


	showTooltip = (s) ->
		e = d3.event
		tooltip.html(s)
		tooltip.style({
			"left": e.x + "px"
			"top": e.y + window.scrollY + "px"
			"display": "block"
			})

	hideTooltip = () ->
		tooltip.style("display", "none")

	render = () ->
		# draw all logs
		for log in logs
			console.log log.logs

			direction = sign(log.lastStation - log.firstStation)
			console.log "line #{log.lineName}, direction #{direction}"

			# find the line offset, i.e., the earliest station's position on the track
			minStation = Math.min(log.firstStation, log.lastStation)
			maxStation = Math.max(log.firstStation, log.lastStation)
			lineOffset = minStation / lineData.length
			lineScaling = (maxStation - minStation) / lineData.length

			# find the next streckenabschnitt
			currentPosition = 1
			lastStationPosition = 1

			# count all non-DEPARTING logs
			totalLogs = _.reduce(
				log.logs,
				(memo, d) ->
					if d.split(",")[0] == "DEPARTING" or d.split(",")[0] == "ARRIVING"
						return memo
					else
						return memo + 1
				0)
			while(currentPosition < log.logs.length)
				# parse current entry
				entry = log.logs[currentPosition].split(",")

				# next streckenabschnitt!
				if (entry[0] == "DEPARTING") or (currentPosition + 1 == log.logs.length)
					# draw all points in between:
					#console.log "drawing #{lastStationPosition} to #{currentPosition}"
					if direction == 1
						for i in [lastStationPosition...currentPosition]
							do (i) ->
								#console.log "position: " + ((i/totalLogs)*lineScaling + lineOffset)
								horizontalPosition = (i/totalLogs) * lineScaling + lineOffset
								#console.log i + ": " + log.logs[i].split(",")[0]

								svg.append("circle")
									.classed("measure", true)
									.classed("forward", true)
									.attr("cx", lineScale(horizontalPosition))
									.attr("cy", signalScale(log.logs[i].split(",")[0]))
									.attr("r", 2)
									.on("mouseover",
										() ->
											showTooltip("<p><b>signal:</b> " + log.logs[i].split(",")[0] + "<br/><b>time:</b> " + new Date(+log.logs[i].split(",")[1] * 1000) + "<br/><b>position on line:</b> " + horizontalPosition + "/1<br/>direction: " + direction + "</p>")
									)
									.on("mouseout", (d) ->
										hideTooltip()
									)
					else if direction == -1
						for i in [(currentPosition-1)...lastStationPosition] by -1
							do (i) ->
								#console.log "position: " + ((i/totalLogs)*lineScaling + lineOffset)
								horizontalPosition = ((totalLogs - i)/totalLogs) * lineScaling + lineOffset
								#console.log i + ": " + log.logs[i].split(",")[0]

								svg.append("circle")
									.classed("measure", true)
									.classed("backward", true)
									.attr("cx", lineScale(horizontalPosition))
									.attr("cy", signalScale(log.logs[i].split(",")[0]))
									.attr("r", 2)
									.on("mouseover",
										() ->
											showTooltip("<p><b>signal:</b> " + log.logs[i].split(",")[0] + "<br/><b>time:</b> " + new Date(+log.logs[i].split(",")[1] * 1000) + "<br/><b>position on line:</b> " + horizontalPosition + "/1<br/>direction: " + direction + "</p>")
									)
									.on("mouseout", (d) ->
										hideTooltip()
									)


					# finally:
					lastStationPosition = currentPosition + 1
				else
					# just regular log point - do nothing

				currentPosition += 1

	setup()

$(window).on "data-loaded", () ->
	# plot all lines
	window.app.views.lines = {}
	for line in _.keys(window.app.data.trackLines)
		# find all relevant logs
		lineLogs = _.filter(window.app.data.logs, (d) -> d.lineName == line)
		window.app.views.lines[line] = lineView(window.app.data.trackLines[line], line, lineLogs)

	$(window).trigger "scales drawn"
