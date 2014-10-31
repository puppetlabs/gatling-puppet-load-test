package com.puppetlabs.gatling.simulations

import scala.concurrent.duration._
import io.gatling.core.Predef._
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._
import io.gatling.core.structure.{ChainBuilder}


class PE371Clamps extends Simulation {


  val httpProtocol = http
		.baseURL("https://puppet-master:8140")
		.inferHtmlResources()
		.acceptHeader("""pson, b64_zlib_yaml, yaml, raw""")
		.acceptEncodingHeader("""identity""")
		.contentTypeHeader("""application/x-www-form-urlencoded""")
		.userAgentHeader("""Ruby""")

  val headers_3 = Map("""Accept""" -> """pson, b64_zlib_yaml, yaml, dot, raw""")

  val headers_12 = Map(
		"""Accept""" -> """pson, yaml""",
		"""Content-Type""" -> """text/pson""")

  val uri1 = """https://puppet-master:8140/production"""



	val chain_0 = exec(
          // node request
http("node")
			.get(uri1 + """/node/puppet-master?transaction_uuid=460cc8c1-2cd6-43b5-bfee-d29ac7438788&fail_on_404=true""")


// file meta plugin fact request 
		.resources(

http("filemeta_plugin_facts")
			.get(uri1 + """/file_metadatas/pluginfacts?links=manage&recurse=true&ignore=.svn&ignore=CVS&ignore=.git&checksum_type=md5"""),

	
// file meta plugin request
		http("filemeta_plugins")
			.get("""/production/file_metadatas/plugins?links=manage&recurse=true&ignore=.svn&ignore=CVS&ignore=.git&checksum_type=md5"""),
		

// catalog request
		http("catalog")
			.post("""/production/catalog/puppet-master""")
			.headers(headers_3) 
			.formParam("""facts""", """%7B%22name%22%3A%22puppet-master%22%2C%22values%22%3A%7B%22puppetversion%22%3A%223.7.2+%28Puppet+Enterprise+3.4.0-rc1-1757-g53b0768%29%22%2C%22netmask%22%3A%22255.255.252.0%22%2C%22hardwaremodel%22%3A%22x86_64%22%2C%22osfamily%22%3A%22RedHat%22%2C%22fqdn%22%3A%22puppet-master.delivery.puppetlabs.net%22%2C%22system_uptime%22%3A%7B%22seconds%22%3A251%2C%22hours%22%3A0%2C%22days%22%3A0%2C%22uptime%22%3A%220%3A04+hours%22%7D%2C%22uptime_seconds%22%3A251%2C%22operatingsystemrelease%22%3A%226.5%22%2C%22selinux%22%3A%22true%22%2C%22selinux_enforced%22%3A%22true%22%2C%22selinux_policyversion%22%3A%2224%22%2C%22selinux_current_mode%22%3A%22enforcing%22%2C%22selinux_config_mode%22%3A%22enforcing%22%2C%22selinux_config_policy%22%3A%22targeted%22%2C%22kernelversion%22%3A%222.6.32%22%2C%22interfaces%22%3A%22eth0%2Clo%22%2C%22kernel%22%3A%22Linux%22%2C%22ipaddress_eth0%22%3A%2210.0.24.227%22%2C%22macaddress_eth0%22%3A%2200%3A0C%3A29%3AD1%3A1A%3A4C%22%2C%22netmask_eth0%22%3A%22255.255.252.0%22%2C%22mtu_eth0%22%3A%221500%22%2C%22ipaddress_lo%22%3A%22127.0.0.1%22%2C%22netmask_lo%22%3A%22255.0.0.0%22%2C%22mtu_lo%22%3A%2216436%22%2C%22filesystems%22%3A%22ext4%2Ciso9660%22%2C%22virtual%22%3A%22vmware%22%2C%22is_virtual%22%3A%22true%22%2C%22architecture%22%3A%22x86_64%22%2C%22operatingsystem%22%3A%22CentOS%22%2C%22os%22%3A%7B%22name%22%3A%22CentOS%22%2C%22family%22%3A%22RedHat%22%2C%22release%22%3A%7B%22major%22%3A%226%22%2C%22minor%22%3A%225%22%2C%22full%22%3A%226.5%22%7D%7D%2C%22kernelrelease%22%3A%222.6.32-431.el6.x86_64%22%2C%22kernelmajversion%22%3A%222.6%22%2C%22augeasversion%22%3A%221.2.0%22%2C%22rubysitedir%22%3A%22%2Fopt%2Fpuppet%2Flib%2Fruby%2Fsite_ruby%2F1.9.1%22%2C%22rubyplatform%22%3A%22x86_64-linux%22%2C%22partitions%22%3A%7B%22sda1%22%3A%7B%22uuid%22%3A%22588f4b5e-6812-479d-8057-fc61779ab674%22%2C%22size%22%3A%221024000%22%2C%22mount%22%3A%22%2Fboot%22%2C%22filesystem%22%3A%22ext4%22%7D%2C%22sda2%22%3A%7B%22size%22%3A%2240916992%22%2C%22filesystem%22%3A%22LVM2_member%22%7D%7D%2C%22network_eth0%22%3A%2210.0.24.0%22%2C%22network_lo%22%3A%22127.0.0.0%22%2C%22ipaddress%22%3A%2210.0.24.227%22%2C%22facterversion%22%3A%222.2.0%22%2C%22macaddress%22%3A%2200%3A0C%3A29%3AD1%3A1A%3A4C%22%2C%22sshdsakey%22%3A%22AAAAB3NzaC1kc3MAAACBAJ0zNcxZ4wU6387kUJ0GfrSgGmAwuS8xTVcak%2F%2BSnLQ9M%2FFPMCWJ1FJDj5oNqV6HyIKoY4q0ngVxiyyTO3%2FFNfF7w29VdtDLubREMMUWy%2FSDFa5qR6lkpEncFfkyKwM95MZ5hPFTLR4MQ8uyLr7elLXKvyGUVY4ibKTxohMVPwWLAAAAFQDpbT1yveJXgtEbtIbXkNgQmFc2OwAAAIEAmmlYONtMgRw2HUWLBKdLaKB8ShsT2YeoPZKD5vPFNA7jni4E83AR4bKekWxA4x0wHXfyJrQNFI6I5EeIzGkFq8stsUsL8N4N%2Fw3JCfTTMbxZXxMtS1zbvrorv44VkXXpdVvHiA%2FBF19Gz3jyOEh9US7XzQV1aCF%2B0DcniEs4pvcAAACBAJWB6ab49hj1SOyZpZ%2FGS3sUhhxwbhStE5OkCaAPWg3Kf3g6vaR5DpB3nbVOgQBqqoBsfND%2BwG8dFCONxGWlqGcRJOoINgC7P%2BOkw2etgjYKinyMxP7IcejYrTf0u6La%2BfLl9NVysSn3GVMZfx8Eey6xCGwFMLVTlBed0BfUDBJ%2B%22%2C%22sshfp_dsa%22%3A%22SSHFP+2+1+0245710ba274706e6303727e3578791a23434b00%5CnSSHFP+2+2+2bb5f315d03d65be1f0572f4b3741d3b687fbd07a392a98414e67a5ab1bf58fa%22%2C%22sshrsakey%22%3A%22AAAAB3NzaC1yc2EAAAABIwAAAQEA7BUad2fRw3AHmTZX%2BVcfmT43OgA2WZpqdpF4nfNGq2qQTUfLiOBsz1fdQNcnaofWZ%2FJjH0wwl1687wMave20foEM5X0krl2gwoKKZwzhvjrMU%2BWnLa5M%2BHs9deutq5zhMs7ZbC5kj4uhOTyjzRv%2BdZOfxJbc88tvhRoqsT%2BiHHRrXkmhV1WeQGtKiwbzb3OVhSjvWfHWVfQGj92TcFB5GP0%2FPE557IdwI%2BUo8Us6E9IrzYCpNInTdG77u2EvLZXtephTu%2BV75f6T9Kuai1e3Mjh0D6vVB1Q37Gx93DJqEQJQq%2FpMYf0As7KBKYShMJYBO7vvt3IPFxTFEPmjUBrBNw%3D%3D%22%2C%22sshfp_rsa%22%3A%22SSHFP+1+1+6473dfc4c38ccf15dbd60ea44c6191c954e7688e%5CnSSHFP+1+2+43d559160249bd5e2ce3f56f2ab1c5c66dec9e1cec20594167089708e1a228d4%22%2C%22uptime_days%22%3A0%2C%22processors%22%3A%7B%22models%22%3A%5B%22Intel%28R%29+Core%28TM%29+i5-4288U+CPU+%40+2.60GHz%22%5D%2C%22count%22%3A1%2C%22physicalcount%22%3A1%7D%2C%22processor0%22%3A%22Intel%28R%29+Core%28TM%29+i5-4288U+CPU+%40+2.60GHz%22%2C%22processorcount%22%3A%221%22%2C%22ps%22%3A%22ps+-ef%22%2C%22path%22%3A%22%2Fusr%2Flocal%2Fsbin%3A%2Fusr%2Flocal%2Fbin%3A%2Fsbin%3A%2Fbin%3A%2Fusr%2Fsbin%3A%2Fusr%2Fbin%3A%2Froot%2Fbin%22%2C%22memorysize%22%3A%22988.62+MB%22%2C%22memoryfree%22%3A%2282.60+MB%22%2C%22swapsize%22%3A%221.94+GB%22%2C%22swapfree%22%3A%221.34+GB%22%2C%22swapsize_mb%22%3A%221983.99%22%2C%22swapfree_mb%22%3A%221373.96%22%2C%22memorysize_mb%22%3A%22988.62%22%2C%22memoryfree_mb%22%3A%2282.60%22%2C%22uptime%22%3A%220%3A04+hours%22%2C%22blockdevice_sr0_size%22%3A417333248%2C%22blockdevice_sr0_vendor%22%3A%22NECVMWar%22%2C%22blockdevice_sr0_model%22%3A%22VMware+IDE+CDR10%22%2C%22blockdevice_sda_size%22%3A21474836480%2C%22blockdevice_sda_vendor%22%3A%22VMware%2C%22%2C%22blockdevice_sda_model%22%3A%22VMware+Virtual+S%22%2C%22blockdevices%22%3A%22sda%2Csr0%22%2C%22gid%22%3A%22root%22%2C%22physicalprocessorcount%22%3A%221%22%2C%22boardmanufacturer%22%3A%22Intel+Corporation%22%2C%22boardproductname%22%3A%22440BX+Desktop+Reference+Platform%22%2C%22boardserialnumber%22%3A%22None%22%2C%22bios_vendor%22%3A%22Phoenix+Technologies+LTD%22%2C%22bios_version%22%3A%226.00%22%2C%22bios_release_date%22%3A%2207%2F31%2F2013%22%2C%22manufacturer%22%3A%22VMware%2C+Inc.%22%2C%22productname%22%3A%22VMware+Virtual+Platform%22%2C%22serialnumber%22%3A%22VMware-56+4d+4a+5c+8d+88+27+78-a1+a8+bc+55+46+d1+1a+4c%22%2C%22uuid%22%3A%22564D4A5C-8D88-2778-A1A8-BC5546D11A4C%22%2C%22type%22%3A%22Other%22%2C%22id%22%3A%22root%22%2C%22operatingsystemmajrelease%22%3A%226%22%2C%22hostname%22%3A%22puppet-master%22%2C%22timezone%22%3A%22PDT%22%2C%22domain%22%3A%22delivery.puppetlabs.net%22%2C%22uniqueid%22%3A%22000ae318%22%2C%22hardwareisa%22%3A%22x86_64%22%2C%22uptime_hours%22%3A0%2C%22rubyversion%22%3A%221.9.3%22%2C%22pe_build%22%3A%223.4.0-rc1-1757-g53b0768%22%2C%22pe_concat_basedir%22%3A%22%2Fvar%2Fopt%2Flib%2Fpe-puppet%2Fpe_concat%22%2C%22pe_version%22%3A%223.4.0%22%2C%22is_pe%22%3Atrue%2C%22pe_major_version%22%3A%223%22%2C%22pe_minor_version%22%3A%224%22%2C%22pe_patch_version%22%3A%220%22%2C%22custom_auth_conf%22%3A%22true%22%2C%22platform_tag%22%3A%22el-6-x86_64%22%2C%22staging_http_get%22%3A%22curl%22%2C%22clientcert%22%3A%22puppet-master%22%2C%22clientversion%22%3A%223.7.2+%28Puppet+Enterprise+3.4.0-rc1-1757-g53b0768%29%22%2C%22clientnoop%22%3Afalse%7D%2C%22timestamp%22%3A%222015-10-25+08%3A30%3A42+-0700%22%2C%22expiration%22%3A%222015-10-25T09%3A00%3A42.462391096-07%3A00%22%7D""")
		  .formParam("""transaction_uuid""", """460cc8c1-2cd6-43b5-bfee-d29ac7438788""")
		  .formParam("""fail_on_404""", """true""")
		  .formParam("""facts_format""", """pson"""),
	

// file meta requests
 // .resources(

  http("filemeta")
    .get("""/production/file_metadata/modules/pe_repo/GPG-KEY-puppetlabs?links=manage&source_permissions=use"""),

  http("filemeta")
    .get("""/production/file_metadatas/pe_modules?links=manage&recurse=true&checksum_type=md5"""),

  http("filemeta")
    .get(uri1 + """/file_metadatas/modules/puppet_enterprise/mcollective/plugins?links=manage&recurse=true&checksum_type=md5"""),

  http("filemeta")
    .get("""/production/file_metadata/modules/pe_concat/concatfragments.sh?links=manage&source_permissions=use"""),

  http("filemeta")
    .get("""/production/file_metadata/modules/pe_accounts/shell/bashrc?links=manage&source_permissions=use"""),
                  http("filemeta")
                    .get(uri1 + """/file_metadata/modules/pe_accounts/shell/bash_profile?links=manage&source_permissions=use"""),
                  http("filemeta")
		    .get(uri1 + """/file_metadata/modules/pe_accounts/shell/bashrc?links=manage&source_permissions=use"""),
                  http("filemeta")
		    .get(uri1 + """/file_metadata/modules/pe_accounts/shell/bash_profile?links=manage&source_permissions=use"""),
//                    .resources(



// report request 
    http("report")
			    .put("""/production/report/puppet-master""")
			    .headers(headers_12)
			    .body(RawFileBody("./request-bodies/PE371Clamps_report.txt"))))
  //)))







	val scn = scenario("PE371_Clamps").exec(chain_0)
        val REPETITION_COUNTER: String = "repetitionCounter"
        val NUM_AGENTS: Int = 1
        val NUM_REPETITIONS: Int = 2
        val SLEEP_DURATION: FiniteDuration = 3 minutes
        val RAMP_UP_DURATION: FiniteDuration = 3 minutes

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






