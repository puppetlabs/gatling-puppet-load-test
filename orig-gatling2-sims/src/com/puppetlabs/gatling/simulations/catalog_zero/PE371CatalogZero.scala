package com.puppetlabs.gatling.simulations.catalog_zero



import scala.concurrent.duration._

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._
import io.gatling.core.structure.{ChainBuilder}

class PE371CatalogZero extends Simulation {

	val httpProtocol = http
		.baseURL("https://puppet-master:8140")
		.inferHtmlResources()
		.acceptHeader("""pson, b64_zlib_yaml, yaml, raw""")
		.acceptEncodingHeader("""identity""")
		.contentTypeHeader("""application/x-www-form-urlencoded""")
		.userAgentHeader("""Ruby""")

	val headers_3 = Map("""Accept""" -> """pson, b64_zlib_yaml, yaml, dot, raw""")

	val headers_106 = Map(
		"""Accept""" -> """pson, yaml""",
		"""Content-Type""" -> """text/pson""")

    val uri1 = """https://puppet-master:8140/production"""

	val chain_0 = 	exec(http("node")
		  .get("""/production/node/perf-bl16.performance.delivery.puppetlabs.net?transaction_uuid=391529e8-4da8-4643-8a2f-3e9c101947a1&fail_on_404=true""")
		  .resources(http("filemeta_plugin_facts")
		    .get(uri1 + """/file_metadatas/pluginfacts?links=manage&recurse=true&ignore=.svn&ignore=CVS&ignore=.git&checksum_type=md5"""),
                    http("filemeta_plugins")
	      .get(uri1 + """/file_metadatas/plugins?links=manage&recurse=true&ignore=.svn&ignore=CVS&ignore=.git&checksum_type=md5"""),
                    http("catalog")
	      .post(uri1 + """/catalog/perf-bl16.performance.delivery.puppetlabs.net""")
	      .headers(headers_3)
	      .formParam("""fail_on_404""", """true""")
	      .formParam("""transaction_uuid""", """d1d0fd05-7247-4b0f-ba9c-540593b13f85""")
	      .formParam("""facts""", """%7B%22name%22%3A%22perf-bl16.performance.delivery.puppetlabs.net%22%2C%22values%22%3A%7B%22virtual%22%3A%22physical%22%2C%22is_virtual%22%3A%22false%22%2C%22id%22%3A%22root%22%2C%22operatingsystem%22%3A%22CentOS%22%2C%22hostname%22%3A%22perf-bl16%22%2C%22puppetversion%22%3A%223.7.1%2B%28Puppet%2BEnterprise%2B3.4.0%29%22%2C%22filesystems%22%3A%22ext4%2Ciso9660%22%2C%22osfamily%22%3A%22RedHat%22%2C%22kernelrelease%22%3A%222.6.32-431.23.3.el6.x86_64%22%2C%22kernel%22%3A%22Linux%22%2C%22bios_vendor%22%3A%22HP%22%2C%22bios_version%22%3A%22P80%22%2C%22bios_release_date%22%3A%2209%2F01%2F2013%22%2C%22manufacturer%22%3A%22HP%22%2C%22productname%22%3A%22ProLiant%2BDL320e%2BGen8%2Bv2%22%2C%22serialnumber%22%3A%22USE346L3KS%22%2C%22uuid%22%3A%2233323237-3531-5355-4533-34364C334B53%22%2C%22type%22%3A%22Rack%2BMount%2BChassis%22%2C%22uniqueid%22%3A%2200000000%22%2C%22timezone%22%3A%22PDT%22%2C%22ipaddress%22%3A%2210.16.150.34%22%2C%22netmask%22%3A%22255.255.255.0%22%2C%22operatingsystemrelease%22%3A%226.5%22%2C%22rubysitedir%22%3A%22%2Fopt%2Fpuppet%2Flib%2Fruby%2Fsite_ruby%2F1.9.1%22%2C%22network_eth0%22%3A%2210.16.150.0%22%2C%22network_lo%22%3A%22127.0.0.0%22%2C%22gid%22%3A%22root%22%2C%22interfaces%22%3A%22eth0%2Ceth1%2Clo%22%2C%22ipaddress_eth0%22%3A%2210.16.150.34%22%2C%22macaddress_eth0%22%3A%2284%3A34%3A97%3A11%3AD5%3AE4%22%2C%22netmask_eth0%22%3A%22255.255.255.0%22%2C%22mtu_eth0%22%3A%221500%22%2C%22macaddress_eth1%22%3A%2284%3A34%3A97%3A11%3AD5%3AE5%22%2C%22mtu_eth1%22%3A%221500%22%2C%22ipaddress_lo%22%3A%22127.0.0.1%22%2C%22netmask_lo%22%3A%22255.0.0.0%22%2C%22mtu_lo%22%3A%2216436%22%2C%22system_uptime%22%3A%7B%22seconds%22%3A3113471%2C%22hours%22%3A864%2C%22days%22%3A36%2C%22uptime%22%3A%2236%2Bdays%22%7D%2C%22os%22%3A%7B%22name%22%3A%22CentOS%22%2C%22family%22%3A%22RedHat%22%2C%22release%22%3A%7B%22major%22%3A%226%22%2C%22minor%22%3A%225%22%2C%22full%22%3A%226.5%22%7D%7D%2C%22operatingsystemmajrelease%22%3A%226%22%2C%22physicalprocessorcount%22%3A%221%22%2C%22partitions%22%3A%7B%22sda1%22%3A%7B%22uuid%22%3A%221ab7941e-42c4-4639-83cd-df6f75695bd2%22%2C%22size%22%3A%221024000%22%2C%22mount%22%3A%22%2Fboot%22%2C%22filesystem%22%3A%22ext4%22%7D%2C%22sda2%22%3A%7B%22size%22%3A%221952432128%22%2C%22filesystem%22%3A%22LVM2_member%22%7D%2C%22sdb1%22%3A%7B%22size%22%3A%22586004480%22%2C%22filesystem%22%3A%22LVM2_member%22%7D%7D%2C%22sshdsakey%22%3A%22AAAAB3NzaC1kc3MAAACBAO%2FSQi2xqm84MRep45iMgNcbSoA5PXIMwxHFzEqx5shrCU5jcO7iz%2FFh5iN9XnJ%2Fp3Bj1GIDUXph5RKghUglGYx98nPETxjOlnAjBFBgaGlq%2FRQG5vig85LWtZ0LO33NOPih1f2JnwFWjOR9dN9byyvBAWt6i7w3aq2x4kkhCHAzAAAAFQD%2FbE4QnCAviUaVGWy47jvNyQTLewAAAIBnqIJP1DhfE14w4BHWRBLlVNEOXASJH25UpO9hFPcj0g9Mr5dCZRQYKD%2BcyyZCkepUAm53L5oMimdXw7%2BYjzOl4Nt5LX4bqZt9w5SDECuVsLKfPltNBG32uKejmXg1mtM6%2FMYklFuPZxFMTY2mq7wz7%2FiLkWswkZcpZzpNABRDHQAAAIEA1bn1tTBs27qYRC9WfcW03GZ2YwSdFbzS%2BS0HyABOYa3uXPQGvQ3GF4XuywpWyflaWuMMeZcF1YND25O4Pw9eGNHhbm243a6HaYQ1NUZAmtWi0l2roU0r%2FDvu6KAVdY0Tb%2FKrSAHScHCseHjPAse2KPdNjBkLhovybKAVhKtoLEE%3D%22%2C%22sshfp_dsa%22%3A%22SSHFP%2B2%2B1%2B2c83962d9332c1549b2173cf3778eaf9fe2a5cbc%5CnSSHFP%2B2%2B2%2Bd50b9a51a811ac766331dd9dc1a5ff6fe31097f7ba59f8c56ca6809b7cda94b0%22%2C%22sshrsakey%22%3A%22AAAAB3NzaC1yc2EAAAABIwAAAQEAxnr%2FGT8l3VjGONNY%2FjtQYKIOBxD94Mnu0ii%2FYouwkbreNTHNZLN1CVcgQaOQPU51jeZw11Wk4WYujPMBAg%2F302rPKm%2BRcJdB04G6IoHTlEg6nOL9RsK3zEyjbMPKO9poM%2Fz%2FvjPaKyh81rQgBaaUyA4MTewlq39JsrISl4p8sFyKVD6PFx52oBCLjL3qdVYDmnATwl2PpGP0Fg2nBZFt9rdU2RrbalcvNY2N0eO5avKWY2Hd8xEGylAa9hks6WIuMefxcnLiFGDuih47HRQPglZEgeBDZtqYUwFhz1jliNRuPNSGtLe2nPEPnQccq96NJNFu7nd0tw0SPtlr7MsA4w%3D%3D%22%2C%22sshfp_rsa%22%3A%22SSHFP%2B1%2B1%2Ba2f9d88c1dfdf10a11b0fab729932b3ff498b8ee%5CnSSHFP%2B1%2B2%2Ba847030840ea774636dea76b207e5c9ff8db0a10d67902920872a22a04eabae5%22%2C%22domain%22%3A%22performance.delivery.puppetlabs.net%22%2C%22architecture%22%3A%22x86_64%22%2C%22uptime%22%3A%2236%2Bdays%22%2C%22uptime_hours%22%3A864%2C%22kernelmajversion%22%3A%222.6%22%2C%22hardwaremodel%22%3A%22x86_64%22%2C%22memorysize%22%3A%227.52%2BGB%22%2C%22memoryfree%22%3A%226.62%2BGB%22%2C%22swapsize%22%3A%227.66%2BGB%22%2C%22swapfree%22%3A%227.65%2BGB%22%2C%22swapsize_mb%22%3A%227839.99%22%2C%22swapfree_mb%22%3A%227833.75%22%2C%22memorysize_mb%22%3A%227703.16%22%2C%22memoryfree_mb%22%3A%226782.42%22%2C%22path%22%3A%22%2Fusr%2Flocal%2Fsbin%3A%2Fusr%2Flocal%2Fbin%3A%2Fsbin%3A%2Fbin%3A%2Fusr%2Fsbin%3A%2Fusr%2Fbin%3A%2Froot%2Fbin%22%2C%22selinux%22%3A%22false%22%2C%22processors%22%3A%7B%22models%22%3A%5B%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%5D%2C%22count%22%3A8%2C%22physicalcount%22%3A1%7D%2C%22processor0%22%3A%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22processor1%22%3A%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22processor2%22%3A%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22processor3%22%3A%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22processor4%22%3A%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22processor5%22%3A%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22processor6%22%3A%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22processor7%22%3A%22Intel%28R%29%2BXeon%28R%29%2BCPU%2BE3-1280%2Bv3%2B%40%2B3.60GHz%22%2C%22processorcount%22%3A%228%22%2C%22fqdn%22%3A%22perf-bl16.performance.delivery.puppetlabs.net%22%2C%22kernelversion%22%3A%222.6.32%22%2C%22macaddress%22%3A%2284%3A34%3A97%3A11%3AD5%3AE4%22%2C%22rubyplatform%22%3A%22x86_64-linux%22%2C%22ps%22%3A%22ps%2B-ef%22%2C%22blockdevice_sda_size%22%3A1000171331584%2C%22blockdevice_sda_vendor%22%3A%22HP%22%2C%22blockdevice_sda_model%22%3A%22LOGICAL%2BVOLUME%22%2C%22blockdevice_sdb_size%22%3A300035497984%2C%22blockdevice_sdb_vendor%22%3A%22HP%22%2C%22blockdevice_sdb_model%22%3A%22LOGICAL%2BVOLUME%22%2C%22blockdevices%22%3A%22sda%2Csdb%22%2C%22hardwareisa%22%3A%22x86_64%22%2C%22uptime_seconds%22%3A3113471%2C%22facterversion%22%3A%222.2.0%22%2C%22uptime_days%22%3A36%2C%22augeasversion%22%3A%221.2.0%22%2C%22rubyversion%22%3A%221.9.3%22%2C%22pe_version%22%3A%223.4.0%22%2C%22is_pe%22%3Atrue%2C%22pe_major_version%22%3A%223%22%2C%22pe_minor_version%22%3A%224%22%2C%22pe_patch_version%22%3A%220%22%2C%22staging_http_get%22%3A%22curl%22%2C%22custom_auth_conf%22%3A%22false%22%2C%22pe_build%22%3A%223.4.0%22%2C%22platform_tag%22%3A%22el-6-x86_64%22%2C%22root_home%22%3A%22%2Froot%22%2C%22pe_concat_basedir%22%3A%22%2Fvar%2Fopt%2Flib%2Fpe-puppet%2Fpe_concat%22%2C%22puppet_vardir%22%3A%22%2Fvar%2Fopt%2Flib%2Fpe-puppet%22%2C%22clientcert%22%3A%22perf-bl16.performance.delivery.puppetlabs.net%22%2C%22clientversion%22%3A%223.7.1%2B%28Puppet%2BEnterprise%2B3.4.0%29%22%2C%22clientnoop%22%3Afalse%7D%2C%22timestamp%22%3A%222014-10-14%2B17%3A14%3A01%2B-0700%22%2C%22expiration%22%3A%222014-10-14T17%3A44%3A01.355882259-07%3A00%22%7D""")
	      .formParam("""facts_format""", """pson""")))
                
		.pause(2)
		.exec(http("filemeta")
			.get("""/production/file_metadata/modules/catalog-zero1/catalog-zero1-impl24.txt?links=manage&source_permissions=use""")
		  .resources(http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero1/catalog-zero1-impl71.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero1/catalog-zero1-impl83.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero2/catalog-zero2-impl51.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero3/catalog-zero3-impl23.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero3/catalog-zero3-impl32.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero3/catalog-zero3-impl74.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero4/catalog-zero4-impl13.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero5/catalog-zero5-impl22.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero5/catalog-zero5-impl42.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero5/catalog-zero5-impl43.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero5/catalog-zero5-impl52.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero6/catalog-zero6-impl32.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero6/catalog-zero6-impl54.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero7/catalog-zero7-impl32.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero7/catalog-zero7-impl34.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero7/catalog-zero7-impl82.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero7/catalog-zero7-impl85.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero7/catalog-zero7-impl87.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero8/catalog-zero8-impl11.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero8/catalog-zero8-impl13.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero8/catalog-zero8-impl33.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero8/catalog-zero8-impl81.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero9/catalog-zero9-impl63.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero9/catalog-zero9-impl72.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero9/catalog-zero9-impl84.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero10/catalog-zero10-impl13.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero10/catalog-zero10-impl22.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero10/catalog-zero10-impl41.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero10/catalog-zero10-impl71.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero10/catalog-zero10-impl83.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero10/catalog-zero10-impl85.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero11/catalog-zero11-impl11.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero11/catalog-zero11-impl21.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero11/catalog-zero11-impl24.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero11/catalog-zero11-impl62.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero11/catalog-zero11-impl84.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero12/catalog-zero12-impl33.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero12/catalog-zero12-impl82.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero12/catalog-zero12-impl86.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero12/catalog-zero12-impl87.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero13/catalog-zero13-impl51.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero13/catalog-zero13-impl54.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero13/catalog-zero13-impl74.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero13/catalog-zero13-impl83.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero13/catalog-zero13-impl84.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero13/catalog-zero13-impl86.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero14/catalog-zero14-impl72.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero15/catalog-zero15-impl62.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero15/catalog-zero15-impl72.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero15/catalog-zero15-impl73.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero16/catalog-zero16-impl33.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero16/catalog-zero16-impl83.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero16/catalog-zero16-impl85.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero17/catalog-zero17-impl13.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero17/catalog-zero17-impl87.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero18/catalog-zero18-impl14.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero18/catalog-zero18-impl23.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero18/catalog-zero18-impl24.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero18/catalog-zero18-impl32.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero18/catalog-zero18-impl84.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero19/catalog-zero19-impl12.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero19/catalog-zero19-impl31.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero19/catalog-zero19-impl53.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero19/catalog-zero19-impl54.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero19/catalog-zero19-impl83.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero19/catalog-zero19-impl86.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero20/catalog-zero20-impl24.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero20/catalog-zero20-impl42.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero20/catalog-zero20-impl71.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero20/catalog-zero20-impl73.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero21/catalog-zero21-impl32.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero21/catalog-zero21-impl41.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero21/catalog-zero21-impl82.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero21/catalog-zero21-impl86.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero21/catalog-zero21-impl87.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero22/catalog-zero22-impl34.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero22/catalog-zero22-impl52.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero23/catalog-zero23-impl21.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero23/catalog-zero23-impl62.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero24/catalog-zero24-impl52.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero24/catalog-zero24-impl83.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero25/catalog-zero25-impl13.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero25/catalog-zero25-impl22.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero25/catalog-zero25-impl24.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero25/catalog-zero25-impl51.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero26/catalog-zero26-impl54.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero26/catalog-zero26-impl64.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero26/catalog-zero26-impl86.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero27/catalog-zero27-impl33.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero27/catalog-zero27-impl41.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero27/catalog-zero27-impl63.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero28/catalog-zero28-impl13.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero28/catalog-zero28-impl33.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero28/catalog-zero28-impl51.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero28/catalog-zero28-impl72.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero28/catalog-zero28-impl84.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero29/catalog-zero29-impl71.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero29/catalog-zero29-impl86.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero30/catalog-zero30-impl34.txt?links=manage&source_permissions=use"""),
            http("filemeta")
			.get(uri1 + """/file_metadata/modules/catalog-zero30/catalog-zero30-impl85.txt?links=manage&source_permissions=use"""),
                    http("filemeta")
		      .get(uri1 + """/file_metadata/modules/puppet_enterprise/mcollective/plugins?links=manage&recurse=true&checksum_type=md5"""),

                  http("report")
                    .put(uri1 + """/report/perf-bl16.performance.delivery.puppetlabs.net""")
                    .headers(headers_106)

                    // may need the full path here
                    .body(RawFileBody("request-bodies/PE371_catalogzero_report.txt"))))
                              
 
					
	val scn = scenario("PE371_CatalogZero").exec(chain_0)
        val REPETITION_COUNTER: String = "repetitionCounter"
        val NUM_AGENTS: Int = 1
        val NUM_REPETITIONS: Int = 2
        val SLEEP_DURATION: FiniteDuration = 1 seconds
        val RAMP_UP_DURATION: FiniteDuration = 0 seconds

        def addSleeps(chain:ChainBuilder, totalNumReps:Int): ChainBuilder = {
          // This is kind of a dirty hack. Here's the deal.
          // In order to simulate real world agent runs, we need to sleep 30 minutes
          // in between each series of agent requests. That can be achieved
          // easily by adding a "pause" to the end of the run.
          // However, if we do that, then after the final series of requests, we'll sleep
          // for 30 minutes before the simulation can end, even though that is entirely
          // unnecessary. Since most of our jenkins jobs are going to run 2-6 sims,
          // that would mean we're sleeping for 1-3 extra hours and uselessly tying up the
          // hardware. Thus, we need to make the sleep conditional based on whether
          // or not we're on the final repetition.
          // Here we've replaced our "pause" with a Gatling "session function",
          // which basically just sets a session variable to check to see if
          // we are on the final repetition, and if not, sleep for 30 mins.
          chain.exec((session: Session) => {
            val repetitionCount = session(REPETITION_COUNTER).asOption[Int].getOrElse(0) + 1
            println("Agent " + session.userId +
              " completed " + repetitionCount + " of " + totalNumReps + " repetitions.")
            session.set(REPETITION_COUNTER, repetitionCount)
          }).doIf((session) => session(REPETITION_COUNTER).as[Int] < totalNumReps) {
            exec((session) => {
              println("This is not the last repetition; sleeping " + SLEEP_DURATION + ".")
              session
            }).pause(SLEEP_DURATION)
          }.doIf((session) => session(REPETITION_COUNTER).as[Int] >= totalNumReps) {
            exec((session) => {
              println("That was the last repetition. Not sleeping.")
              session
            })
          }
        }

        val chainWithFailFast:ChainBuilder =
          // this wrapper causes the agent sims to exit the series of
          // of requests upon the first failure, rather than continuing
          // to send up the remaining requests for the agent run.
          exitBlockOnFail {
            exec(scn)
          }

        val chainWithSleeps:ChainBuilder =
          addSleeps(chainWithFailFast, NUM_REPETITIONS)

        val finalScn = scenario(this.getClass.getSimpleName)
          .repeat(NUM_REPETITIONS) {
            group((session) => this.getClass.getSimpleName) {
              chainWithSleeps
            }
          }.inject(rampUsers(NUM_AGENTS) over RAMP_UP_DURATION)
          .protocols(httpProtocol)

	setUp(finalScn)
}
