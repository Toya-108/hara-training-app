<?php
	header('Content-Type: text/html; charset=UTF-8');


	$result_data ;
	$data = file_get_contents('php://input') ;

	$data = $data.PHP_EOL."Result" ;
	print($data) ;

?>
