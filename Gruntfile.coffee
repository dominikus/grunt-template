module.exports = (grunt) ->
	grunt.initConfig(

		pkg: grunt.file.readJSON('package.json')
		
		## watch
		watch:
			options: 
				livereload: true
				spawn: false	

			scripts: 
				files: ['js/*.js']
				tasks: []
			
			coffee: 
				files: ['coffee/*.coffee']
				tasks: ['coffee', 'concat']
			
			sass: 
				files: ['**/*.sass']
				tasks: ['compass']
				
			
			images: 
				files: ['images/**/*.png,jpg,gif', 'images/*.png,jpg,gif']
				tasks: ['imagemin']
				
			gruntfile:
				files: ["Gruntfile.coffee"]

			html:
				files: ["*.html", "*.rb"]				

		"bower-install":

			target:
				src: ['index.html'],
				###
				cwd: ''
				dependencies: Boolean (default: true)
				devDependencies: Boolean (default: false)
				exclude: []
				fileTypes: {}
				ignorePath: ''
				###
			
		
		## dev

		coffee: 
			glob_to_multiple: 
				expand: true
				flatten: true
				cwd: '.'
				src: ['coffee/*.coffee']
				dest: 'js'
				ext: '.js'

		
		compass:
			dist:
				options: 
					environment: 'production'
				
			dev: 
				options: {}
			
		

		connect: 
			server: 
				options: 
					port: 8000
					base: './'

		concat: 
			default: 
				src: [
					'js/main.js'
				]
				dest: 'js/build/scripts.js'		

		# dist

		clean: 
			dist:
				src: ["dist/*"]

		copy:
			dist:
				files:
					[				
						src: '*.html'
						dest: 'dist/'
					,
						cwd: 'assets/fonts'
						src: '**/*'
						dest: 'dist/assets/fonts'
					]

		cssmin: 
			combine: 
				files: 
					'dist/css/build/styles.css': ['css/build/styles.css']
		

		uglify: 
			build: 
				src: 'js/build/scripts.js'
				dest: 'dist/js/build/scripts.js'
		

		imagemin: 
			dynamic: 
				files: [
					expand: true
					cwd: 'assets/images/'
					src: ['**/*.png,jpg,gif']
					dest: 'dist/assets/images/'
				]

	)

	## setup 
	require('load-grunt-tasks')(grunt)

	grunt.loadNpmTasks 'grunt-contrib-compass' 
	grunt.loadNpmTasks 'grunt-contrib-coffee' 
	grunt.loadNpmTasks 'grunt-contrib-clean' 
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-bower-install'

	## tasks
	grunt.registerTask('default', [
		'coffee'
		'compass:dev'
		'concat'
	])

	grunt.registerTask('dev', [
		'connect'
		'watch'
	])

	grunt.registerTask('dist', [
		'clean'
		'copy'
		'coffee'
		'compass:dist'
		'concat'
		'uglify'
		'cssmin'
		'imagemin'
	])
