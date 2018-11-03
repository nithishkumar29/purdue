set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(ifqlen) 50
set val(nn) [lindex $argv 0]
set val(rp) AODV
set val(x) 100
set val(y) 100
set val(stop) 150

set ns [new Simulator]
set tracefd [open adhoc.tr w]
set windowVsTime2 [open win.tr w]
set namtrace [open adhoc.nam w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

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
				-macTrace OFF \
				-movementTrace ON \
$ns node-config -energyModel "EnergyModel" \
                -idlePower 1.0 \
                -rxPower 1.0 \
                -txPower 1.0 \
                -sleepPower 0.101 \
                -transitionPower 0.2 \
                -transitionTime 0.305 \
                -initialEnergy 200

for {set i 0} {$i < $val(nn) } { incr i } {
	set node_($i) [$ns node]
	#set energy_($i) [expr rand()*500]
		#$ns node-config -initialEnergy $energy_($i) \
		#				-rxPower 0.5 \
	#				-txPower 1.0 \
	#				-idlePower 0.0 \
	#				-sensePower 0.3			
	#set E_($i) $energy_($i)
}

set nx 0
set ny 0

$node_(0) set X_ nx
$node_(0) set Y_ ny
$node_(0) set Z_ 0

for {set i 1} {$i < $val(nn) } { incr i } {
 if {[expr $i%2] != 0} {
  set nx [expr $nx+10]
 } else {
  set ny [expr $ny+10]
 }
 
 $node_($i) set X_ $nx
 $node_($i) set Y_ $ny
 $node_($i) set Z_ 0
 
 set tcp_($i) [new Agent/TCP/Newreno]
 $tcp_($i) set class_ 2
 set sink_($i) [new Agent/TCPSink]
 $ns attach-agent $node_(0) $tcp_($i)
 $ns attach-agent $node_($i) $sink_($i)
 $ns connect $tcp_($i) $sink_($i)
 set ftp_($i) [new Application/FTP]
 $ftp_($i) attach-agent $tcp_($i)
 $ns at 0.1 "$ftp_($i) start"
}

proc plotWindow {tcpSource file} {
	global ns
	set time 0.01
	set now [$ns now]
	set cwnd [$tcpSource set cwnd_]
	puts $file "$now $cwnd"
	$ns at [expr $now+$time] "plotWindow $tcpSource $file"
}

for {set i 0} {$i < $val(nn)} { incr i } {
	$ns initial_node_pos $node_($i) 5;
}

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns at $val(stop) "$node_($i) reset";
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"

proc stop {} {
	global ns tracefd namtrace
	$ns flush-trace
	close $tracefd
	close $namtrace
}

$ns run

