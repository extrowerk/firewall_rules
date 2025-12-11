macro ENABLE_LO:
# ------------------------------------------------------------------------
# Loopback interface (no restrictions)
# ------------------------------------------------------------------------
pass in quick on lo0 all
pass out quick on lo0 all
end


macro ENABLE_DNS:
# ------------------------------------------------------------------------
# DNS - Allow outbound access to DNS servers (TCP/UDP port 53)
# ------------------------------------------------------------------------
# To the default router
pass out quick on $ext_if proto tcp from $my_IP to $defrouter_IP port = 53 flags S keep state
pass out quick on $ext_if proto udp from $my_IP to $defrouter_IP port = 53 keep state
# To DNS server
pass out quick on $ext_if proto tcp from $my_IP to $dns_IP port = 53 flags S keep state
pass out quick on $ext_if proto udp from $my_IP to $dns_IP port = 53 keep state
end


macro ENABLE_NTP:
# ------------------------------------------------------------------------
# NTP - Allow outbound access for NTP (port 123)
# ------------------------------------------------------------------------
pass out quick on $ext_if proto udp from $my_IP to any port = 123 keep state
end


macro ENABLE_PING_OUT:
# ------------------------------------------------------------------------
# Ping - Allow ICMP echo requests (ping)
# ------------------------------------------------------------------------
pass out quick on $ext_if proto icmp from $my_IP to any icmp-type 8 keep state
end


macro ALLOW_INCOMING:
# ------------------------------------------------------------------------
# Allow inbound traffic
# ------------------------------------------------------------------------
pass in quick on $ext_if proto ${proto} from any to port = ${port} keep state ${application}
end


macro ALLOW_OUTBOUND:
# ------------------------------------------------------------------------
# Allow outbound traffic
# ------------------------------------------------------------------------
pass out quick on $ext_if proto ${proto} from $my_IP to $target_IP port = ${port} keep state ${application}
end


macro BLOCK_OUT:
# ------------------------------------------------------------------------
# Block and log everything else
# ------------------------------------------------------------------------
block out log first quick on $ext_if all
end
