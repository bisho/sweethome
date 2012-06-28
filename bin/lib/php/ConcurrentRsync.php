<?php

require './Console.php';

class ConcurrentRsync {
	const DEFAULT_CONCURRENCY = 64;
	const DEFAULT_TIMEOUT = 5;
	const DEFAULT_RSYNC_OPTS = '--checksum -rl --no-owner --no-group --compress --delay-updates';
	const RSYNC_COMMAND = '/usr/bin/rsync';
	const LOG_FILE_PATH = '/tmp/';
	const LOG_FILE_PREFIX = 'rsync-log.';
	const EXEC_OK = 0;
	const EXEC_ERROR = 1;

	protected $passwordFile = NULL;
	protected $filterFile = NULL;
	protected $concurrency = self::DEFAULT_CONCURRENCY;
	protected $rsyncOptions = self::DEFAULT_RSYNC_OPTS;
	protected $delete = FALSE;
	
	protected $verbose = TRUE;

	protected $pids = array();
	protected $children = 0;
	protected $count = 0;
	protected $done = 0;

	protected $timeout = FALSE;
	protected $error = FALSE;
	protected $failures = array();
	protected $logFile = FALSE;

	public function __destruct() {
		if (! $this->error && $this->logFile) {
			@unlink($this->logFile);
		}
	}

	public function setTimeout($timeout = self::DEFAULT_TIMEOUT) {
		$this->timeout = $timeout;
		return $this;
	}

	public function setEnableLog($file = TRUE) {
		$this->logFile = $file;
		return $this;
	}

	public function setDelete($mode = TRUE) {
		$this->delete = $mode;
		return $this;
	}

	public function setPasswordFile($file) {
		$this->passwordFile = $file;
		return $this;
	}

	public function setFilterFile($file) {
		$this->filterFile = $file;
		return $this;
	}

	public function setBaseRsyncOptions($options) {
		$this->rsyncOptions = $options;
		return $this;
	}

	public function setConcurrency($concurrency) {
		$this->concurrency = $concurrency;
		return $this;
	}

	public function serVerbose($mode) {
		$this->verbose = $mode;
		return $this;
	}

	public function getRsyncOptions($extraOptions = '') {
		return $this->rsyncOptions
			.($this->timeout?' --contimeout='.escapeshellcmd($this->timeout).' --timeout='.escapeshellcmd($this->timeout):'')
			.($this->filterFile?' --filter=._'.escapeshellcmd($this->filterFile):'')
			.($this->passwordFile?' --password-file='.escapeshellcmd($this->passwordFile):'')
			.($this->delete?' --delete --delete-after':'')
			.' '.$extraOptions;
	}

	public function getFailures() {
		return $this->failures;
	}

	public function getLogFile() {
		if ($this->logFile === TRUE) {
			$this->logFile = tempnam(self::LOG_FILE_PATH, self::LOG_FILE_PREFIX);
		}
		return $this->logFile;
	}

	public function stats($origin, $destination, $server) {
                $status = $this->rsyncServer($origin, $destination, $server, '--stats -i -h', FALSE);
		$this->error = ($status != self::EXEC_OK);
		return ! $this->error;
	}

	public function dryRun($origin, $destination, array $servers) {
		return $this->rsyncServers($origin, $destination, $servers, FALSE);
	}

	public function rsync($origin, $destination, array $servers, $real = TRUE) {
		return $this->rsyncServers($origin, $destination, $servers, $real);
	}

	private function rsyncServers($origin, $destination, array $servers, $real) {

		// Reset internal status
		$this->failures = array();
		$this->error = FALSE;
		$this->pids = array();
		$this->children = 0;

		if ($this->verbose) {
			$start = microtime(TRUE);
			$this->count = count($servers);
			$this->done = 0;
			$this->notifyProgress();
		}

		foreach ($servers as $server) {
			if ($this->children >= $this->concurrency) {
				// We are over max concurrency, wait for some rsync to finish
				$this->children -= $this->waitForChild();
			}

			$pid = pcntl_fork();
			if ($pid == 0) {
				// Child process, launch rsync
				$status = $this->rsyncServer($origin, $destination, $server, '', $real);
				exit($status); // End of child execution
			} else if ($pid > 0) {
				// Store in $pids and increment child count
				$this->pids[$pid] = $server;
				$this->children++;
			} else {
				die("Could not fork\n");
			}

			// Check if any child has exited (non blocking)
			$this->children -= $this->waitForChild(FALSE);
		}

		while ($this->children > 0) {
			// Wait for remaining rsync to finish
			$this->children -= $this->waitForChild();
		}

		if ($this->verbose) {
			printf("       Ellapsed: %.2f secs\n\n", microtime(TRUE) - $start);
		}

		return ! $this->error;
	}

	private function waitForChild($block = TRUE) {
		$pid = pcntl_wait($status, $block? 0 : WNOHANG);
		if ($pid > 0) {
			if (pcntl_wexitstatus($status) != 0) {
				$this->childFailure($pid);
			}
			if ($this->verbose) {
				$this->done++;
				$this->notifyProgress();
			}
			return 1;
		} else {
			return 0;
		}
	}

	private function childFailure($pid) {
		$this->error = TRUE;
		if (!isset($this->pids[$pid])) {
			die("Unable to find pid in table\n");
		}
		$this->failures[] = $this->pids[$pid];
		Console::progressError($this->pids[$pid]);
	}

	private function notifyProgress() {
		Console::progressBar($this->done, $this->count);
	}

	private function rsyncServer($origin, $destination, $server, $rsyncOptions, $real) {
		$origin = escapeshellarg($origin);
		$destination = escapeshellarg(sprintf($destination, $server));
		$opts = $this->getRsyncOptions($rsyncOptions . ($real? '' : ' --dry-run'));

		$logFile = $this->getLogFile();
		if ($logFile != FALSE) {
			$std = array(
				0 => array('pipe', 'r'),
				1 => STDOUT,
				2 => array('file', $logFile, 'a'),
			);
		} else {
			$std = array(
				0 => array('pipe', 'r'),
				1 => STDOUT,
				2 => STDERR,
			);
		}
		$process = proc_open(self::RSYNC_COMMAND." $opts $origin $destination", $std, $pipes);

		if (is_resource($process)) {
			fclose($pipes[0]);
			return proc_close($process);
		} else {
			return self::EXEC_ERROR;
		}
	}
}

