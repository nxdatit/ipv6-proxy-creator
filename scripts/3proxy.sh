detect_interface() {
    # Tìm interface mạng chính
    INTERFACE=$(ip route | grep default | awk 'NR==1{print $5}')
    if [ -z "$INTERFACE" ]; then
        INTERFACE=$(ls /sys/class/net/ | grep -v lo | head -1)
    fi
    echo $INTERFACE
}

install_3proxy() {
    echo "installing 3proxy"
    URL="https://github.com/z3APA3A/3proxy/archive/0.9.4.tar.gz"
    wget -qO- $URL | bsdtar -xvf-
    cd 3proxy-0.9.4
    make -f Makefile.Linux
    mkdir -p /usr/local/etc/3proxy/{bin,logs,stat}
    cp bin/3proxy /usr/local/etc/3proxy/bin/
    cp ./scripts/init.d/3proxy.sh /etc/init.d/3proxy
    # Sửa đường dẫn 3proxy trong service script
    sed -i 's|/bin/3proxy|/usr/local/etc/3proxy/bin/3proxy|g' /etc/init.d/3proxy
    sed -i 's|DAEMON=.*|DAEMON=/usr/local/etc/3proxy/bin/3proxy|g' /etc/init.d/3proxy
    chmod +x /etc/init.d/3proxy
    chkconfig 3proxy on
    cd $WORKDIR
}

gen_3proxy() {
    cat <<EOF
daemon
maxconn 1000
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
setgid 65535
setuid 65535
flush
auth strong

users $(awk -F "/" 'BEGIN{ORS="";} {print $1 ":CL:" $2 " "}' ${WORKDATA})

$(awk -F "/" '{print "auth strong\n" \
"allow " $1 "\n" \
"socks -6 -n -a -p" $4 " -i" $3 " -e" $5 "\n" \
"flush\n"}' ${WORKDATA})
EOF
}

gen_proxy_file_for_user() {
    cat >proxy.txt <<EOF
$(awk -F "/" '{print $3 ":" $4 ":" $1 ":" $2 }' ${WORKDATA})
EOF
}

upload_proxy() {
    local PASS=$(random)
    zip --password $PASS proxy.zip proxy.txt
    URL=$(curl -s --upload-file proxy.zip https://transfer.sh/proxy.zip)

    echo "Proxy is ready! Format IP:PORT:LOGIN:PASS"
    echo "Download zip archive from: ${URL}"
    echo "Password: ${PASS}"

}
gen_data() {
    seq $FIRST_PORT $LAST_PORT | while read port; do
        echo "usr$(random)/pass$(random)/$IP4/$port/$(gen64 "$IP6")"
    done
}

gen_iptables() {
    cat <<EOF
    $(awk -F "/" '{print "iptables -I INPUT -p tcp --dport " $4 "  -m state --state NEW -j ACCEPT"}' ${WORKDATA}) 
EOF
}

gen_ifconfig() {
    MAIN_INTERFACE=$(detect_interface)
    cat <<EOF
$(awk -F "/" -v iface="$MAIN_INTERFACE" '{print "ifconfig " iface " inet6 add " $5 "/64"}' ${WORKDATA})
EOF
}
