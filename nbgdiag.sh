#!/usr/bin/expect
# Copyright (C) 2013, Andrei Belov <defanator(at)gmail(dot)com>
#
# Zyxel NBG460N-EE sample CLI diagnostic script.
#
# Tested with expect version 5.45 and following NBG460N-EE firmwares:
#  - V3.60(BFL.1) | 07/06/2010
#  - V3.60(BFL.1)D0_20120319 | 03/19/2012
#

proc zcmd {cmd} {
    set timeout 5
    send "$cmd\r"
    expect "> "
}

proc zcmdlong {cmd} {
    set timeout 5
    set crsent 0
    send "$cmd\r"
    expect {
        timeout {
            if { $crsent == 0 } {
                send "\r"
                set crsent 1
            }
            exp_continue
        }
        "> " {}
    }
}

proc zlogin {pass} {
    set timeout 30
    expect "Password: "
    send "$pass\r"
    expect {
        "Password: " {
            puts "\rInvalid password."
            exit 1
        }
        eof {
            puts "\rInvalid password?"
            exit 1
        }
        "> " {}
    }
}

proc zlogout {} {
    send "exit\r"
    expect eof
}

if {[llength $argv] != 3} {
    puts "usage: zyxdiag.sh <host> <port> <password>"
    puts "i.e.: zyxdiag.sh 192.168.1.1 23 \"1234\""
    exit 1
}

spawn telnet [lindex $argv 0] [lindex $argv 1]

zlogin "[lindex $argv 2]"

zcmd "sys ver"
zcmd "sys cpu disp"
zcmd "wlan assoc"
zcmdlong "ip dhcp enif0 sta"
zcmd "ether swi sta"
zcmd "ip arp sta"
zcmd "ip ifconfig"
zcmd "ip sta"
zcmd "ip tcp sta"
zcmd "ip udp sta"
zcmd "ip icmp sta"
zcmd "ip igmp sta"

send "ip route sta\r"
expect {
    -re "default\x20+\[0-9]+\x20\[0-9]+\x20+enet.\x20+(\[0-9.]+)" {
        set gateway $expect_out(1,string)
        exp_continue
    }
    "> " {}
}

if [ info exists gateway ] {
    zcmd "ip ping $gateway"
} else {
    puts "WARNING: could not get default gateway"
}

zcmdlong "ip nat hashTable enif1"
zcmdlong "sys tos listPerHost"
zcmdlong "sys tos disp"

zlogout
