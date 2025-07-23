random() {
	tr </dev/urandom -dc A-Za-z0-9 | head -c5
	echo
}

gen64() {
	# Tạo random hex cho IPv6
	hex_random() {
		printf "%04x" $((RANDOM % 65536))
	}
	echo "$1:$(hex_random):$(hex_random):$(hex_random):$(hex_random)"
}
