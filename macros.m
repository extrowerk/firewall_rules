macro ALLOW_LO:
# Loopback interface (no restrictions)
pass in quick on lo0 all
pass out quick on lo0 all
end

macro ALLOW_DNS_OUT:
# DNS - Allow outbound access to DNS servers
# To the default router
pass out quick on $ext_if proto tcp from $my_IP to $defrouter_IP port = 53 flags S keep state
pass out quick on $ext_if proto udp from $my_IP to $defrouter_IP port = 53 keep state
# To DNS server
pass out quick on $ext_if proto tcp from $my_IP to $dns_IP port = 53 flags S keep state
pass out quick on $ext_if proto udp from $my_IP to $dns_IP port = 53 keep state
end

macro ALLOW_NTP_OUT:
# NTP - Allow outbound access for NTP
pass out quick on $ext_if proto udp from $my_IP to any port = 123 keep state
end

macro ALLOW_PING_OUT:
# Allow ICMP echo requests
pass out quick on $ext_if proto icmp from $my_IP to any icmp-type 8 keep state
end

macro ALLOW_PING_IN:
# Allow ICMP echo requests
pass in quick on $ext_if proto icmp all icmp-type 8 keep state
end

macro ALLOW_SSH_IN:
# Allow SSH in
pass in quick on $ext_if proto tcp from ${from_IP} to any port = 22 flags S keep state
end

macro ALLOW_SSH_OUT:
# Allow SSH out
pass out quick on $ext_if proto tcp from any to any port = 22 flags S keep state
end

macro ALLOW_ICMPv6_OUT:
# Allow ICMPv6 out
pass out quick proto ipv6-icmp from any to any
end

macro ALLOW_ICMPv6_IN:
# Allow ICMPv6 in
pass in quick proto ipv6-icmp from any to any
end

macro ALLOW_DHCPv6_OUT:
# Allow DHCPv6 out
pass out quick on $ext_if proto udp from any to any port = 547 keep state
end

macro ALLOW_DHCPv6_IN:
# Allow DHCPv6 in
pass in quick proto udp from any to any port = 546 keep state
end

macro ALLOW_INBOUND:
# Allow inbound traffic
pass in quick on $ext_if proto ${proto} from any to port = ${port} keep state ${application}
end

macro ALLOW_OUTBOUND:
# Allow outbound traffic
pass out quick on $ext_if proto ${proto} from $my_IP to port = ${port} keep state ${application}
end

macro ALLOW_INBOUND_RANGE:
# Allow inbound port range
pass in quick on $ext_if proto ${proto} from any to port ${port_range} keep state ${application}
end

macro ALLOW_OUTBOUND_RANGE:
# Allow outbound port range
pass out quick on $ext_if proto ${proto} from $my_IP to port ${port_range} keep state ${application}
end

macro ALLOW_OUTBOUND_ANY_PORT:
# Allow outbound traffic
pass out quick on $ext_if proto ${proto} from $my_IP keep state ${application}
end

macro BLOCK_STRANGE:
# Block fragments and too short tcp packets
block in quick on $ext_if all with frags
block in quick on $ext_if proto tcp all with short
# Block source routed packets
block in quick on $ext_if all with opt lsrr
block in quick on $ext_if all with opt ssrr
# Block OS fingerprint attempts and log first occurrence
block in log first quick on $ext_if proto tcp from any to any flags FUP
# Block anything with special options
block in quick on $ext_if all with ipopts
# Block ident
block in quick on $ext_if proto tcp from any to any port = 113
# Block incoming Netbios services
block in log first quick on $ext_if proto tcp/udp from any to any port = 137
block in log first quick on $ext_if proto tcp/udp from any to any port = 138
block in log first quick on $ext_if proto tcp/udp from any to any port = 139
block in log first quick on $ext_if proto tcp/udp from any to any port = 81
end

macro BLOCK_OUT:
# Block and log everything else
block out log first quick on $ext_if all
end
