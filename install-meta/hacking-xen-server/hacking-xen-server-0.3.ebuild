# Copyright 2012 Hacking Networked Solutions
# Distributed under the terms of the GNU General Public License v3
# $Header: $

EAPI="3"

DESCRIPTION="Hacking Networked Solutions Xen host meta-package"
HOMEPAGE="http://www.hacking.co.uk/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="${DEPEND}
	install-meta/hacking-base-server
	app-emulation/xen
	app-emulation/xen-tools
	app-emulation/xen-vif-hacking
	net-firewall/iptables
	net-misc/bird
	snmp-agents/snmpd-mdraid-connector
	snmp-agents/snmpd-smartctl-connector
	sys-apps/gptfdisk
	sys-apps/hdparm
	sys-apps/lm_sensors
	sys-apps/pciutils
	sys-apps/smartmontools
	sys-boot/grub
	sys-boot/last-known-good
	sys-fs/lvm2
	sys-fs/mdadm"
