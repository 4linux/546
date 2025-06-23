provider "google" {
  region  = var.region
  zone    = var.zone
}

resource "google_compute_address" "static_ip" {
  name   = "${var.instance_name}-ip"
  region = var.region
}

resource "google_compute_instance" "workstation" {
  name         = var.instance_name
  machine_type = "n2-standard-8"
  zone         = var.zone
  tags         = [var.instance_name]

  boot_disk {
    initialize_params {
      image  = "projects/rocky-linux-cloud/global/images/rocky-linux-9-optimized-gcp-v20250513"
      size   = 100
      type   = "pd-ssd"
    }
  }

  advanced_machine_features {
    enable_nested_virtualization = true
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }
  metadata = {
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
    setenforce 0

    yum groupinstall -y "Workstation"
    dnf install -y git python3 python3-pip tigervnc-server
    pip3 install websockify

    mkdir -p /opt && cd /opt
    git clone https://github.com/novnc/noVNC.git
    cd /opt/noVNC
    git clone https://github.com/novnc/websockify

    GCP_USER=$(basename /var/google-sudoers.d/*)

    cat <<EOL > /etc/systemd/system/vncserver@\:1.service
    [Unit]
    Description=Remote desktop service (VNC)
    After=network.target

    [Service]
    Type=forking
    User=${var.gcp_user}
    ExecStart=/usr/bin/vncserver :1 -geometry 1920x1080 -depth 24 -SecurityTypes None
    ExecStop=/usr/bin/vncserver -kill :1
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target
    EOL

    systemctl daemon-reload
    systemctl enable vncserver@:1.service
    systemctl restart vncserver@:1.service

    cat <<EOL > /etc/systemd/system/novnc.service
    [Unit]
    Description=noVNC Web Interface
    After=network.target vncserver@:1.service
    Requires=vncserver@:1.service

    [Service]
    Type=simple
    User=${var.gcp_user}
    WorkingDirectory=/opt/noVNC
    ExecStart=/opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080
    Restart=on-failure
    RestartSec=2

    [Install]
    WantedBy=multi-user.target
    EOL

    systemctl daemon-reexec
    systemctl daemon-reload
    systemctl enable novnc.service
    systemctl restart novnc.service

    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --permanent --add-port=443/tcp
    firewall-cmd --permanent --add-port=5901/tcp
    firewall-cmd --permanent --add-port=6080/tcp
    firewall-cmd --permanent --add-port=8080/tcp
    firewall-cmd --permanent --add-port=8081/tcp
    firewall-cmd --permanent --add-port=8082/tcp
    firewall-cmd --reload
  EOF
}

resource "google_compute_firewall" "allow_custom_ports" {
  name    = "allow-custom-ports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "5901", "6080", "8080", "8081", "8082"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.instance_name]
}
