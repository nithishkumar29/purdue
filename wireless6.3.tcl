set ns [new Simulator]
$ns color 1 Blue
$ns color 2 Red
set val(x) 500
set val(y) 500

set val(chan) Channel/WirelessChannel ;
set val(prop) Propagation/TwoRayGround ;
set val(phy) Phy/WirelessPhy ;
set val(mac) Mac/802_11 ;
set val(ifq) Queue/DropTail/PriQueue ;
set val(ll) LL ;
set val(ant) Antenna/OmniAntenna ;
set val(ifqlen) 50 ;
set val(nn) 6 ;
set val(rp) DSDV ;
set val(stop) 100.0 ;

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

set namfile [open nam1.nam w]
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set tracefile [open sample.tr w]

$ns trace-all $tracefile

create-god $val(nn)

$ns node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(phy) \
		-channelType $val(chan) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace OFF \
		-movementTrace ON 

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

$n1 set X_ 200
$n1 set Y_ 100
$n1 set Z_ 0

$n2 set X_ 100
$n2 set Y_ 100
$n2 set Z_ 0

$n3 set X_ 200
$n3 set Y_ 300
$n3 set Z_ 0

$n4 set X_ 300
$n4 set Y_ 100
$n4 set Z_ 0

$n5 set X_ 200
$n5 set Y_ 200
$n5 set Z_ 0

$n6 set X_ 300
$n6 set Y_ 300
$n6 set Z_ 0

$ns initial_node_pos $n1 30
$ns initial_node_pos $n2 30
$ns initial_node_pos $n3 30
$ns initial_node_pos $n4 30
$ns initial_node_pos $n5 30
$ns initial_node_pos $n6 30

set udp [new Agent/UDP]
$udp set fid_ 2
$ns attach-agent $n2 $udp
set null [new Agent/Null]
$ns attach-agent $n5 $null
$ns connect $udp $null

#Apply CBR Traffic over UDP
set cbr0 [new Application/Traffic/CBR]
$cbr0 set type_ CBR
$cbr0 set packetSize_ 1000
$cbr0 set rate_ 0.1Mb
$cbr0 set random_ false
$cbr0 attach-agent $udp

$ns at 2.0 "$n2 setdest 300 100 10"
$ns at 0.1 "$cbr0 start"
$ns at 100.0 "$cbr0 stop"
$ns at 100.01 "stop"
$ns at 100.02 "puts \"NS Exiting..\" ; $ns halt"

proc stop {} {
	global namfile tracefile ns
	$ns flush-trace
	close $namfile
	close $tracefile
	exec nam nam1.nam &
}

$ns run
