#Create Simulator
set ns [new Simulator]

#Use colors to differentiate the traffic
$ns color 1 Blue
$ns color 2 Red

#Open trace and NAM trace file
set ntrace [open prog6.tr w]
$ns trace-all $ntrace
set namfile [open prog6.nam w]
$ns namtrace-all $namfile
set winfile3 [open winfile3 w]
#set winfile2 [open winfile2 w]
#Create 6 nodes
for {set i 0} {$i < 6} {incr i} {
set n($i) [$ns node]
}

proc plotWindow {tcpSource file} {
global ns
set time 0.1
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file"
}

proc finish {} {
	global ns ntrace namfile
	$ns flush-trace
	close $ntrace
	close $namfile
	exec nam prog6.nam &
	exit 0
}

#Create duplex links between the nodes
$ns duplex-link $n(0) $n(2) 1Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 1Mb 10ms DropTail
$ns simplex-link $n(2) $n(3) 3Mb 100ms DropTail
$ns simplex-link $n(3) $n(2) 3Mb 100ms DropTail

#Node n(3), n(4) and n(5) are considered in a LAN
set lan [$ns newLan "$n(3) $n(4) $n(5)" 10Mb 40ms LL Queue/DropTail MAC/802_3 Channel]

#Orientation to the nodes
$ns duplex-link-op $n(0) $n(2) orient right-down
$ns duplex-link-op $n(1) $n(2) orient right-up
$ns simplex-link-op $n(2) $n(3) orient right

#Setup queue between n(2) and n(3) and monitor the queue
$ns queue-limit $n(2) $n(3) 50
$ns simplex-link-op $n(2) $n(3) queuePos 0.5

#Set error model on link n(2) and n(3) and insert the error model
set loss_module [new ErrorModel]
$loss_module ranvar [new RandomVariable/Uniform]
$loss_module drop-target [new Agent/Null]
$ns lossmodel $loss_module $n(2) $n(3)

#Setup TCP Connection between n(0) and n(4)
set tcp0 [new Agent/TCP/Newreno]
$tcp0 set fid_ 1
$tcp0 set window_ 8000
$tcp0 set packetSize_ 552
$ns attach-agent $n(0) $tcp0
set sink0 [new Agent/TCPSink/DelAck]
$ns attach-agent $n(4) $sink0
$ns connect $tcp0 $sink0

#Apply FTP Application over TCP
set ftp0 [new Application/FTP]
$ftp0 set type_ FTP
$ftp0 attach-agent $tcp0

#Setup UDP Connection between n(1) and n(5)
set udp0 [new Agent/UDP]
$udp0 set fid_ 2
$ns attach-agent $n(1) $udp0
set null0 [new Agent/Null]
$ns attach-agent $n(5) $null0
$ns connect $udp0 $null0

#Apply CBR Traffic over UDP
set cbr0 [new Application/Traffic/CBR]
$cbr0 set type_ CBR
$cbr0 set packetSize_ 1000
$cbr0 set rate_ 0.1Mb
$cbr0 set random_ false
$cbr0 attach-agent $udp0

#Schedule events
$ns at 0.1 "$cbr0 start"
$ns at 0.1 "plotWindow $tcp0 $winfile3"
$ns at 1.0 "$ftp0 start"
$ns at 124.0 "$ftp0 stop"
$ns at 124.5 "$cbr0 stop"
$ns at 125.0 "finish"
#$ns at 125.0 "Finish"



#$ns at 0.1 "plotWindow $udp0 $winfile2"
#Run Simulation
$ns run


