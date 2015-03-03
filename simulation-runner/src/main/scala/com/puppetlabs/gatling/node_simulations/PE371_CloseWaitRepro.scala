package com.puppetlabs.gatling.node_simulations

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import com.puppetlabs.gatling.runner.SimulationWithScenario
import org.joda.time.LocalDateTime
import org.joda.time.format.ISODateTimeFormat

class PE371_CloseWaitRepro extends SimulationWithScenario {

//	val httpProtocol = http
//		.baseURL("https://ec2-closewait-split-master.localdomain:8140")
//		.inferHtmlResources()
//		.acceptHeader("pson, b64_zlib_yaml, yaml, raw")
//		.acceptEncodingHeader("identity")
//		.contentTypeHeader("application/x-www-form-urlencoded")
//		.userAgentHeader("Ruby")

	val headers_3 = Map("Accept" -> "pson, b64_zlib_yaml, yaml, dot, raw")

	val headers_9 = Map(
		"Accept" -> "pson, yaml",
		"Content-Type" -> "text/pson",
    "Connection" -> "close")

//    val uri1 = "https://ec2-closewait-split-master.localdomain:8140/production"

  val reportBody = ELFileBody("PE371_CloseWaitRepro_0009_request.txt")

	val scn = scenario("PE371_CloseWaitRepro")
		.exec(http("node")
			.get("/production/node/closewait-agent.localdomain?transaction_uuid=58a8f8fe-9921-4af0-b96a-5ed8656083ed&fail_on_404=true"))
    .exec(http("filemeta pluginfacts")
			.get("/production/file_metadatas/pluginfacts?links=manage&recurse=true&ignore=.svn&ignore=CVS&ignore=.git&checksum_type=md5"))
		.pause(1)
		.exec(http("filemeta plugins")
			.get("/production/file_metadatas/plugins?links=manage&recurse=true&ignore=.svn&ignore=CVS&ignore=.git&checksum_type=md5"))
		.pause(42)
		.exec(http("catalog")
			.post("/production/catalog/closewait-agent.localdomain")
			.headers(headers_3)
			.formParam("facts_format", "pson")
			.formParam("facts", "%7B%22name%22%3A%22closewait-agent.localdomain%22%2C%22values%22%3A%7B%22sshrsakey%22%3A%22AAAAB3NzaC1yc2EAAAADAQABAAABAQDet%2B1wzjOGHj6xQdaNfg4XzsJhbKpzlRPkddpKkmk7RJBFEt%2BQTR1IugOiXQ8lOrIAbejlzcu0OKTzvoK6vx0s4b6IixSN%2ByvzHYsOnI8XJq83iZM%2BATQAdrs3epvlyjFlreVfItCh69kKv88EQRKSM9gJERTu740FTnr1Ja7IbB0VQoUPsHXbsC2n%2Fva2zXO3tMfWN3tEdjoaQAhPEtwRwgct6IMgIeeS4fo80%2FLeX7pYJmaTGCtRMGpwMgz1gJv3EBt%2FIuukNQeLQFdyx22bw7lK3KSs61ejKf9OvBxsSmbQuYgvtZsuFyqSfS2q8Tv7473RDuVnU4vsg46j3wOj%22%2C%22sshfp_rsa%22%3A%22SSHFP+1+1+230fad4e9d645e87166ae012bf73b86cf36f3cdc%5CnSSHFP+1+2+36630f2d8b4991015b62868753edb18566413efcd3f7e1015e648ff4f325fc86%22%2C%22sshecdsakey%22%3A%22AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMJ5BgptH3MG7wm8MBBYG%2FbqBkNv1Cg12LImFFa5HIY7HWM5p0WtlvvDMkMuNcEVWlV12wxZGPr2G2lQwrETY90%3D%22%2C%22sshfp_ecdsa%22%3A%22SSHFP+3+1+9e2d2e38a52ab7f92a49d0500813095a9f60c372%5CnSSHFP+3+2+3760029a26e759428216aa627ae7b578cf6abf3ffee12c33e07b750103f4e789%22%2C%22architecture%22%3A%22x86_64%22%2C%22system_uptime%22%3A%7B%22seconds%22%3A20976%2C%22hours%22%3A5%2C%22days%22%3A0%2C%22uptime%22%3A%225%3A49+hours%22%7D%2C%22augeasversion%22%3A%221.2.0%22%2C%22timezone%22%3A%22PST%22%2C%22kernel%22%3A%22Linux%22%2C%22blockdevice_fd0_size%22%3A4096%2C%22blockdevice_sda_size%22%3A21474836480%2C%22blockdevice_sda_vendor%22%3A%22VMware%2C%22%2C%22blockdevice_sda_model%22%3A%22VMware+Virtual+S%22%2C%22blockdevice_sr0_size%22%3A1073741312%2C%22blockdevice_sr0_vendor%22%3A%22NECVMWar%22%2C%22blockdevice_sr0_model%22%3A%22VMware+IDE+CDR10%22%2C%22blockdevices%22%3A%22fd0%2Csda%2Csr0%22%2C%22dhcp_servers%22%3A%7B%22system%22%3A%22192.168.122.254%22%2C%22eno16777736%22%3A%22192.168.122.254%22%7D%2C%22domain%22%3A%22localdomain%22%2C%22virtual%22%3A%22vmware%22%2C%22is_virtual%22%3Atrue%2C%22hardwaremodel%22%3A%22x86_64%22%2C%22operatingsystem%22%3A%22CentOS%22%2C%22os%22%3A%7B%22name%22%3A%22CentOS%22%2C%22family%22%3A%22RedHat%22%2C%22release%22%3A%7B%22major%22%3A%227%22%2C%22minor%22%3A%220%22%2C%22full%22%3A%227.0.1406%22%7D%7D%2C%22facterversion%22%3A%222.3.0%22%2C%22filesystems%22%3A%22xfs%22%2C%22fqdn%22%3A%22closewait-agent.localdomain%22%2C%22gid%22%3A%22root%22%2C%22hardwareisa%22%3A%22x86_64%22%2C%22hostname%22%3A%22closewait-agent%22%2C%22id%22%3A%22root%22%2C%22interfaces%22%3A%22eno16777736%2Clo%22%2C%22ipaddress_eno16777736%22%3A%22192.168.122.128%22%2C%22macaddress_eno16777736%22%3A%2200%3A0c%3A29%3A81%3Acd%3Ab8%22%2C%22netmask_eno16777736%22%3A%22255.255.255.0%22%2C%22mtu_eno16777736%22%3A1500%2C%22ipaddress_lo%22%3A%22127.0.0.1%22%2C%22netmask_lo%22%3A%22255.0.0.0%22%2C%22mtu_lo%22%3A65536%2C%22ipaddress%22%3A%22192.168.122.128%22%2C%22kernelmajversion%22%3A%223.10%22%2C%22kernelrelease%22%3A%223.10.0-123.4.2.el7.x86_64%22%2C%22kernelversion%22%3A%223.10.0%22%2C%22rubyplatform%22%3A%22x86_64-linux%22%2C%22rubysitedir%22%3A%22%2Fopt%2Fpuppet%2Flib%2Fruby%2Fsite_ruby%2F1.9.1%22%2C%22macaddress%22%3A%2200%3A0c%3A29%3A81%3Acd%3Ab8%22%2C%22boardmanufacturer%22%3A%22Intel+Corporation%22%2C%22boardproductname%22%3A%22440BX+Desktop+Reference+Platform%22%2C%22boardserialnumber%22%3A%22None%22%2C%22bios_vendor%22%3A%22Phoenix+Technologies+LTD%22%2C%22bios_version%22%3A%226.00%22%2C%22bios_release_date%22%3A%2207%2F31%2F2013%22%2C%22manufacturer%22%3A%22VMware%2C+Inc.%22%2C%22productname%22%3A%22VMware+Virtual+Platform%22%2C%22serialnumber%22%3A%22VMware-56+4d+e0+ae+8c+bb+09+10-6b+04+77+71+ee+81+cd+b8%22%2C%22uuid%22%3A%22564DE0AE-8CBB-0910-6B04-7771EE81CDB8%22%2C%22type%22%3A%22Other%22%2C%22memorysize%22%3A%22987.17+MB%22%2C%22memoryfree%22%3A%22480.17+MB%22%2C%22swapsize%22%3A%222.00+GB%22%2C%22swapfree%22%3A%222.00+GB%22%2C%22swapsize_mb%22%3A%222048.00%22%2C%22swapfree_mb%22%3A%222048.00%22%2C%22memorysize_mb%22%3A%22987.17%22%2C%22memoryfree_mb%22%3A%22480.17%22%2C%22netmask%22%3A%22255.255.255.0%22%2C%22network_eno16777736%22%3A%22192.168.122.0%22%2C%22network_lo%22%3A%22127.0.0.0%22%2C%22operatingsystemmajrelease%22%3A%227%22%2C%22rubyversion%22%3A%221.9.3%22%2C%22operatingsystemrelease%22%3A%227.0.1406%22%2C%22osfamily%22%3A%22RedHat%22%2C%22partitions%22%3A%7B%22sda1%22%3A%7B%22uuid%22%3A%2259903d9a-cd23-4866-ab15-f897b591a08d%22%2C%22size%22%3A%221024000%22%2C%22mount%22%3A%22%2Fboot%22%2C%22filesystem%22%3A%22xfs%22%7D%2C%22sda2%22%3A%7B%22size%22%3A%2240916992%22%2C%22filesystem%22%3A%22LVM2_member%22%7D%7D%2C%22path%22%3A%22%2Fusr%2Flocal%2Fsbin%3A%2Fusr%2Flocal%2Fbin%3A%2Fusr%2Fsbin%3A%2Fusr%2Fbin%3A%2Froot%2Fbin%3A%2Fsbin%22%2C%22selinux%22%3Atrue%2C%22selinux_enforced%22%3Atrue%2C%22selinux_policyversion%22%3A%2228%22%2C%22selinux_current_mode%22%3A%22enforcing%22%2C%22selinux_config_mode%22%3A%22enforcing%22%2C%22selinux_config_policy%22%3A%22unknown%22%2C%22physicalprocessorcount%22%3A1%2C%22processors%22%3A%7B%22models%22%3A%5B%22Intel%28R%29+Core%28TM%29+i7-2600+CPU+%40+3.40GHz%22%5D%2C%22count%22%3A1%2C%22physicalcount%22%3A1%7D%2C%22processor0%22%3A%22Intel%28R%29+Core%28TM%29+i7-2600+CPU+%40+3.40GHz%22%2C%22processorcount%22%3A1%2C%22ps%22%3A%22ps+-ef%22%2C%22puppetversion%22%3A%223.7.3+%28Puppet+Enterprise+3.7.1%29%22%2C%22uniqueid%22%3A%2200000000%22%2C%22uptime%22%3A%225%3A49+hours%22%2C%22uptime_days%22%3A0%2C%22uptime_hours%22%3A5%2C%22uptime_seconds%22%3A20976%2C%22concat_basedir%22%3A%22%2Fvar%2Fopt%2Flib%2Fpe-puppet%2Fconcat%22%2C%22custom_auth_conf%22%3A%22false%22%2C%22ecc_activeip%22%3A%22192.168.122.128%22%2C%22ip6tables_version%22%3A%221.4.21%22%2C%22ecc_activenetworkinterface%22%3A%22%22%2C%22iptables_version%22%3A%221.4.21%22%2C%22staging_http_get%22%3A%22curl%22%2C%22ecc_appnetgroup%22%3A%22%22%2C%22ecc_cluster%22%3A%22ara%22%2C%22ecc_clustername%22%3A%22aram%22%2C%22puppet_vardir%22%3A%22%2Fvar%2Fopt%2Flib%2Fpe-puppet%22%2C%22ecc_gateway%22%3A%22192.168.122.2%22%2C%22root_home%22%3A%22%2Froot%22%2C%22ecc_managementip%22%3A%22192.168.122.200%22%2C%22rsyslog_version%22%3A%227.4.7%22%2C%22ecc_mempagesize%22%3A%224096%22%2C%22ecc_nodetype%22%3A%22undef%22%2C%22pe_concat_basedir%22%3A%22%2Fvar%2Fopt%2Flib%2Fpe-puppet%2Fpe_concat%22%2C%22ecc_puppetpartition%22%3A1%2C%22pe_version%22%3A%223.7.1%22%2C%22is_pe%22%3Atrue%2C%22pe_major_version%22%3A%223%22%2C%22pe_minor_version%22%3A%227%22%2C%22pe_patch_version%22%3A%221%22%2C%22ecc_sshdomain%22%3A%22undef%22%2C%22ecc_ugedomain%22%3A%22undef%22%2C%22platform_tag%22%3A%22el-7-x86_64%22%2C%22ecc_vendornetgroups%22%3A%5B%22-%40acshpc%22%2C%22-%40afchpc%22%2C%22-%40ebkhpc%22%2C%22-%40jcchpc%22%2C%22-%40sbmhpc%22%2C%22-%40wpahpc%22%5D%2C%22gemhome%22%3A%22%2Fopt%2Fpuppet%2Flib%2Fruby%2Fgems%2F1.9.1%22%2C%22git_exec_path%22%3A%22%2Fusr%2Flibexec%2Fgit-core%22%2C%22git_html_path%22%3A%22%2Fusr%2Fshare%2Fdoc%2Fgit-1.8.3.1%22%2C%22git_version%22%3A%221.8.3.1%22%2C%22pe_build%22%3A%223.7.1%22%2C%22clientcert%22%3A%22closewait-agent.localdomain%22%2C%22clientversion%22%3A%223.7.3+%28Puppet+Enterprise+3.7.1%29%22%2C%22clientnoop%22%3Afalse%7D%2C%22timestamp%22%3A%222015-02-20+13%3A45%3A06+-0800%22%2C%22expiration%22%3A%222025-02-20T14%3A15%3A06.591482340-08%3A00%22%7D")
			.formParam("transaction_uuid", "58a8f8fe-9921-4af0-b96a-5ed8656083ed")
			.formParam("fail_on_404", "true"))
    .exec(http("filemeta mco plugins")
			.get("/production/file_metadatas/modules/puppet_enterprise/mcollective/plugins?links=manage&recurse=true&checksum_type=md5"))
    .exec(http("filemeta")
			.get("/production/file_metadata/modules/mlocate/mlocate.cron?links=manage&source_permissions=use"))
    .exec(http("filemeta")
			.get("/production/file_metadata/modules/logrotate/etc/logrotate.conf?links=manage&source_permissions=use"))
    .exec(http("filemeta")
			.get("/production/file_metadata/modules/logrotate/etc/cron.daily/logrotate?links=manage&source_permissions=use"))
    .exec(http("filemeta")
			.get("/production/file_metadata/modules/logrotate/etc/cron.hourly/logrotate?links=manage&source_permissions=use"))
    .exec((session:Session) => {
      session.set("reportTimestamp",
        LocalDateTime.now.toString(ISODateTimeFormat.dateTime()))
    })
    .exec(http("report")
			.put("/production/report/closewait-agent.localdomain")
			.headers(headers_9)
      .body(reportBody))

	//setUp(scn.inject(atOnceUsers(1))).protocols(httpProtocol)
}
