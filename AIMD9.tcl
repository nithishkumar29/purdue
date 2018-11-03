set ns [new Simulator]                  

$ns trace-all [open D1-m-decrease.tr w]
$ns namtrace-all [open D1-m-decrease.nam w]

        foreach i " 0 1 2 3 " {
                set n$i [$ns node]
        }                         

        $ns at 0.0 "$n0 label TCP"
        $ns at 0.0 "$n3 label TCP"

        $ns duplex-link $n0 $n1 5Mb 20ms DropTail
        $ns duplex-link $n1 $n2 0.5Mb 100ms DropTail
        $ns duplex-link $n2 $n3 5Mb 20ms DropTail   

        $ns queue-limit $n1 $n2 5

        $ns duplex-link-op $n0 $n1 orient top
        $ns duplex-link-op $n1 $n2 orient right
        $ns duplex-link-op $n2 $n3 orient bottom

        $ns duplex-link-op $n1 $n2 queuePos 0.5

Agent/TCP set nam_tracevar_ true
Agent/TCP set window_ 20        
Agent/TCP set ssthresh_ 20     
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink  

$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp       

$ns add-agent-trace $tcp tcp
$ns monitor-agent-trace $tcp
$tcp tracevar cwnd_         
$tcp tracevar ssthresh_     

proc finish {} {

        global ns
        $ns flush-trace

        puts "filtering..."
        #exec tclsh ../ns-allinone-2.1b5/nam-1.0a7/bin/namfilter.tcl D1-m-decrease.nam
        puts "running nam..."
        exec nam D1-m-decrease.nam &
        exit 0
}


$ns at 0.1 "$ftp start"
$ns at 5.0 "$ftp stop"
$ns at 5.1 "finish"

#$ns at 0.0 "$ns trace-annotate \"TCP with multiplicative decrease\""

$ns run

