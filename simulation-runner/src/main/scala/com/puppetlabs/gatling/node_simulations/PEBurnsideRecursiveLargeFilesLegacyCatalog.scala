package com.puppetlabs.gatling.node_simulations
import com.puppetlabs.gatling.runner.SimulationWithScenario
import org.joda.time.LocalDateTime
import org.joda.time.format.ISODateTimeFormat
import java.util.UUID

import scala.concurrent.duration._

import io.gatling.core.Predef._
import io.gatling.http.Predef._
// import io.gatling.jdbc.Predef._

class PEBurnsideRecursiveLargeFilesLegacyCatalog extends SimulationWithScenario {

// 	val httpProtocol = http
// 		.baseURL("https://${node}:8140")

	val reportBody = ELFileBody("PEBurnsideRecursiveLargeFilesLegacyCatalog_0036_request.txt")

	val headers_0 = Map(
		"Accept" -> "pson, yaml, binary",
		"X-Puppet-Version" -> "4.4.0")

	val headers_3 = Map(
		"Accept" -> "pson, yaml, dot, binary",
		"X-Puppet-Version" -> "4.4.0")

	val headers_36 = Map(
		"Accept" -> "pson, yaml",
		"Content-Type" -> "text/pson",
		"X-Puppet-Version" -> "4.4.0",
	  "Connection" -> "close")
// val uri1 = "https://${node}:8140/puppet/v3"

	val scn = scenario("PEBurnsideRecursiveLargeFilesLegacyCatalog")
		.exec(http("node")
			.get("/puppet/v3/node/${node}?environment=production&transaction_uuid=9079a10f-a195-4de7-80e6-fe43d0ce335e&fail_on_404=true")
			.headers(headers_0))
		.exec(http("filemeta pluginfacts")
			.get("/puppet/v3/file_metadatas/pluginfacts?environment=production&links=follow&recurse=true&source_permissions=use&ignore=.svn&ignore=CVS&ignore=.git&checksum_type=md5")
			.headers(headers_0))
		.exec(http("filemeta plugins")
			.get("/puppet/v3/file_metadatas/plugins?environment=production&links=follow&recurse=true&source_permissions=ignore&ignore=.svn&ignore=CVS&ignore=.git&checksum_type=md5")
			.headers(headers_0))
		.pause(218 milliseconds)
		.exec(http("catalog")
			.post("/puppet/v3/catalog/${node}?environment=production")
			.headers(headers_3)
			.formParam("environment", "production")
			.formParam("facts_format", "pson")
			.formParam("facts", "%7B%22name%22%3A%22${node}%22%2C%22values%22%3A%7B%22aio_agent_build%22%3A%221.3.5.328.g7a3dae3%22%2C%22aio_agent_version%22%3A%221.3.5.328%22%2C%22architecture%22%3A%22x86_64%22%2C%22augeas%22%3A%7B%22version%22%3A%221.4.0%22%7D%2C%22augeasversion%22%3A%221.4.0%22%2C%22bios_release_date%22%3A%2209%2F01%2F2013%22%2C%22bios_vendor%22%3A%22HP%22%2C%22bios_version%22%3A%22P80%22%2C%22blockdevice_sda_model%22%3A%22LOGICAL+VOLUME%22%2C%22blockdevice_sda_size%22%3A1000171331584%2C%22blockdevice_sda_vendor%22%3A%22HP%22%2C%22blockdevice_sdb_model%22%3A%22LOGICAL+VOLUME%22%2C%22blockdevice_sdb_size%22%3A300035497984%2C%22blockdevice_sdb_vendor%22%3A%22HP%22%2C%22blockdevices%22%3A%22sda%2Csdb%22%2C%22chassistype%22%3A%22Rack+Mount+Chassis%22%2C%22custom_auth_conf%22%3Afalse%2C%22dhcp_servers%22%3A%7B%22eth0%22%3A%2210.0.22.10%22%2C%22system%22%3A%2210.0.22.10%22%7D%2C%22disks%22%3A%7B%22sda%22%3A%7B%22model%22%3A%22LOGICAL+VOLUME%22%2C%22size%22%3A%22931.48+GiB%22%2C%22size_bytes%22%3A1000171331584%2C%22vendor%22%3A%22HP%22%7D%2C%22sdb%22%3A%7B%22model%22%3A%22LOGICAL+VOLUME%22%2C%22size%22%3A%22279.43+GiB%22%2C%22size_bytes%22%3A300035497984%2C%22vendor%22%3A%22HP%22%7D%7D%2C%22dmi%22%3A%7B%22bios%22%3A%7B%22release_date%22%3A%2209%2F01%2F2013%22%2C%22vendor%22%3A%22HP%22%2C%22version%22%3A%22P80%22%7D%2C%22chassis%22%3A%7B%22type%22%3A%22Rack+Mount+Chassis%22%7D%2C%22manufacturer%22%3A%22HP%22%2C%22product%22%3A%7B%22name%22%3A%22ProLiant+DL320e+Gen8+v2%22%2C%22serial_number%22%3A%22USE346L7E4%22%2C%22uuid%22%3A%2237323233-3135-5553-4533-34364C374534%22%7D%7D%2C%22domain%22%3A%22delivery.puppetlabs.net%22%2C%22facterversion%22%3A%223.1.5%22%2C%22filesystems%22%3A%22ext4%2Ciso9660%22%2C%22fqdn%22%3A%22${node}%22%2C%22gid%22%3A%22root%22%2C%22hardwareisa%22%3A%22x86_64%22%2C%22hardwaremodel%22%3A%22x86_64%22%2C%22hostname%22%3A%22perf-bl15%22%2C%22id%22%3A%22root%22%2C%22identity%22%3A%7B%22gid%22%3A0%2C%22group%22%3A%22root%22%2C%22uid%22%3A0%2C%22user%22%3A%22root%22%7D%2C%22interfaces%22%3A%22eth0%2Ceth1%2Clo%22%2C%22ipaddress%22%3A%2210.0.150.33%22%2C%22ipaddress6%22%3A%22fe80%3A%3A8634%3A97ff%3Afe11%3Ad0a0%22%2C%22ipaddress6_eth0%22%3A%22fe80%3A%3A8634%3A97ff%3Afe11%3Ad0a0%22%2C%22ipaddress6_lo%22%3A%22%3A%3A1%22%2C%22ipaddress_eth0%22%3A%2210.0.150.33%22%2C%22ipaddress_lo%22%3A%22127.0.0.1%22%2C%22is_pe%22%3Afalse%2C%22is_virtual%22%3Afalse%2C%22kernel%22%3A%22Linux%22%2C%22kernelmajversion%22%3A%222.6%22%2C%22kernelrelease%22%3A%222.6.32-358.el6.x86_64%22%2C%22kernelversion%22%3A%222.6.32%22%2C%22load_averages%22%3A%7B%2215m%22%3A0.17%2C%221m%22%3A0.74%2C%225m%22%3A0.34%7D%2C%22macaddress%22%3A%2284%3A34%3A97%3A11%3Ad0%3Aa0%22%2C%22macaddress_eth0%22%3A%2284%3A34%3A97%3A11%3Ad0%3Aa0%22%2C%22macaddress_eth1%22%3A%2284%3A34%3A97%3A11%3Ad0%3Aa1%22%2C%22manufacturer%22%3A%22HP%22%2C%22memory%22%3A%7B%22swap%22%3A%7B%22available%22%3A%22251.88+MiB%22%2C%22available_bytes%22%3A264110080%2C%22capacity%22%3A%2274.81%25%22%2C%22total%22%3A%22999.99+MiB%22%2C%22total_bytes%22%3A1048567808%2C%22used%22%3A%22748.12+MiB%22%2C%22used_bytes%22%3A784457728%7D%2C%22system%22%3A%7B%22available%22%3A%223.66+GiB%22%2C%22available_bytes%22%3A3926396928%2C%22capacity%22%3A%2251.39%25%22%2C%22total%22%3A%227.52+GiB%22%2C%22total_bytes%22%3A8077553664%2C%22used%22%3A%223.87+GiB%22%2C%22used_bytes%22%3A4151156736%7D%7D%2C%22memoryfree%22%3A%223.66+GiB%22%2C%22memoryfree_mb%22%3A3744.50390625%2C%22memorysize%22%3A%227.52+GiB%22%2C%22memorysize_mb%22%3A7703.35546875%2C%22mountpoints%22%3A%7B%22%2F%22%3A%7B%22available%22%3A%22265.03+GiB%22%2C%22available_bytes%22%3A284575420416%2C%22capacity%22%3A%223.23%25%22%2C%22device%22%3A%22%2Fdev%2Fsdb3%22%2C%22filesystem%22%3A%22ext4%22%2C%22options%22%3A%5B%22rw%22%5D%2C%22size%22%3A%22273.89+GiB%22%2C%22size_bytes%22%3A294086156288%2C%22used%22%3A%228.86+GiB%22%2C%22used_bytes%22%3A9510735872%7D%2C%22%2Fboot%22%3A%7B%22available%22%3A%22162.38+MiB%22%2C%22available_bytes%22%3A170267648%2C%22capacity%22%3A%2216.16%25%22%2C%22device%22%3A%22%2Fdev%2Fsdb1%22%2C%22filesystem%22%3A%22ext4%22%2C%22options%22%3A%5B%22rw%22%5D%2C%22size%22%3A%22193.69+MiB%22%2C%22size_bytes%22%3A203097088%2C%22used%22%3A%2231.31+MiB%22%2C%22used_bytes%22%3A32829440%7D%2C%22%2Fdata%22%3A%7B%22available%22%3A%22732.56+GiB%22%2C%22available_bytes%22%3A786583207936%2C%22capacity%22%3A%2220.10%25%22%2C%22device%22%3A%22%2Fdev%2Fsda1%22%2C%22filesystem%22%3A%22ext4%22%2C%22options%22%3A%5B%22rw%22%5D%2C%22size%22%3A%22916.86+GiB%22%2C%22size_bytes%22%3A984475844608%2C%22used%22%3A%22184.30+GiB%22%2C%22used_bytes%22%3A197892636672%7D%7D%2C%22mtu_eth0%22%3A1500%2C%22mtu_eth1%22%3A1500%2C%22mtu_lo%22%3A16436%2C%22netmask%22%3A%22255.255.255.0%22%2C%22netmask6%22%3A%22ffff%3Affff%3Affff%3Affff%3A%3A%22%2C%22netmask6_eth0%22%3A%22ffff%3Affff%3Affff%3Affff%3A%3A%22%2C%22netmask6_lo%22%3A%22ffff%3Affff%3Affff%3Affff%3Affff%3Affff%3Affff%3Affff%22%2C%22netmask_eth0%22%3A%22255.255.255.0%22%2C%22netmask_lo%22%3A%22255.0.0.0%22%2C%22network%22%3A%2210.0.150.0%22%2C%22network6%22%3A%22fe80%3A%3A%22%2C%22network6_eth0%22%3A%22fe80%3A%3A%22%2C%22network6_lo%22%3A%22%3A%3A1%22%2C%22network_eth0%22%3A%2210.0.150.0%22%2C%22network_lo%22%3A%22127.0.0.0%22%2C%22networking%22%3A%7B%22dhcp%22%3A%2210.0.22.10%22%2C%22domain%22%3A%22delivery.puppetlabs.net%22%2C%22fqdn%22%3A%22${node}%22%2C%22hostname%22%3A%22perf-bl15%22%2C%22interfaces%22%3A%7B%22eth0%22%3A%7B%22bindings%22%3A%5B%7B%22address%22%3A%2210.0.150.33%22%2C%22netmask%22%3A%22255.255.255.0%22%2C%22network%22%3A%2210.0.150.0%22%7D%5D%2C%22bindings6%22%3A%5B%7B%22address%22%3A%22fe80%3A%3A8634%3A97ff%3Afe11%3Ad0a0%22%2C%22netmask%22%3A%22ffff%3Affff%3Affff%3Affff%3A%3A%22%2C%22network%22%3A%22fe80%3A%3A%22%7D%5D%2C%22dhcp%22%3A%2210.0.22.10%22%2C%22ip%22%3A%2210.0.150.33%22%2C%22ip6%22%3A%22fe80%3A%3A8634%3A97ff%3Afe11%3Ad0a0%22%2C%22mac%22%3A%2284%3A34%3A97%3A11%3Ad0%3Aa0%22%2C%22mtu%22%3A1500%2C%22netmask%22%3A%22255.255.255.0%22%2C%22netmask6%22%3A%22ffff%3Affff%3Affff%3Affff%3A%3A%22%2C%22network%22%3A%2210.0.150.0%22%2C%22network6%22%3A%22fe80%3A%3A%22%7D%2C%22eth1%22%3A%7B%22mac%22%3A%2284%3A34%3A97%3A11%3Ad0%3Aa1%22%2C%22mtu%22%3A1500%7D%2C%22lo%22%3A%7B%22bindings%22%3A%5B%7B%22address%22%3A%22127.0.0.1%22%2C%22netmask%22%3A%22255.0.0.0%22%2C%22network%22%3A%22127.0.0.0%22%7D%5D%2C%22bindings6%22%3A%5B%7B%22address%22%3A%22%3A%3A1%22%2C%22netmask%22%3A%22ffff%3Affff%3Affff%3Affff%3Affff%3Affff%3Affff%3Affff%22%2C%22network%22%3A%22%3A%3A1%22%7D%5D%2C%22ip%22%3A%22127.0.0.1%22%2C%22ip6%22%3A%22%3A%3A1%22%2C%22mtu%22%3A16436%2C%22netmask%22%3A%22255.0.0.0%22%2C%22netmask6%22%3A%22ffff%3Affff%3Affff%3Affff%3Affff%3Affff%3Affff%3Affff%22%2C%22network%22%3A%22127.0.0.0%22%2C%22network6%22%3A%22%3A%3A1%22%7D%7D%2C%22ip%22%3A%2210.0.150.33%22%2C%22ip6%22%3A%22fe80%3A%3A8634%3A97ff%3Afe11%3Ad0a0%22%2C%22mac%22%3A%2284%3A34%3A97%3A11%3Ad0%3Aa0%22%2C%22mtu%22%3A1500%2C%22netmask%22%3A%22255.255.255.0%22%2C%22netmask6%22%3A%22ffff%3Affff%3Affff%3Affff%3A%3A%22%2C%22network%22%3A%2210.0.150.0%22%2C%22network6%22%3A%22fe80%3A%3A%22%2C%22primary%22%3A%22eth0%22%7D%2C%22operatingsystem%22%3A%22CentOS%22%2C%22operatingsystemmajrelease%22%3A%226%22%2C%22operatingsystemrelease%22%3A%226.4%22%2C%22os%22%3A%7B%22architecture%22%3A%22x86_64%22%2C%22family%22%3A%22RedHat%22%2C%22hardware%22%3A%22x86_64%22%2C%22name%22%3A%22CentOS%22%2C%22release%22%3A%7B%22full%22%3A%226.4%22%2C%22major%22%3A%226%22%2C%22minor%22%3A%224%22%7D%2C%22selinux%22%3A%7B%22enabled%22%3Afalse%7D%7D%2C%22osfamily%22%3A%22RedHat%22%2C%22partitions%22%3A%7B%22%2Fdev%2Fsda1%22%3A%7B%22filesystem%22%3A%22ext4%22%2C%22mount%22%3A%22%2Fdata%22%2C%22size%22%3A%22931.48+GiB%22%2C%22size_bytes%22%3A1000169537536%2C%22uuid%22%3A%22ec82ddf9-8487-40fe-b0f2-3680ea282165%22%7D%2C%22%2Fdev%2Fsdb1%22%3A%7B%22filesystem%22%3A%22ext4%22%2C%22mount%22%3A%22%2Fboot%22%2C%22size%22%3A%22200.00+MiB%22%2C%22size_bytes%22%3A209715200%2C%22uuid%22%3A%221b1e3fbc-e89d-4f73-a231-aff346fb9b19%22%7D%2C%22%2Fdev%2Fsdb2%22%3A%7B%22filesystem%22%3A%22swap%22%2C%22size%22%3A%221000.00+MiB%22%2C%22size_bytes%22%3A1048576000%2C%22uuid%22%3A%2259476f00-d086-46aa-bc82-03da1ba9f5c8%22%7D%2C%22%2Fdev%2Fsdb3%22%3A%7B%22filesystem%22%3A%22ext4%22%2C%22mount%22%3A%22%2F%22%2C%22size%22%3A%22278.26+GiB%22%2C%22size_bytes%22%3A298776002560%2C%22uuid%22%3A%2263078947-8c98-47d3-8e95-bdce75c13308%22%7D%7D%2C%22path%22%3A%22%2Fusr%2Flocal%2Fsbin%3A%2Fusr%2Flocal%2Fbin%3A%2Fsbin%3A%2Fbin%3A%2Fusr%2Fsbin%3A%2Fusr%2Fbin%3A%2Fopt%2Fpuppetlabs%2Fbin%3A%2Froot%2Fbin%22%2C%22pe_build%22%3A%222016.1.0-rc2-420-gb432a65%22%2C%22pe_concat_basedir%22%3A%22%2Fopt%2Fpuppetlabs%2Fpuppet%2Fcache%2Fpe_concat%22%2C%22pe_razor_server_version%22%3A%22package+pe-razor-server+is+not+installed%22%2C%22pe_server_version%22%3A%222016.1.0%22%2C%22physicalprocessorcount%22%3A1%2C%22platform_symlink_writable%22%3Atrue%2C%22platform_tag%22%3A%22el-6-x86_64%22%2C%22processor0%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22processor1%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22processor2%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22processor3%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22processor4%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22processor5%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22processor6%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22processor7%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22processorcount%22%3A8%2C%22processors%22%3A%7B%22count%22%3A8%2C%22isa%22%3A%22x86_64%22%2C%22models%22%3A%5B%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%5D%2C%22physicalcount%22%3A1%2C%22speed%22%3A%223.60+GHz%22%7D%2C%22productname%22%3A%22ProLiant+DL320e+Gen8+v2%22%2C%22puppet_files_dir_present%22%3Afalse%2C%22puppetversion%22%3A%224.4.0%22%2C%22ruby%22%3A%7B%22platform%22%3A%22x86_64-linux%22%2C%22sitedir%22%3A%22%2Fopt%2Fpuppetlabs%2Fpuppet%2Flib%2Fruby%2Fsite_ruby%2F2.1.0%22%2C%22version%22%3A%222.1.8%22%7D%2C%22rubyplatform%22%3A%22x86_64-linux%22%2C%22rubysitedir%22%3A%22%2Fopt%2Fpuppetlabs%2Fpuppet%2Flib%2Fruby%2Fsite_ruby%2F2.1.0%22%2C%22rubyversion%22%3A%222.1.8%22%2C%22selinux%22%3Afalse%2C%22serialnumber%22%3A%22USE346L7E4%22%2C%22ssh%22%3A%7B%22dsa%22%3A%7B%22fingerprints%22%3A%7B%22sha1%22%3A%22SSHFP+2+1+7d6061c998ba699a8e51eef0384069b76091168d%22%2C%22sha256%22%3A%22SSHFP+2+2+1f5570d926e57a9beea1780282973b354c8a1c15e73eec9f2e70fa289210a2c2%22%7D%2C%22key%22%3A%22AAAAB3NzaC1kc3MAAACBANaCQKq1NRWXTjgY1SpPj56YcITGHJIS%2BfxNBvQn3FZ%2BnJcmAnE4y1VNYWOj%2FJVGFgaQqnOe20b%2Bkhp3%2F27g9bWAi3F7nwngEoixvAsmr7qRt7kRouizxRqljvRx9Wwa9XJ9RCfGu9ym5I1D%2B7z%2FixiXo9C2k2OdBhjdT77E7fCxAAAAFQDWxZ2OcdBEXnvxv%2F0W0VHzztu9jQAAAIAn9nrqt05XkvFsb2OZTRxQ3guMWcYFG1dZUuUltOYRWxZCbWz%2B23tocv6RgJnKTRAHEh8d9dss78V6q8RbApVx%2B%2FzT8UzkRs7oFSdc5wJH49SRu481DIYAtkFo%2BkKn%2B1tTsPB8LyOCsHtmsCrFTvYz3vVCD31mQczZDGfBrl08JQAAAIEAjOBI0AXk81UAyJj5owVGQhFrZRZADbsMTZ23r%2Bj%2FXVPAv8NGrO4EHjdr6T0c0Lnj9wPiediTMDyMWr%2FdaDvKXD7C3jOoIy3EyVQuheQfEhBKuggaITVKKGm07jXzunflnCjf0cotNlPazTaJWg1fl4AwDR7%2BNPVlLGNpWe2qMvc%3D%22%7D%2C%22rsa%22%3A%7B%22fingerprints%22%3A%7B%22sha1%22%3A%22SSHFP+1+1+f1609a8aee4ebeb8488b6324f59af71373247786%22%2C%22sha256%22%3A%22SSHFP+1+2+12679aac10ee1656f772aba805c02e6845dc7e265bc6fc230cb0371221f5e62f%22%7D%2C%22key%22%3A%22AAAAB3NzaC1yc2EAAAABIwAAAQEAuwS9UODBuSGvbXkp4y0%2FS6eqkfHb4uD6ZDOdJNwjS1pRy6pAvFZY7XQ5AUIVx%2F%2FWY%2BsgsXMhiZf%2Fs%2BLDXPrdaXZV%2F92pmbV4BfXcAPi0JKvZEJi1uTOrCrWJa9yYI6XCkLmRcdj1PoKlHzD%2BwgTxYjkPHFddkNaHxxyRHPcvYXIXSy0f1%2BYshbJ9w1wI2QP2r2NWOBqTXBZYmI41DHS65wbsvoisgEAYTQ9%2BknDJ4nCha9jGMEi5OcBMdpP2JNt8D5qxyYD60ynd3CzeZgcAXNE3laHcs7YhJrR1N1nk%2FCDcGgMZmCjrCnowLqAbwkaX1opFW288haZJOIf3%2Fq5E2Q%3D%3D%22%7D%7D%2C%22sshdsakey%22%3A%22AAAAB3NzaC1kc3MAAACBANaCQKq1NRWXTjgY1SpPj56YcITGHJIS%2BfxNBvQn3FZ%2BnJcmAnE4y1VNYWOj%2FJVGFgaQqnOe20b%2Bkhp3%2F27g9bWAi3F7nwngEoixvAsmr7qRt7kRouizxRqljvRx9Wwa9XJ9RCfGu9ym5I1D%2B7z%2FixiXo9C2k2OdBhjdT77E7fCxAAAAFQDWxZ2OcdBEXnvxv%2F0W0VHzztu9jQAAAIAn9nrqt05XkvFsb2OZTRxQ3guMWcYFG1dZUuUltOYRWxZCbWz%2B23tocv6RgJnKTRAHEh8d9dss78V6q8RbApVx%2B%2FzT8UzkRs7oFSdc5wJH49SRu481DIYAtkFo%2BkKn%2B1tTsPB8LyOCsHtmsCrFTvYz3vVCD31mQczZDGfBrl08JQAAAIEAjOBI0AXk81UAyJj5owVGQhFrZRZADbsMTZ23r%2Bj%2FXVPAv8NGrO4EHjdr6T0c0Lnj9wPiediTMDyMWr%2FdaDvKXD7C3jOoIy3EyVQuheQfEhBKuggaITVKKGm07jXzunflnCjf0cotNlPazTaJWg1fl4AwDR7%2BNPVlLGNpWe2qMvc%3D%22%2C%22sshfp_dsa%22%3A%22SSHFP+2+1+7d6061c998ba699a8e51eef0384069b76091168d%5CnSSHFP+2+2+1f5570d926e57a9beea1780282973b354c8a1c15e73eec9f2e70fa289210a2c2%22%2C%22sshfp_rsa%22%3A%22SSHFP+1+1+f1609a8aee4ebeb8488b6324f59af71373247786%5CnSSHFP+1+2+12679aac10ee1656f772aba805c02e6845dc7e265bc6fc230cb0371221f5e62f%22%2C%22sshrsakey%22%3A%22AAAAB3NzaC1yc2EAAAABIwAAAQEAuwS9UODBuSGvbXkp4y0%2FS6eqkfHb4uD6ZDOdJNwjS1pRy6pAvFZY7XQ5AUIVx%2F%2FWY%2BsgsXMhiZf%2Fs%2BLDXPrdaXZV%2F92pmbV4BfXcAPi0JKvZEJi1uTOrCrWJa9yYI6XCkLmRcdj1PoKlHzD%2BwgTxYjkPHFddkNaHxxyRHPcvYXIXSy0f1%2BYshbJ9w1wI2QP2r2NWOBqTXBZYmI41DHS65wbsvoisgEAYTQ9%2BknDJ4nCha9jGMEi5OcBMdpP2JNt8D5qxyYD60ynd3CzeZgcAXNE3laHcs7YhJrR1N1nk%2FCDcGgMZmCjrCnowLqAbwkaX1opFW288haZJOIf3%2Fq5E2Q%3D%3D%22%2C%22staging_http_get%22%3A%22curl%22%2C%22swapfree%22%3A%22251.88+MiB%22%2C%22swapfree_mb%22%3A251.875%2C%22swapsize%22%3A%22999.99+MiB%22%2C%22swapsize_mb%22%3A999.9921875%2C%22system_uptime%22%3A%7B%22days%22%3A4%2C%22hours%22%3A110%2C%22seconds%22%3A396981%2C%22uptime%22%3A%224+days%22%7D%2C%22timezone%22%3A%22PDT%22%2C%22uptime%22%3A%224+days%22%2C%22uptime_days%22%3A4%2C%22uptime_hours%22%3A110%2C%22uptime_seconds%22%3A396981%2C%22uuid%22%3A%2237323233-3135-5553-4533-34364C374534%22%2C%22virtual%22%3A%22physical%22%2C%22clientcert%22%3A%22${node}%22%2C%22clientversion%22%3A%224.4.0%22%2C%22clientnoop%22%3Afalse%7D%2C%22timestamp%22%3A%222016-03-17T11%3A39%3A41.669116912-07%3A00%22%2C%22expiration%22%3A%222025-03-17T12%3A09%3A41.669333199-07%3A00%22%7D")
			.formParam("transaction_uuid", "9079a10f-a195-4de7-80e6-fe43d0ce335e")
			.formParam("static_catalog", "true")
			.formParam("checksum_type", "md5.sha256")
			.formParam("fail_on_404", "true"))
		.pause(3)
		.exec(http("filemeta")
			.get("/puppet/v3/file_metadata/modules/pe_repo/GPG-KEY-puppetlabs?environment=production&links=manage&checksum_type=md5&source_permissions=ignore")
			.headers(headers_0))
		.pause(1)
		.exec(http("filemeta mco plugins")
			.get("/puppet/v3/file_metadatas/modules/puppet_enterprise/mcollective/plugins?environment=production&links=manage&recurse=true&source_permissions=ignore&checksum_type=md5")
			.headers(headers_0))
		.pause(218 milliseconds)
		.exec(http("filemeta")
			.get("/puppet/v3/file_metadatas/modules/recursive_with_large_files/dir_with_large_files?environment=production&links=manage&recurse=true&source_permissions=ignore&checksum_type=md5")
			.headers(headers_0))
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica1.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica10.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica11.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica12.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica13.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica14.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica15.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica16.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica17.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica18.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica19.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica2.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica20.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica21.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica22.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica23.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica24.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica25.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica3.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica4.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica5.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica6.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica7.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica8.pdf?environment=production&"))
		.pause(7)
		.exec(http("file content")
			.get("/puppet/v3/file_content/modules/recursive_with_large_files/dir_with_large_files/faunajaponica9.pdf?environment=production&"))
		.pause(9)
		.exec(http("filemeta")
			.get("/puppet/v3/file_metadata/modules/pe_concat/concatfragments.sh?environment=production&links=manage&checksum_type=md5&source_permissions=ignore")
			.headers(headers_0))
		.pause(683 milliseconds)
		.exec(http("filemeta")
			.get("/puppet/v3/file_metadata/modules/puppet_enterprise/console/dhparam_puppetproxy.pem?environment=production&links=manage&checksum_type=md5&source_permissions=ignore")
			.headers(headers_0))
		.pause(642 milliseconds)
		.exec(http("filemeta")
			.get("/puppet/v3/file_metadata/modules/pe_accounts/shell/bashrc?environment=production&links=manage&checksum_type=md5&source_permissions=ignore")
			.headers(headers_0))
		.exec(http("filemeta")
			.get("/puppet/v3/file_metadata/modules/pe_accounts/shell/bash_profile?environment=production&links=manage&checksum_type=md5&source_permissions=ignore")
			.headers(headers_0))
		.pause(322 milliseconds)
		.exec((session:Session) => {
			session.set("reportTimestamp",
				LocalDateTime.now.toString(ISODateTimeFormat.dateTime()))
		})
		.exec((session:Session) => {
			session.set("transactionUuid",
				UUID.randomUUID().toString())
		})
		.exec(http("report")
			.put("/puppet/v3/report/${node}?environment=production&")
			.headers(headers_36)
			.body(reportBody))
// setUp(scn.inject(atOnceUsers(1))).protocols(httpProtocol)
}