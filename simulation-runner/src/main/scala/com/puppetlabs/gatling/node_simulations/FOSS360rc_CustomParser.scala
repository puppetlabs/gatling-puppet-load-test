package com.puppetlabs.gatling.node_simulations
import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._

class FOSS360rc_CatalogZero extends com.puppetlabs.gatling.runner.SimulationWithScenario {

	val httpConf = httpConfig
			.baseURL("https://perf-bl16.performance.delivery.puppetlabs.net:8140")
			.acceptHeader("pson, yaml, b64_zlib_yaml, raw")
			.connection("close")


	val headers_4 = Map(
			"Accept" -> """pson, yaml, dot, b64_zlib_yaml, raw""",
			"Content-Type" -> """application/x-www-form-urlencoded"""
	)

	val headers_108 = Map(
			"Accept" -> """pson, yaml""",
			"Content-Type" -> """text/pson"""
	)


	val chain_0 =
		exec(http("node")
					.get("/production/node/perf-bl15.performance.delivery.puppetlabs.net")
			)
		.pause(126 milliseconds)
		.exec(http("filemeta plugin facts")
					.get("/production/file_metadatas/pluginfacts")
					.queryParam("""checksum_type""", """md5""")
					.queryParam("""links""", """manage""")
					.queryParam("""recurse""", """true""")
					.queryParam("""ignore""", """.svn""")
					.queryParam("""ignore""", """CVS""")
					.queryParam("""ignore""", """.git""")
			)
		.pause(117 milliseconds)
		.exec(http("filemeta plugins")
					.get("/production/file_metadatas/plugins")
					.queryParam("""checksum_type""", """md5""")
					.queryParam("""links""", """manage""")
					.queryParam("""recurse""", """true""")
					.queryParam("""ignore""", """.svn""")
					.queryParam("""ignore""", """CVS""")
					.queryParam("""ignore""", """.git""")
			)
		.pause(2)
		.exec(http("catalog")
					.post("/production/catalog/perf-bl15.performance.delivery.puppetlabs.net")
					.headers(headers_4)
						.param("""facts_format""", """pson""")
						.param("""transaction_uuid""", """2360dec4-0380-446f-a46e-db32a1fb2b80""")
						.param("""facts""", """%7B%22name%22%3A%22perf-bl15.performance.delivery.puppetlabs.net%22%2C%22expiration%22%3A%222014-05-12T16%3A53%3A56.848863000-04%3A00%22%2C%22timestamp%22%3A%22Mon+May+12+16%3A23%3A56+-0400+2014%22%2C%22values%22%3A%7B%22memoryfree%22%3A%226.89+GB%22%2C%22processor6%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22selinux%22%3A%22false%22%2C%22kernelmajversion%22%3A%222.6%22%2C%22sshrsakey%22%3A%22AAAAB3NzaC1yc2EAAAABIwAAAQEA5G8mWdwUuLTmpevbq%2Fp2GJcBNeBgcr6sMs5LOwS3He%2FLLuMghpYaEoneRk7RBdB24%2F2pbpyh6KUXdygTFodDXx6VP0HW%2BT9kY6WpIwffoH1Y%2FsPHP6wvXCvZ54OmaDMF3fLn%2BbUFPBwsTQD1kv5lYnX1RJUiN0k3MFDDy4csBZFyAVo2B1TsI%2FpF3xrErJ3eESFOiEbT3A8hzK3OVRD9LWXdaGfe5YlMgLJELTa7SCOWHs1I5wEhsCt1d%2BRza60dY51boXcB0%2BFnDcvn5fJ5fdRkXwc%2BZ6Lbf92IUucLQnDCBJFUKwcyFrwZC2SMrIotgs%2Fe6K8GUlt8ZLN%2FbsAR8Q%3D%3D%22%2C%22fqdn%22%3A%22perf-bl15.performance.delivery.puppetlabs.net%22%2C%22macaddress_eth1%22%3A%2284%3A34%3A97%3A11%3AD0%3AA1%22%2C%22netmask%22%3A%22255.255.255.0%22%2C%22physicalprocessorcount%22%3A%221%22%2C%22processorcount%22%3A%228%22%2C%22sshfp_dsa%22%3A%22SSHFP+2+1+49cb4d18c6fc9e2f0146b1c62f0d57969e2e879f%5CnSSHFP+2+2+19074ca236460e21f1b378487bb3c0be0a00ce4544c8e2e1fdf87330de378654%22%2C%22uptime%22%3A%220%3A38+hours%22%2C%22manufacturer%22%3A%22HP%22%2C%22netmask_eth0%22%3A%22255.255.255.0%22%2C%22blockdevice_sdb_size%22%3A%22300035497984%22%2C%22uptime_days%22%3A%220%22%2C%22processor3%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22memorysize%22%3A%227.52+GB%22%2C%22uniqueid%22%3A%2200000000%22%2C%22kernel%22%3A%22Linux%22%2C%22uptime_hours%22%3A%220%22%2C%22blockdevice_sda_vendor%22%3A%22HP%22%2C%22hardwaremodel%22%3A%22x86_64%22%2C%22productname%22%3A%22ProLiant+DL320e+Gen8+v2%22%2C%22processor0%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22timezone%22%3A%22EDT%22%2C%22osfamily%22%3A%22RedHat%22%2C%22swapsize_mb%22%3A%22999.99%22%2C%22domain%22%3A%22performance.delivery.puppetlabs.net%22%2C%22bios_version%22%3A%22P80%22%2C%22virtual%22%3A%22physical%22%2C%22network_eth0%22%3A%2210.16.150.0%22%2C%22blockdevice_sdb_model%22%3A%22LOGICAL+VOLUME%22%2C%22ipaddress%22%3A%2210.16.150.33%22%2C%22puppetversion%22%3A%223.5.0%22%2C%22macaddress%22%3A%2284%3A34%3A97%3A11%3AD0%3AA0%22%2C%22processor5%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22netmask_lo%22%3A%22255.0.0.0%22%2C%22type%22%3A%22Rack+Mount+Chassis%22%2C%22mtu_eth1%22%3A%221500%22%2C%22kernelrelease%22%3A%222.6.32-358.el6.x86_64%22%2C%22macaddress_eth0%22%3A%2284%3A34%3A97%3A11%3AD0%3AA0%22%2C%22mtu_lo%22%3A%2216436%22%2C%22blockdevice_sdb_vendor%22%3A%22HP%22%2C%22memorysize_mb%22%3A%227703.36%22%2C%22path%22%3A%22%2Fusr%2Flocal%2Fsbin%3A%2Fusr%2Flocal%2Fbin%3A%2Fsbin%3A%2Fbin%3A%2Fusr%2Fsbin%3A%2Fusr%2Fbin%3A%2Froot%2Fbin%22%2C%22network_lo%22%3A%22127.0.0.0%22%2C%22processor2%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22clientversion%22%3A%223.5.0%22%2C%22uuid%22%3A%2233323237-3531-5355-4533-34364C374534%22%2C%22hardwareisa%22%3A%22x86_64%22%2C%22ipaddress_eth0%22%3A%2210.16.150.33%22%2C%22sshfp_rsa%22%3A%22SSHFP+1+1+88a5a00e73d21967be4a135d52f42d26c15a0404%5CnSSHFP+1+2+c5e7b1fc93ea088f80f9225f51cd841670e954332822bb45c428f09413a749a8%22%2C%22ipaddress_lo%22%3A%22127.0.0.1%22%2C%22operatingsystemmajrelease%22%3A%226%22%2C%22facterversion%22%3A%222.0.1%22%2C%22filesystems%22%3A%22ext4%2Ciso9660%22%2C%22swapfree_mb%22%3A%22999.99%22%2C%22hostname%22%3A%22perf-bl15%22%2C%22operatingsystem%22%3A%22CentOS%22%2C%22bios_vendor%22%3A%22HP%22%2C%22processor7%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22blockdevice_sda_size%22%3A%221000171331584%22%2C%22operatingsystemrelease%22%3A%226.4%22%2C%22uptime_seconds%22%3A%222334%22%2C%22rubyversion%22%3A%221.8.7%22%2C%22clientcert%22%3A%22perf-bl15.performance.delivery.puppetlabs.net%22%2C%22mtu_eth0%22%3A%221500%22%2C%22processor4%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22architecture%22%3A%22x86_64%22%2C%22bios_release_date%22%3A%2209%2F01%2F2013%22%2C%22rubysitedir%22%3A%22%2Fusr%2Flib%2Fruby%2Fsite_ruby%2F1.8%22%2C%22memoryfree_mb%22%3A%227060.03%22%2C%22processor1%22%3A%22Intel%28R%29+Xeon%28R%29+CPU+E3-1280+v3+%40+3.60GHz%22%2C%22clientnoop%22%3A%22false%22%2C%22swapsize%22%3A%22999.99+MB%22%2C%22augeasversion%22%3A%221.0.0%22%2C%22sshdsakey%22%3A%22AAAAB3NzaC1kc3MAAACBAK73Hv37Q693eTsJdOFLMFsz93BIk80p4tt9Zzt0vURla%2BsfXok2rAOyVC7MB%2B7r8tdtV2GoEGkje%2FIIju68vxlhFKFcex7zwemaJ7uI9P8z%2FLvrCKfzJ6bYdajDoeVxjZE3eSZ7xaKZSsaesIucZ8HthHkxrCZYWgR31EasMUkNAAAAFQDYD5x3qW%2B6ie%2FAvmQ0VN2MQGCeywAAAIA%2FBDi1yXI%2Fbe5iJ%2BCrnVdPSs6u5adcWkS%2FcUCuPZbJcBr4I0GMs5ajDKQ3ysaBjIDlpfSLCc%2BQKpaFa0T1c27hpEqEL%2FOas0cFsMDvG%2BHQgq32eJy%2BCdijVasOu0Lj8tXrBqtEDpzxNCh3ACX%2BTOwzzALoUzD%2F%2F3enKeGKNunUXAAAAIBgz22M4%2Fxj8Tzs%2B5D1VK83knl10Tn9G%2FYlYodgD3OZMlq3IyLs01J4L7LD5ilGHKqaruMFYzEm0%2BeEOn%2BYCynxlPYP6jfxUH7dd4X5yxsugtxm6S6IUv2ySbLFySlmcRoBsZSApM6ZhO94wUUjug0MzDUbx3baIdufydQO2lhlHg%3D%3D%22%2C%22ps%22%3A%22ps+-ef%22%2C%22blockdevice_sda_model%22%3A%22LOGICAL+VOLUME%22%2C%22swapfree%22%3A%22999.99+MB%22%2C%22id%22%3A%22root%22%2C%22blockdevices%22%3A%22sda%2Csdb%22%2C%22serialnumber%22%3A%22USE346L7E4%22%2C%22interfaces%22%3A%22eth0%2Ceth1%2Clo%22%2C%22is_virtual%22%3A%22false%22%2C%22kernelversion%22%3A%222.6.32%22%7D%7D""")
			)
		.exec(http("report")
					.put("/production/report/perf-bl15.performance.delivery.puppetlabs.net")
					.headers(headers_108)
						.fileBody("FOSS360rc_CatalogZero_request_108.txt")
			)

	val scn = scenario("Scenario Name")
		.exec(	chain_0	)

	setUp(scn.users(1).protocolConfig(httpConf))
}