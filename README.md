# fastdfs-client-ruby

fastdfs client for ruby 

### Install

    gem install 'fastdfs-client'

### Using

```RUBY
  
  require 'fastdfs-client'

  # return the result format 
  #  {status: true, err_msg: "", result: ...}
  #


  tracker = Fastdfs::Client::Tracker.new(trackers: {host: "192.168.1.1", port: "22122"})

  # multiple trackers server
  # trackers: [
  #  {host: "192.168.1.1", port: "22122"},
  #  {host: "192.168.1.2", port: "22122"}
  # ]

  # socket connection KEEPALIVE
  tracker.pipeline do |s| 
    files.each do |file|
      s.upload(s)
    end
  end

  # @file class includes [File, Tempfile, ActionDispatch::Http::UploadedFile]
  @tracker.upload(@file)
  #result: {group_name: "group1", path: "m1/xfsd/fds.jpg"}

  @tracker.delete(path, group_name)  

  # flag params [cover, merge]
  @tracker.set_metadata(path, group_name, {author: "kaka", width: "300"}, flag)

  @tracker.get_metadata(path, group_name) 
  #result: {author: "kaka", width: "300"}

  @tracker.download(path, group_name) 
  #result: #<Tempfile:/var/folders/m7/bt2j0rk54x555t44dpn4b7bm0000gn/T/test.jpg20160416-43738-1560vq3>  


  # Make compatible 1.x version
  
  @storage = tracker.get_storage
  
  @storage.upload ...
  @storage.delete ...
  @storage.set_metadata ...
  @storage.get_metadata ...
  @storage.download ...

```

### License

[MIT License](https://opensource.org/licenses/MIT)