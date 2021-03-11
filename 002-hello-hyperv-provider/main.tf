terraform {
    required_providers {
        hyperv = {
            version = "1.0.1"
            source = "registry.terraform.io/taliesins/hyperv"
        }
    }
}

provider "hyperv" {

}

resource "hyperv_network_switch" "dmz_network_switch" {
    name = "dmz"
}

resource "hyperv_vhd" "pblab_test_001_vhd" {
    path = "c:\\vhdx\\pblab_test_001.vhdx"
    size = 10737412742 #10gb
}

resource "hyperv_machine_instance" "pblab_test_001" {
    name = "pblab_test_001"
    generation = 1
    processor_count = 2
    memory_startup_bytes = 536870912 #512mb
    wait_for_state_timeout = 10
    wait_for_ips_timeout = 10

    vm_processor {
        expose_virtualization_extensions = true
    }

    network_adaptors {
        name = "wan"
        switch_name = "hyperv_network_switch.dmz_network_switch.name"
        wait_for_ips = false
    }

    hard_disk_drives {
        controller_type = "Ide"
        path = hyperv_vhd.pblab_test_001_vhd.path
        controller_number = 0
        controller_location = 0
    }

    dvd_drives {
        controller_number = 0
        controller_location = 1
        path = "C:\\iso\\ubuntu-20.04.2-live-server-amd64.iso"
    }

}


