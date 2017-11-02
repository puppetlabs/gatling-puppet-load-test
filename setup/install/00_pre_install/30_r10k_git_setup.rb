test_name 'setup r10k git repo' do

  # Get all hosts with role master or compile_master
  masters = select_hosts({:roles => ['master', 'compile_master']})

  step 'place private key on each master' do
    #public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCYh3jLwtuf1Ef/w/FZWqpsl4QS7RA4mkmeyIrbH8LQpAVAWBdLmU+x7vC0W1K47RgNjIVAGmiPwGY1MGc2ZakoFJWVLelq4ew8GiUODYOn7PAW531j6BmNNEJvWsNgfDw6EOj2r0VqOr+k3mttAG7NI1MfLlstIPJk/Ua13gPkKjUqK1GvZnf7lHXFqOMH31fZ1FPMUTqoLo5okMJ/l9axgBL08ibPdPoeJPa0xy2VHFdX9Ud9UnFblbIi6nlCngpfKJKeyiDURt6vUuFmEwrhumyWY75xRaXrif59FyXXtOBBPq8WAqTBkVjMUEyiWt/+j7nnbgwLsKGFcLPKhG/J deploykey@puppet-scale-control"
    private_key = <<-PRIVATE_KEY
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAmId4y8Lbn9RH/8PxWVqqbJeEEu0QOJpJnsiK2x/C0KQFQFgX
S5lPse7wtFtSuO0YDYyFQBpoj8BmNTBnNmWpKBSVlS3pauHsPBolDg2Dp+zwFud9
Y+gZjTRCb1rDYHw8OhDo9q9Fajq/pN5rbQBuzSNTHy5bLSDyZP1Gtd4D5Co1KitR
r2Z3+5R1xajjB99X2dRTzFE6qC6OaJDCf5fWsYAS9PImz3T6HiT2tMctlRxXV/VH
fVJxW5WyIup5Qp4KXyiSnsog1Eber1LhZhMK4bpslmO+cUWl64n+fRcl17TgQT6v
FgKkwZFYzFBMolrf/o+5524MC7ChhXCzyoRvyQIDAQABAoIBAAakb6g/9hyBvBjx
SYNgpWdROdkxJbGxVl9p0FI2kd9QJUJmE62hIY1YIHdaOsH+4TtF0U+3VrJb6JeM
YhJGXxV1wAXdF/sll4oOgWqZQBCCCvqUXiuJogM6MWJ0C2oaPu0wa1TC0T0NDed6
ICeBC1I3pZkIBcRzWNr5BKlK39SByNOMPoBLVBlf4oNUKSYWTJRwYajLae6z7czs
64Tj2G0llsgeDFkqyXmbbditJpktZPSY4bo5tmoxPGMsFfZMjpqPmCo+d++NLktJ
ZOISWsan8unhJQdGbnRlMB6JauXs1LWjYVIBuh6TtwbVqf9WpqVA+dL0mUVcPdxA
4SemxOECgYEAyqvS/DOLjrw9X0ajR3oHd1/GBPnnVbvetPbmGaVKkeUmqugWJ/R3
FQHUR1TiEq+ycxEp35Xmu9JNgSU5lpdl3FppTlA99pOiV6AcrCXRZf1Y7jiFyn/x
c6Q9MX13VanA+Qtbs5VTwXXuIFWl0EUVdi8SRfKJO2aFnRk5ZJxkVaUCgYEAwKoF
oJpeMdccnUtLh55luGerz1gl1mGmdAIEUYDW7YWqUjCqFM/yWx5jCFihLbQUfJXs
YsgTkU54k593BIpX2iPD3bS/RvRMdRPnb/Y70822NTAdjrmVs17VRqeU66+ua2Je
gE/LCrxQX+G0Ryw8zb5NRx0Kd9jg0RIXm+okAFUCgYEAr7rGiSlEc7HiYQ9Fmj9D
5AzmDQCGxn7Mfwqpv0jj3JbdrUjplSFSc6OPZX5DO8KeL0mNjjFSzD5wN2+IfHuv
tZ2rO102LOwb0nChC98Krq06g+v8jfXb7NJWwOeyJlO3X/mqPI9Y/SD9JYo96NVN
45iy9nVy6k9dwTbS3dsA4IUCgYAk2B7tYLgExgN13TFbhSIkysajh1LtFY2Uf9I9
l+sCT16MCzxrcH0DieMcdH6WU+rbDHzBQ0virOQILyW+m4pDcDWDz44Izq1UcnL/
CVLVpXBj6Yitg7YqMEePFHs5O0aayJwT466Lpgmk3G/ycHZMTklPATHAS5xqvw/+
xB8QZQKBgQCfx99/nY0DDRcKkz4ftKEQC7wCligcMeYvPvsyfEs/Sm4dmWXXwUmM
rvUWLYk1rsTvRhcCl2X9mV7kQhV5jy+rhI/0Xlt9q7YD+/eoE0+xrxsFdvClBfr/
B5mRrDUW3rwnPdxJ3eONw5l4AistswtRPc45jHSbEfRXJQZIlIxB6A==
-----END RSA PRIVATE KEY-----
PRIVATE_KEY

    ssh_config = <<SSH_CONFIG
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
SSH_CONFIG

    masters.each do |node|
      create_remote_file(node, "/root/.ssh/id_rsa", private_key)
      create_remote_file(node, "/root/.ssh/config", ssh_config)
      on node, "chmod 600 /root/.ssh/id_rsa /root/.ssh/config"
    end
  end

  step 'install git on masters for file syncing' do
    # vcloud VM's do not have git installed
    masters.each do |node|
      install_package node, 'git'
    end
  end
end
