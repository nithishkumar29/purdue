set ns [new Simulator]

set nf [open out.nam w]
$ns namtrace-all $nf

set tr [open out.tr w]
$ns trace-all $tr

proc finish {} {
	global nf ns tr
	$ns flush-trace
	close $tr
	exec nam out.nam &
	exit 0
}

set node_(0) [$ns node]
set node_(1) [$ns node]
set node_(2) [$ns node]
set node_(3) [$ns node]
set node_(4) [$ns node]
set node_(5) [$ns node]
set node_(6) [$ns node]
set node_(7) [$ns node]

$ns duplex-link $node_(0) $node_(1) 10Mb 10ms DropTail
$ns duplex-link $node_(1) $node_(3) 10Mb 10ms DropTail
$ns duplex-link $node_(2) $node_(1) 10Mb 10ms DropTail
$ns duplex-link $node_(2) $node_(4) 10Mb 10ms DropTail
$ns duplex-link $node_(4) $node_(5) 10Mb 10ms DropTail
$ns duplex-link $node_(5) $node_(3) 10Mb 10ms DropTail
$ns duplex-link $node_(5) $node_(6) 10Mb 10ms DropTail
$ns duplex-link $node_(1) $node_(7) 10Mb 10ms DropTail

$ns duplex-link-op $node_(0) $node_(1) orient right
$ns duplex-link-op $node_(1) $node_(3) orient right
$ns duplex-link-op $node_(2) $node_(1) orient right-up

set tcp [new Agent/TCP]
$ns attach-agent $node_(0) $tcp

set ftp [new Application/FTP]
$ftp attach-agent $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $node_(3) $sink

set udp [new Agent/UDP]
$ns attach-agent $node_(2) $udp

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp

set null [new Agent/Null]
$ns attach-agent $node_(3) $null

$ns connect $tcp $sink
$ns connect $udp $null

$ns rtmodel-at 1.0 down $node_(1) $node_(3)
$ns rtmodel-at 2.0 up $node_(1) $node_(3)

$ns rtproto DV

$ns at 0.0 "$ftp start"
$ns at 0.0 "$cbr start"

$ns at 5.0 "finish"
$ns compute-routes
$ns get-routelogic
$ns dump-routelogic-nh
$ns dump-routelogic-distance

$ns run

