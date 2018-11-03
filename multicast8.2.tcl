set ns [new Simulator]
$ns multicast

$ns namtrace-all [open out.nam w]

set f [open out.tr w]
$ns trace-all $f


$ns color 1 Blue
$ns color 2 Red

set group1 [Node allocaddr]   
set group2 [Node allocaddr]                   

set nod 6                          

for {set i 1} {$i <= $nod} {incr i} {
   set n($i) [$ns node]                      
}

$ns duplex-link $n(1) $n(2) 0.3Mb 10ms DropTail 
$ns duplex-link $n(2) $n(3) 0.3Mb 10ms DropTail
$ns duplex-link $n(2) $n(4) 0.5Mb 10ms DropTail
$ns duplex-link $n(2) $n(5) 0.3Mb 10ms DropTail
$ns duplex-link $n(1) $n(6) 0.3Mb 10ms DropTail

DM set CacheMissMode dvmrp
set mproto DM                                

set mrthandle [$ns mrtproto $mproto] 

set udp1 [new Agent/UDP]
$udp1 set dst_addr_ $group1
$udp1 set dst_port_ 0
set src1 [new Application/Traffic/CBR]
$src1 attach-agent $udp1
$src1 set random_ false
$ns attach-agent $n(1) $udp1


set udp2 [new Agent/UDP]
$udp2 set dst_addr_ $group2
$udp2 set dst_port_ 3
set src2 [new Application/Traffic/CBR]
$src2 attach-agent $udp2
$src2 set random_ false                    
$ns attach-agent $n(2) $udp2

$udp1 set fid_ 1
$udp2 set fid_ 2

set rcvr [new Agent/LossMonitor]      

$ns at 0.6 "$n(3) join-group $rcvr $group2"
$ns at 1.3 "$n(4) join-group $rcvr $group1"
$ns at 1.6 "$n(5) join-group $rcvr $group2"
$ns at 2.3 "$n(6) join-group $rcvr $group2"
$ns at 3.5 "$n(3) leave-group $rcvr $group1"
$ns at 3.9 "$n(4) leave-group $rcvr $group1"
$ns at 0.4 "$src1 start"
$ns at 2.0 "$src2 start"
$ns at 4.0 "finish"
proc finish {} {
        global ns f 
        $ns flush-trace
        close $f
        exec nam out.nam &
        exit 0
}
$ns run
