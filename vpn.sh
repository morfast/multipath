ip addr | grep -q tun0
if [ $? -eq 0 ]; then
    echo "tun0 already connected"
    exit 0
fi

cd /root/openvpn/test
openvpn --config test1.ovpn &> /tmp/ovpn.log &
cd -

while :
do
    ip addr | grep -q tun0
    if [ $? -eq 0 ]; then
        echo "tun0 connected"
        break
    fi
    sleep 1
done
