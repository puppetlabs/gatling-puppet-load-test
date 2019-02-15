test_name "setup gitlab" do

  step "copy gitlab files" do
    scp_to(gitlab, "#{__dir__}/../../../cd4pe/gitlab", "/root")
  end

  step "install docker" do
    command = "cd gitlab && chmod 777 install_docker.sh && ./install_docker.sh"
    puts command
    on gitlab, command
  end

  step "run gitlab container" do
    command = "docker run --name=cd4pe-gitlab -d -p 80:80 -p 443:443 -p 8022:22 -v gitlab_etc:/etc/gitlab -v gitlab_opt:/var/opt/gitlab -v gitlab_log:/var/log/gitlab gitlab/gitlab-ce:latest"
    puts command
    on gitlab, command
  end

end
