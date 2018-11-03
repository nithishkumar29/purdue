set ns [new Simulator]

set node_(s1) [$ns node]
set node_(s2) [$ns node]
set node_(r1) [$ns node]
set node_(r2) [$ns node]
set node_(s3) [$ns node]
set node_(s4) [$ns node]

$ns duplex-link $node_(s1) $node_(r1) 10Mb 2ms DropTail 
$ns duplex-link $node_(s2) $node_(r1) 10Mb 3ms DropTail 
$ns duplex-link $node_(r1) $node_(r2) 1.5Mb 20ms RED 
$ns queue-limit $node_(r1) $node_(r2) 25
$ns queue-limit $node_(r2) $node_(r1) 25
$ns duplex-link $node_(s3) $node_(r2) 10Mb 4ms DropTail 
$ns duplex-link $node_(s4) $node_(r2) 10Mb 5ms DropTail 


set tcp1 [new Agent/TCP]
$ns attach-agent $node_(r1) $tcp1
set tcpsink1 [new Agent/TCPSink]
$ns attach-agent $node_(r2) $tcpsink1
$ns connect $tcp1 $tcpsink1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

$tcp1 set window_ 15
set tcp2 [$ns create-connection TCP/Reno $node_(s2) TCPSink $node_(s3) 1]
$tcp2 set window_ 15
set ftp1 [$tcp1 attach-source FTP]
set ftp2 [$tcp2 attach-source FTP]

# Tracing a queue
set redq [[$ns link $node_(r1) $node_(r2)] queue]
set tchan_ [open all.q w]
$redq trace curq_
$redq trace ave_
$redq attach $tchan_


$ns at 0.0 "$ftp1 start"
$ns at 3.0 "$ftp2 start"
$ns at 10 "finish"

# Define 'finish' procedure (include post-simulation processes)
proc finish {} {
    global tchan_
    set awkCode {
        {
           if ($1 == "Q" && NF>2) {
              print $2, $3 >> "temp.q";
           }
           else if ($1 == "a" && NF>2)
               print $2, $3 >> "temp.a";
        }
    }
    close $tchan_
    exec awk $awkCode all.q
    
    exit 0
}

$ns run

