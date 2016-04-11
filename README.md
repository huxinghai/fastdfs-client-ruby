# fastdfs-client-ruby

fastdfs client for ruby 

### Install

    #Gemfile
    gem 'fastdfs-client', git: "git@github.com:huxinghai1988/fastdfs-client-ruby.git"

### Using

```RUBY
  tracker = new Fastdfs::Client::Tracker("192.168.1.1", "22122")

  @storage = tracker.get_storage

  @storage.upload(@file)

  #group_name + path
  @storage.delete(path)
```