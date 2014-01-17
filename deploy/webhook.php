<?php
 
	// Use in the "Post-Receive URLs" section of your GitHub repo.
	shell_exec( 'cd ~/html/XXXXXXX/ && git reset --hard HEAD && git pull ; cd www; grunt' );

	echo("done");
 
?>