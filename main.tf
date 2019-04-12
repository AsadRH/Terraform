resource "google_compute_address" "test-static-ip-address" {
  name = "my-test-static-ip-address"
}

//resource "google_compute_project_metadata_item" "ssh-keys" {
//  key   = "ssh-keys"
//  value = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
//}

//resource "google_compute_disk" "deloittord360" {
//  name  = "deloittord360"
//  type  = "pd-ssd"
//  zone  = "${var.zone}"
//  size  = 30
//  snapshot = "${google_compute_snapshot.ubuntu-beaver.name}"
//}

resource "google_compute_instance" "deloitte-ord360" {
  name         = "deloitte-ord360-dev"
  machine_type = "f1-micro"
  zone         = "${var.zone}" 


  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
      size  = 30
      type  = "pd-ssd"
    }
  }

  // Local SSD disk
//  scratch_disk {
//  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet.name}"

    access_config {
      nat_ip = "${google_compute_address.test-static-ip-address.address}"
    }
  }

   metadata = {
    sshKeys = "${var.INSTANCE_USERNAME}:${file(var.PATH_TO_PUBLIC_KEY)}"
   }

 // metadata_startup_script = "echo hi > /test.txt"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  

//  connection {
//    user = "${var.INSTANCE_USERNAME}"
//    private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"

//  }
}


// Create VPC
resource "google_compute_network" "vpc" {
 name                    = "${var.name}-vpc"
 auto_create_subnetworks = "false"
}

// Create Subnet
resource "google_compute_subnetwork" "subnet" {
 name          = "${var.name}-subnet"
 ip_cidr_range = "${var.subnet_cidr}"
 network       = "${google_compute_network.vpc.name}"
 depends_on    = ["google_compute_network.vpc"]
 region      = "${var.region}"
}

// VPC firewall configuration
resource "google_compute_firewall" "firewall" {
  name    = "${var.name}-firewall"
  network = "${google_compute_network.vpc.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



