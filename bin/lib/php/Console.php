<?php

class Console {
	const COLOR_BLUE = '34;1';
	const COLOR_GREEN = '32';
	const COLOR_RED = '31;1';
	const COLOR_YELLOW = '33;1';

	private static $isTerminal;

	public static function section($line) {
		self::log("\n".'*** '.$line."\n", self::COLOR_BLUE);
	}

	public static function success($line) {
		self::log($line, self::COLOR_GREEN);
	}

	public static function error($line) {
		self::log('* ERROR: '.$line, self::COLOR_RED);
	}

	public static function warn($line = '') {
		self::log('* '.$line, self::COLOR_YELLOW);
	}

	public static function log($line = '', $color = FALSE, $end = "\n") {
		if ($color !== FALSE && self::isTerminal()) {
			echo "\033[" . $color . "m$line\033[0m" . $end;
		} else {
			echo $line . $end;
		}
	}

	public static function getAnswer($opts) {
		$cmd = '['.implode('/', array_keys($opts)).']: ';
		while (true) {
			echo $cmd;
			$answer = strtolower(trim(fgets(STDIN)));
			if (isset($opts[$answer])) {
				break;
			}
		}
		return $opts[$answer];
	}

	public static function confirm() {
		return self::getAnswer(array('y'=>TRUE, 'n' => FALSE));
	}

	public static function progressError($server, $length = 78) {
		self::returnCarriage();
		self::log(sprintf("       - %-" . ($length-9) . "s\n", $server . ': rsync failed!'), self::COLOR_RED, '');
	}

	public static function progressBar($done, $count, $length = 78) {
		$length -= 10;
		self::returnCarriage();
		if ($done == $count) {
			printf("  100%% [%s]\n", str_repeat('=', $length));
		} else {
			$ratio = $done / $count;
			$length--; // To leave space for > mark
			$done_len = round($ratio * $length);
			$pending_len= $length - $done_len;
			printf("%5.1f%% [%s>%s] ", $ratio*100, str_repeat('=', $done_len), str_repeat('.', $pending_len));
		}
	}

	public static function isTerminal() {
		if (self::$isTerminal === NULL) {
			self::$isTerminal = posix_isatty(STDOUT);
		}
		return self::$isTerminal;
	}

	public static function returnCarriage() {
		echo self::isTerminal() ? "\r" : "\n";
	}
}
