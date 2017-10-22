require 'spec_helper'

BLOG_URI = "http://168ta.com"

class Profile

  def messages(limit, offset); [limit, offset] end

  def blog; BLOG_URI end

  def change_email; yield end

end

class User
  include Fastdfs::Client::Delegation

  delegate :messages, :blog, :change_email, to: :profile

  def profile
    Profile.new
  end
end

describe Fastdfs::Client::Delegation do 

  let(:user){  User.new }

  it "user should be three methods" do 
    expect(user.respond_to?(:messages)).to be_truthy
    expect(user.respond_to?(:blog)).to be_truthy
    expect(user.respond_to?(:change_email)).to be_truthy
    expect(user.respond_to?(:title)).to be_falsey
  end

  it "user method receive argments" do 
    expect(user.messages(25, 0)).to eq([25, 0])
    expect(user.blog).to eq(BLOG_URI)
    expect(user.change_email{ "hello" }).to eq("hello")
  end

  it "argments of the execption" do 
    begin
      user.messages(25) 
    rescue Exception => e
      expect(e).to be_a_kind_of(ArgumentError)  
    end

    begin
      user.change_email     
    rescue Exception => e
      expect(e).to be_a_kind_of(LocalJumpError)  
    end  
  end

end