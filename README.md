# An unofficial UniFi Protect API in Ruby

This is an implementation of (parts of) [UniFi Protect](https://unifi-network.ui.com/building-security) API, which is primarily designed to support the local web interface. The API allows access to camera configuration, status, and of course the ability to collect real-time snapshots and export recorded video from the NVR.

Currently the API implemented in this Gem is read-only, but I do hope to allow setting at least some configuration such as camera parameters via the API. (For example, enabling or disabling IR modes, or zoom levels for cameras supporting optical zoom.)

_**Note**_: The details of the UniFi Protect API are unpublished and potentially unstable, so this is an unofficial and potentially equally unstable implementation of that API. This implementation is partly based on the Python [`unifi-protect-video-downloader`](https://github.com/unifi-toolbox/unifi-protect-video-downloader) script, as well as inspection of the actual API interactions through the UniFi Protect web interface.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unifi_protect'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install unifi_protect
```

## Usage of the library

Once installed, a `UnifiProtect` module is provided and its usage is fairly straightforward:

```ruby
require 'unifi_protect'

# Connect to the UniFi Protect API using HTTPS and basic authentication
u = UnifiProtect::Client.new(host: '1.2.3.4', username: 'bob', password: 'secret')

# Fetch all cameras as a CameraCollection:
u.cameras 

# Return a CameraCollection for all cameras matching a Regexp:
u.cameras.match(name: /house/i) 

# Some attributes can be filtered more simply, for example currently-connected cameras:
u.cameras.connected

# Filters can be chained together as they return new CameraCollection objects:
u.cameras.connected.recording.match(name: /^barn/i)

# If a single match is expected, #fetch will return #first from the collection directly:
c = u.cameras.fetch(name: 'Front Door')

# Once a Camera object is obtained, the current snapshot (in practice, one from within the past few
# seconds, cached by the NVR) can be retrieved from it using #snapshot, which returns a DownloadedFile
# object with #file and #size attributes:
d = c.snapshot

# => #<struct UnifiProtect::API::DownloadedFile file="5f33454c00d21103e701d84f_1598726026000.jpg", size=236855>

# Recorded video can be exported from the NVR as well, given a start_time and end_time; this returns
# a DownloadedFile object as well:
d = c.video_export(start_time: Time.now - 10, end_time: Time.now)

# => #<struct UnifiProtect::API::DownloadedFile file="5f33454c00d21103e701d84f_1598725975000_1598725985000.mp4", size=1019346>
```

## Usage of the command-line tool

A simple command-line tool is provided to make it especially easy to download snapshots and video from one or more cameras without doing any Ruby programming.

Listing cameras is simple using `--list-cameras` and supports a number of filters, such as `id`, `name`, `connected`, `recording`, etc.:

```
$ unifi_protect -H 1.2.3.4 -u bob -p secret --connected --name 'House' --list-cameras
ID                            Name                                    Type                State               
xxxxxxxxxxxxxxxxxxxxxxxx      Back of House Looking West              UVC G3 Flex         CONNECTED           
yyyyyyyyyyyyyyyyyyyyyyyy      Barn towards House                      UVC G3 Pro          CONNECTED           
zzzzzzzzzzzzzzzzzzzzzzzz      Back of House Looking South             UVC G3 Flex         CONNECTED           
```

More advanced filtering can be done using `--match`, `--match-i` and `--exact` arguments:

```
$ unifi_protect -H 1.2.3.4 -u bob -p secret --connected --match-i type=doorbell --list-cameras

ID                            Name                                    Type                State
xxxxxxxxxxxxxxxxxxxxxxxx      Front Door                              UVC G4 Doorbell     CONNECTED
```

More information about each camera can be obtained with `--describe-cameras`:

```
$ unifi_protect -H 1.2.3.4 -u bob -p secret --id yyyyyyyyyyyyyyyyyyyyyyyy --describe-cameras

Id                  : yyyyyyyyyyyyyyyyyyyyyyyy
Name                : Barn towards House
Type                : UVC G3 Pro
Mac                 : AABBCCDDEEFF
State               : CONNECTED
Hardware Revision   : 16
Firmware Version    : 4.26.13
Firmware Build      : 8a76001.200825.1028
Up Since            : 2020-08-25 06:15:04 -0700
Connected Since     : 2020-08-25 06:15:35 -0700
Last Motion         : 2020-08-28 05:22:26 -0700
Last Ring           : (none)
Last Seen           : 2020-08-29 11:37:59 -0700
```

A current snapshot can be downloaded from each matched camera using `--snapshot`:

```
$ unifi_protect -H 1.2.3.4 -u bob -p secret --id yyyyyyyyyyyyyyyyyyyyyyyy --snapshot

Downloading snapshot from yyyyyyyyyyyyyyyyyyyyyyyy, Barn towards House... OK, 427 KiB.
```

Recorded video can be exported from each matched camera using `--video-export` with appropriate `--start-time` and either `--end-time` or `--duration` parameters:

```
$ unifi_protect -H 1.2.3.4 -u bob -p secret --name '^Barn' --video-export --start-time '2020-08-29 11:00:00 PDT' --duration 30s

Exporting video for 2 cameras from 2020-08-29 11:00:00 -0700 to 2020-08-29 11:00:30 -0700.

Downloading video from xxxxxxxxxxxxxxxxxxxxxxxx, Barn Driveway... OK, 3256 KiB.
Downloading video from yyyyyyyyyyyyyyyyyyyyyyyy, Barn towards House... OK, 3364 KiB.
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome [through GitHub](https://github.com/jeremycole/unifi_protect).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
