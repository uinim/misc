<?php
	// vars
	$target_dir = "/home/www/html/";
	
	$repos = $argv[1];
	$rev = $argv[2];
	
	$ftp_server = "host";
	$ftp_user = "user";
	$ftp_pass = "pass";
	$remort_document_dir = "html/";
	
	// ワーキングコピーの存在チェック
	if (!is_dir($target_dir . ".svn")) {
		$command = sprintf("svn co file://%s %s", $repos, $target_dir);
		exec($command);
	}
	
	$command = sprintf("svn up %s", $target_dir);
	exec($command);
	
	// svn logよりxmlを取得してSimpleXMLオブジェクトへ変換
	$command = sprintf("svn log file://%s -v --xml -r %s", $repos, $rev);
	//system ($command);
	exec($command, $xml_array);
	
	$xml_str = implode("", $xml_array);
	
	$xml = simplexml_load_string($xml_str);
	
	// commitログによりFTPアップロードするか否かの判別
	// コミットログの先頭文字列が「#ftp」の場合はFTPでアップロード
	$comment = $xml->logentry->msg;
	if (preg_match("/^#ftp/", "$comment") == 0) {
		exit;
	}
	
	// FTPアップロードするファイルリスト配列の生成
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
	// ファイルリスト配列のソート
	array_multisort($path, SORT_ASC, SORT_STRING, $files);
	
	// FTP操作開始
	$conn_id = ftp_connect($ftp_server) or die("Couldn't connect to $ftp_server");
	$login_result = ftp_login($conn_id, $ftp_user, $ftp_pass) or die("You do not have access to this ftp server!");
	if ((!$conn_id) || (!$login_result)) {
		print "failed!\n";
	} else {
		print "success!\n";
	}
	
	// ファイルアップロード
	if (!ftp_put($conn_id, "html/index.html", "html/index.html", FTP_BINARY)) {
		print "failed!\n";
	} else {
		print "success!\n";
	}
	
	// ファイル削除
	if (!ftp_delete($conn_id, "html/index.html")) {
		print "failed!\n";
	} else {
		print "success!\n";
	}
	
	// ディレクトリ作成
	if (!ftp_mkdir($conn_id, "html/test")) {
		print "failed!\n";
	} else {
		print "success!\n";
	}
	
	// ディレクトリ削除
	if (!ftp_rmdir($conn_id, "html/test")) {
		print "failed!\n";
	} else {
		print "success!\n";
	}
	
	// FTP終了
	ftp_close($conn_id);

?>
