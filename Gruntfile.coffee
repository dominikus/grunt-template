module.exports = (grunt) ->

	grunt.initConfig(

		pkg: grunt.file.readJSON('package.json')
		
		config:
			dev:
				options:
					variables:
						'environment': 'dev'
						'compass-env': 'development'
			dist:
				options:
					variables:
						'environment': 'dist'
						'compass-env': 'production'

		## watch
		watch:
			options: 
				livereload: true
				spawn: false

			bower:
				files: ['bower_components/**/*']	
				tasks: ['bower_concat']
			
			coffee: 
				files: ['src/coffee/*.coffee', 'src/coffee/**/*.coffee']
				tasks: ['coffee']
			
			sass: 
				files: ['src/sass/*.sass', 'src/sass/**/*.sass']
				tasks: ['compass']
				
			images: 
				files: ['src/images/**/*.png,jpg,gif', 'src/images/*.png,jpg,gif']
				tasks: ['copy']

			html:
				files: ['src/*.html', 'src/**/*.html']
				tasks: ['copy']
				
			gruntfile:
				files: ["Gruntfile.coffee"]
		


		bower_concat:
			default:
				dest: '<%= grunt.config.get("environment") %>/js/libs.js'
		
		coffee: 
			default:
				options:
					join: true
				files:
					'<%= grunt.config.get("environment") %>/js/main.js' : ['src/coffee/main.coffee', 'src/coffee/**/*.coffee']
		
		compass:
			default:
				options: 
					environment: '<%= grunt.config.get("compass-env") %>'		

		connect: 
			default:
				options: 
					port: 8000
					base: './<%= grunt.config.get("environment") %>/'

		# dist

		clean:
			default:
				src: ['<%= grunt.config.get("environment") %>/*']

		copy:
			default:
				files: 
					[
						expand: true
						src: '*.html'
						cwd: 'src'
						dest: '<%= grunt.config.get("environment") %>/'
					,
						expand: true
						cwd: 'src'
						src: 'assets/**/*'
						dest: '<%= grunt.config.get("environment") %>/'
					,
						expand: true
						cwd: 'src'
						src: 'js/**/*'
						dest: '<%= grunt.config.get("environment") %>/'
					]

		cssmin: 
			combine: 
				files: 
					'<%= grunt.config.get("environment") %>/css/styles.css': ['<%= grunt.config.get("environment") %>/css/styles.css']
		

		uglify: 
			default: 
				'<%= grunt.config.get("environment") %>/js/libs.js' : '<%= grunt.config.get("environment") %>/js/libs.js'
				'<%= grunt.config.get("environment") %>/js/main.js' : '<%= grunt.config.get("environment") %>/js/main.js'
		

		imagemin: 
			default: 
				files: [
					expand: true
					cwd: '<%= grunt.config.get("environment") %>/assets/'
					src: ['**/*.{png,jpg,gif}']
					dest: '<%= grunt.config.get("environment") %>/assets/'
				]

	)

	## setup 
	require('load-grunt-tasks')(grunt)

	## tasks
	grunt.registerTask('default', [
		'config:dev'
		'coffee'
		'compass'
	])

	grunt.registerTask('dev', [
		'config:dev'
		'clean'
		'copy'
		'bower_concat'
		'coffee'
		'compass'
		'connect'
		'watch'
	])

	grunt.registerTask('dist', [
		'config:dist'
		'clean'
		'copy'
		'bower_concat'
		'coffee'
		'compass'
		'uglify'
		'cssmin'
		'imagemin'
		'connect:default:keepalive'
	])
