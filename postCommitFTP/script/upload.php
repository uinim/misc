<?php
	// vars
	$target_dir = "/home/www/html/";
	
	$repos = $argv[1];
	$rev = $argv[2];
	
	$ftp_server = "host";
	$ftp_user = "user";
	$ftp_pass = "pass";
	$remort_document_dir = "html/";
	
	// $B%o!<%-%s%0%3%T!<$NB8:_%A%'%C%/(B
	if (!is_dir($target_dir . ".svn")) {
		$command = sprintf("svn co file://%s %s", $repos, $target_dir);
		exec($command);
	}
	
	$command = sprintf("svn up %s", $target_dir);
	exec($command);
	
	// svn log$B$h$j(Bxml$B$r<hF@$7$F(BSimpleXML$B%*%V%8%'%/%H$XJQ49(B
	$command = sprintf("svn log file://%s -v --xml -r %s", $repos, $rev);
	//system ($command);
	exec($command, $xml_array);
	
	$xml_str = implode("", $xml_array);
	
	$xml = simplexml_load_string($xml_str);
	
	// commit$B%m%0$K$h$j(BFTP$B%"%C%W%m!<%I$9$k$+H]$+$NH=JL(B
	// $B%3%_%C%H%m%0$N@hF,J8;zNs$,!V(B#ftp$B!W$N>l9g$O(BFTP$B$G%"%C%W%m!<%I(B
	$comment = $xml->logentry->msg;
	if (preg_match("/^#ftp/", "$comment") == 0) {
		exit;
	}
	
	// FTP$B%"%C%W%m!<%I$9$k%U%!%$%k%j%9%HG[Ns$N@8@.(B
	$files = array();
	$path = array();
	foreach ($xml->logentry->paths->path as $value) {
		array_push($files, array(
			"kind" => (string) $value['kind'],
			"action" => (string) $value['action'],
			"path" => (string)$value,
		));
		// sort
		$path[] = (string)$value;
	}
	// $B%U%!%$%k%j%9%HG[Ns$N%=!<%H(B
	array_multisort($path, SORT_ASC, SORT_STRING, $files);
	
	// FTP$BA`:n3+;O(B
	$conn_id = ftp_connect($ftp_server) or die("Couldn't connect to $ftp_server");
	$login_result = ftp_login($conn_id, $ftp_user, $ftp_pass) or die("You do not have access to this ftp server!");
	if ((!$conn_id) || (!$login_result)) {
		print "failed!\n";
	} else {
		print "success!\n";
	}
	
	// $B%U%!%$%k%"%C%W%m!<%I(B
	if (!ftp_put($conn_id, "html/index.html", "html/index.html", FTP_BINARY)) {
		print "failed!\n";
	} else {
		print "success!\n";
	}
	
	// $B%U%!%$%k:o=|(B
	if (!ftp_delete($conn_id, "html/index.html")) {
		print "failed!\n";
	} else {
		print "success!\n";
	}
	
	// $B%G%#%l%/%H%j:n@.(B
	if (!ftp_mkdir($conn_id, "html/test")) {
		print "failed!\n";
	} else {
		print "success!\n";
	}
	
	// $B%G%#%l%/%H%j:o=|(B
	if (!ftp_rmdir($conn_id, "html/test")) {
		print "failed!\n";
	} else {
		print "success!\n";
	}
	
	// FTP$B=*N;(B
	ftp_close($conn_id);

?>
