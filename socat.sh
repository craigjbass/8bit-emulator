socat -d -d pty,raw,echo=0 pty,raw,echo=0
sudo cat /dev/ttyS3 | tee /dev/pts/1
sudo cat /dev/pts/1 | tee /dev/ttyS3 | xxd -b -c 1
