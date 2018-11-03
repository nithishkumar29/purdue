set ns [new Simulator]


set val(chan) Channel/WirelessChannel ;
set val(prop) Propagation/TwoRayGround ;
set val(netif) Phy/WirelessPhy ;
set val(mac) Mac/802_11 ;
set val(ifq) Queue/DropTail/PriQueue ;
set val(ll) LL ;
set val(ant) Antenna/OmniAntenna ;
set val(ifqlen) 50 ;
set val(nn) 4 ;
set val(rp) DSDV ;
set val(stop) 10.0 ;
set val(x) 1000
set val(y) 1000


$ns use-newtrace
set tr [open out.tr w]
$ns trace-all $tr
set nf [open out.nam w]
$ns namtrace-all-wireless $nf $val(x) $val(y)


set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn);
set chan_ [new $val(chan)]


$ns node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-channelType $val(chan) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace ON \
		-movementTrace ON 



set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

$n1 set X_ 800
$n1 set Y_ 100
$n1 set Z_ 0

$n2 set X_ 1000
$n2 set Y_ 100
$n2 set Z_ 0

$n3 set X_ 2500
$n3 set Y_ 100
$n3 set Z_ 0

$n4 set X_ 2700
$n4 set Y_ 100
$n4 set Z_ 0

$ns initial_node_pos $n1 30
$ns initial_node_pos $n2 30
$ns initial_node_pos $n3 30
$ns initial_node_pos $n4 30

set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $tcp1
$ns attach-agent $n2 $sink1
$ns connect $tcp1 $sink1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns attach-agent $n3 $tcp2
$ns attach-agent $n4 $sink2
$ns connect $tcp2 $sink2

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2


$ns at 1.0 "$ftp1 start"
$ns at 1.5 "$ftp2 start"
$ns at 2.0 "$ftp1 stop"
$ns at 3.5 "$ftp2 stop"
$ns at 4 "stop"

proc stop {} {
	global nf tr ns
	$ns flush-trace
	close $nf
	close $tr
	exec nam out.nam &
}

$ns run	


