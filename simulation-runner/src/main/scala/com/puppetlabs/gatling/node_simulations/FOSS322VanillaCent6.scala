package com.puppetlabs.gatling.node_simulations
import com.excilys.ebi.gatling.core.Predef._
import com.excilys.ebi.gatling.http.Predef._
import com.excilys.ebi.gatling.jdbc.Predef._
import com.excilys.ebi.gatling.http.Headers.Names._
import akka.util.duration._
import bootstrap._
import assertions._
import com.puppetlabs.gatling.runner.SimulationWithScenario

class FOSS322VanillaCent6 extends SimulationWithScenario {

  val httpConf = httpConfig
    .baseURL("https://pe-centos6:8140")
    .acceptHeader("pson, yaml, b64_zlib_yaml, raw")
    .connection("close")


  val headers_3 = Map(
    "Accept" -> """pson, yaml, b64_zlib_yaml, dot, raw""",
    "Content-Type" -> """application/x-www-form-urlencoded"""
  )

  val headers_4 = Map(
    "Content-Type" -> """text/pson"""
  )


  val scn = scenario("Scenario Name")
    .exec(http("node")
    .get("/production/node/pe-centos6.localdomain")
  )
    .pause(192 milliseconds)
    .exec(http("filemeta plugins")
    .get("/production/file_metadatas/plugins")
    .queryParam("""checksum_type""", """md5""")
    .queryParam("""links""", """manage""")
    .queryParam("""recurse""", """true""")
    .queryParam("""ignore""", """.svn""")
    .queryParam("""ignore""", """CVS""")
    .queryParam("""ignore""", """.git""")
  )
    .pause(483 milliseconds)
    .exec(http("catalog")
    .post("/production/catalog/pe-centos6.localdomain")
    .headers(headers_3)
    .param("""facts""", """%7B%22expiration%22%3A%22Mon+Apr+08+10%3A04%3A01+-0700+2013%22%2C%22timestamp%22%3A%22Mon+Apr+08+09%3A34%3A01+-0700+2013%22%2C%22name%22%3A%22pe-centos6.localdomain%22%2C%22values%22%3A%7B%22ipaddress_eth0%22%3A%22192.168.203.128%22%2C%22network_lo%22%3A%22127.0.0.0%22%2C%22operatingsystem%22%3A%22CentOS%22%2C%22uptime_seconds%22%3A%2219761%22%2C%22memorysize_mb%22%3A%22499.57%22%2C%22mtu_eth0%22%3A%221500%22%2C%22swapfree%22%3A%221.97+GB%22%2C%22kernelmajversion%22%3A%222.6%22%2C%22uptime%22%3A%225%3A29+hours%22%2C%22timezone%22%3A%22PDT%22%2C%22swapsize_mb%22%3A%222015.99%22%2C%22operatingsystemmajrelease%22%3A%226%22%2C%22architecture%22%3A%22i386%22%2C%22ps%22%3A%22ps+-ef%22%2C%22hostname%22%3A%22pe-centos6%22%2C%22selinux%22%3A%22true%22%2C%22blockdevice_sr0_size%22%3A%221073741312%22%2C%22netmask_eth0%22%3A%22255.255.255.0%22%2C%22memoryfree_mb%22%3A%22348.20%22%2C%22processor0%22%3A%22Intel%28R%29+Core%28TM%29+i7-3537U+CPU+%40+2.00GHz%22%2C%22activeprocessorcount%22%3A%221%22%2C%22kernelversion%22%3A%222.6.32%22%2C%22blockdevice_sda_vendor%22%3A%22VMware%2C%22%2C%22swapfree_mb%22%3A%222015.99%22%2C%22totalprocessorcount%22%3A%221%22%2C%22network_eth0%22%3A%22192.168.203.0%22%2C%22memorysize%22%3A%22499.57+MB%22%2C%22clientcert%22%3A%22pe-centos6.localdomain%22%2C%22ipaddress%22%3A%22192.168.203.128%22%2C%22memorytotal%22%3A%22499.57+MB%22%2C%22sshfp_dsa%22%3A%22SSHFP+2+1+ab46b8308db7fac2f6d5b1929e18519b64965488%5CnSSHFP+2+2+34b0929769450d342c5b7b26f1ffb185fa7bc5692261d413041b01dbab41492f%22%2C%22physicalprocessorcount%22%3A%221%22%2C%22macaddress_eth0%22%3A%2200%3A0C%3A29%3A23%3A5A%3A78%22%2C%22id%22%3A%22root%22%2C%22kernelrelease%22%3A%222.6.32-71.29.1.el6.i686%22%2C%22operatingsystemrelease%22%3A%226.0%22%2C%22swapsize%22%3A%221.97+GB%22%2C%22clientversion%22%3A%223.2.2%22%2C%22selinux_enforced%22%3A%22true%22%2C%22domain%22%3A%22localdomain%22%2C%22blockdevice_sda_size%22%3A%2221474836480%22%2C%22uptime_hours%22%3A%225%22%2C%22path%22%3A%22%2Fusr%2Flocal%2Fsbin%3A%2Fusr%2Flocal%2Fbin%3A%2Fsbin%3A%2Fbin%3A%2Fusr%2Fsbin%3A%2Fusr%2Fbin%3A%2Froot%2Fbin%22%2C%22facterversion%22%3A%221.7.2-rc1%22%2C%22blockdevice_sr0_model%22%3A%22VMware+IDE+CDR10%22%2C%22selinux_config_policy%22%3A%22targeted%22%2C%22selinux_config_mode%22%3A%22enforcing%22%2C%22sshdsakey%22%3A%22AAAAB3NzaC1kc3MAAACBAIAxQbvg35Vz5gSDke9LA9qlLZbVBIWtVLziBuacl6HF6zW1MFBkrLrrILBKzjLOUbdRe0n4wTgwCXLLAaRR3S0fO8onhxJgsPL7veDfMEtIie0n9NyXdtFSrX2pHV7WP5ImacSl8gRc0yap6YgMobTy0duiHETGHo%2FMBP6DpJShAAAAFQD4%2BScIRX5ihyBPi91AcDZL4ACTiwAAAIAT%2F7IDML2LMHFuy2SIQgcEddb4ccd6A0mP6AYQldGGkABHuiBigpqDLA6o01i6mj%2F5LSKLDJWZwj96k6nx4tkFUUtWmT%2BjUH7ehPA06QenUFayP%2Bc14CSLwNIy45XrjmhRz%2F6vqlgigYGagPXC%2BT9rozWsu8TWIwwlF0daL%2BQBPgAAAIACegwbLV6tjItniKPjTMhGs2ejtAl5ILUXgrb2LX4UltkXgLPW86bhGKV1XS0IqZ1tC01EU03JoVVk2VuT9sJpc3QoCM6ndiR5ktD1VndsFohGv13xUZ8FJiA9wjn7gsxTliO3mc1N5m5eCD0otrfUyVflGz6xqwvi1TtkJZ5IFw%3D%3D%22%2C%22osfamily%22%3A%22RedHat%22%2C%22kernel%22%3A%22Linux%22%2C%22selinux_current_mode%22%3A%22enforcing%22%2C%22blockdevice_sr0_vendor%22%3A%22NECVMWar%22%2C%22macaddress%22%3A%2200%3A0C%3A29%3A23%3A5A%3A78%22%2C%22fqdn%22%3A%22pe-centos6.localdomain%22%2C%22hardwareisa%22%3A%22i686%22%2C%22mtu_lo%22%3A%2216436%22%2C%22hardwaremodel%22%3A%22i686%22%2C%22virtual%22%3A%22physical%22%2C%22selinux_mode%22%3A%22targeted%22%2C%22blockdevices%22%3A%22sr0%2Csda%22%2C%22processorcount%22%3A%221%22%2C%22uptime_days%22%3A%220%22%2C%22blockdevice_sda_model%22%3A%22VMware+Virtual+S%22%2C%22memoryfree%22%3A%22348.20+MB%22%2C%22rubyversion%22%3A%221.8.7%22%2C%22interfaces%22%3A%22lo%2Ceth0%22%2C%22rubysitedir%22%3A%22%2Fusr%2Flib%2Fruby%2Fsite_ruby%2F1.8%22%2C%22filesystems%22%3A%22iso9660%2Cext4%22%2C%22netmask_lo%22%3A%22255.0.0.0%22%2C%22is_virtual%22%3A%22false%22%2C%22sshfp_rsa%22%3A%22SSHFP+1+1+bc7c7047cc57be084420a5cadce31a3e56906380%5CnSSHFP+1+2+9ace269250f0186657e4100c38aa1feffee21fd4a9787e5e8e5af88667fd166d%22%2C%22puppetversion%22%3A%223.2.2%22%2C%22selinux_policyversion%22%3A%2224%22%2C%22ipaddress_lo%22%3A%22127.0.0.1%22%2C%22netmask%22%3A%22255.255.255.0%22%2C%22uniqueid%22%3A%22a8c080cb%22%2C%22sshrsakey%22%3A%22AAAAB3NzaC1yc2EAAAABIwAAAQEAs%2BxZBwOTho9SNjQIAnkvBskjuxR92GoGLU%2BQTcD1j7hk8ti4uLPpE6Ledqb0MgOUny92p1yI0lDw1lSx4eRQ4xmoNdbNz7vhCjIR6qv88bU5CLNjy9dPf2j6%2BwlJrEjtSbluv3WiYGqYwDRX7nuY9EODn8h1YJ3VLDrz%2FF8dm8MKHHQj7KhVwFICCXbzQTNBZ5Md0JHCuG7vuOZx9KgMf%2BP44L86csVUWFo1pSVdltmfT8v0OS0O579XmAHKeBuYCRBEjoAWj40bWAUWMTsm2YoEYu70i3B4UPuLMxrNdvsPOXJCDkawCLjmBnpQaGZM8BI9KCyY3Qma6Gu2648S2Q%3D%3D%22%7D%7D""")
    .param("""facts_format""", """pson""")
  )
    .pause(293 milliseconds)
    .exec(http("report")
    .put("/production/report/pe-centos6.localdomain")
    .headers(headers_4)
    .fileBody("FOSS322VanillaCent6_request_4.txt")
  )

  setUp(scn.users(1).protocolConfig(httpConf))
}