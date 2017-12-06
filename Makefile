ISODIR=iso
ISOPATH=${ISODIR}/SL-7-DVD-x86_64.iso
ISOURL=http://ftp1.scientificlinux.org/linux/scientific/7.0/x86_64/iso/SL-7-x86_64-Everything-Dual-Layer-DVD.iso

iso: ${ISOPATH}

isodir: 
	mkdir -p ${ISODIR}

${ISOPATH}: isodir
	wget -c -O ${ISOPATH} ${ISOURL}

all: iso
