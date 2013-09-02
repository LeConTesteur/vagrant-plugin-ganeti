# Vagrant Ganeti Provider
This is a Vagrant 1.2+ plugin that adds an Ganeti provider to Vagrant, allowing Vagrant to control and provision 
machines in Ganeti.

NOTE: This plugin requires Vagrant 1.2
NOTE: This project is work in progress, there are lot of things which might not work yet.

## Installation

Building the Gem from source:

    $  gem build 'vagrant-plugin-ganeti.gemspec'


Alternatively you could, Install using standard Vagrant 1.1+ plugin installation methods. After installing, vagrant up and specify the ganeti provider. An example is shown below.

    $  vagrant plugin install vagrant-plugin-ganeti

## Usage

    $ vagrant up --provider=ganeti
    ...
Of course prior to doing this, you'll need to obtain an Ganeti-compatible box file for Vagrant.


##Quick Start

After installing the plugin (instructions above), the quickest way to get started is to actually use a "ganeti" Ganeti box and specify all the details manually within a config.vm.provider block. So first, add the "ganeti" box using any name you want:

$ vagrant box add ganeti https://raw.github.com/osuosl/vagrant-plugin-ganeti/master/example_box/ganeti.box
...
And then make a Vagrantfile that looks like the following, filling in your information where necessary.

    Vagrant.configure("2") do |config|
      config.vm.box = "ganeti"
      config.vm.provider :ganeti do |ganeti, override|
        ganeti.rapi_user = "#rapiuser"
        ganeti.rapi_pass = "#password"
        ganeti.cluster = "https://10.10.10.10:5080/"
        ganeti.os_type = "image+debian-squeeze"
        ganeti.instance_name = "gimager3.organisation.org"
        ganeti.pnode = "gnode.organisation.org"
        ganeti.disks =[{"size"=>"8000"}] 
        ganeti.disk_template = "plain"
        override.ssh.username = "root"
      end
    end


And then run vagrant up --provider=ganeti.
        
This will start an  instance in the Ganeti Cluster.

Other overridable settings include 

        override.ssh.username = "User Name"
        override.ssh.private_key_path = "Path to your private key"

If you have issues with SSH connecting, make sure that the instances are being launched with a security group that allows SSH access.

## Box Format

Every provider in Vagrant must introduce a custom box format. This
provider introduces `ganeti` boxes. You can view an example box in
the [example_box/ directory](https://github.com/osuosl/vagrant-plugin-ganeti/master/example_box/).
That directory also contains instructions on how to build a box.

The box format is basically just the required `metadata.json` file
along with a `Vagrantfile` that does default settings for the
provider-specific configuration for this provider.

## Configuration

This provider exposes quite a few provider-specific configuration options:

* `rapi_user` - The username for accessing the RAPI. REQUIRED
* `rapi_pass` - The password for the corrensponding user. REQUIRED
* `cluster` - The host address of the master Ganeti Node. REQUIRED
* * `instance_name` - The name of the instance. REQUIRED
* `os_type` - The OS that needs to be booted up. Note : This will override the default box . OPTIONAL
* `mode` - Mode of creation. Defaults to create. OPTIONAL
* `pnode` - The primary node where instance needs to be created. Defaults to None. OPTIONAL
* `snode` - The Secondary node in case of drbd is used. Defaults to None. OPTIONAL
* `nics` - Network configuration. OPTIONAL
    * List of (Dictionary with keys of (OneOf bridge, name, ip, vlan, mac, link, mode, network) and values of (None or String)
* `disks` - The Size of the Disks . Defaults to 8 G . OPTIONAL
    * List of (Dictionary with keys of (OneOf name, vg, adopt, spindles, mode, provider, metavg, size) and values of (NonEmptyString or Integer)
* `disk_template` - The type of the disk template. Defaults to plain . OPTIONAL
* `iallocator` - The name of the iallocator policy. Defaults to cluster default . OPTIONAL
* `memory` - The size of the memory. Defaults to plain . OPTIONAL
* `vcpus` - The No of VCPUS . Defaults to None . OPTIONAL
* `ip_check` - Either 'true' or 'false' (Without quotes). Defaults to true . OPTIONAL
* `name_check` - Either 'true' or 'false' (Without quotes) . Defaults to true . OPTIONAL


hvparams settings
* `boot_order` - Defaults to None . OPTIONAL
* `cdrom_image_path` - Defaults to None . OPTIONAL
* `nic_type` - Defaults to None . OPTIONAL
* `disk_type` - Defaults to None . OPTIONAL
* `cpu_type` - Defaults to None . OPTIONAL
* `kernel_path` - Defaults to None . OPTIONAL
* `kernel_args` - Defaults to None . OPTIONAL
* `initrd_path` - Defaults to None . OPTIONAL
* `root_path` - Defaults to None . OPTIONAL
* `serial_console` - Defaults to None . OPTIONAL
* `kvm_flag` - Defaults to None . OPTIONAL


## Networks

Networking features in the form of `config.vm.network` are not
supported with `vagrant-ganeti`, currently. If any of these are
specified, Vagrant will emit a warning, but will otherwise boot
the Ganeti machine.

## Synced Folders

There is minimal support for synced folders. Upon `vagrant provision`, the Ganeti provider will use
`rsync` (if available) to uni-directionally sync the folder to
the remote machine over SSH.

This is good enough for all built-in Vagrant provisioners (shell,
chef, and puppet) to work!


## TODO

1. Add more Features supported by RAPI

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
 
## About the Project
Author : Ahmed Shabib 
This project is done as part of GSOC -2013 ,and is mentored by Lance Albertson(Ramereth) and Ken Lett
