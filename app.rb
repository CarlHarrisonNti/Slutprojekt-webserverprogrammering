require "sinatra"
require "sinatra/reloader"
require "sqlite3"
require "bcrypt"
require 'commonmarker'
require "securerandom"
require_relative "models.rb"
require 'better_errors'
require 'binding_of_caller'
require_relative 'routes/users.rb'
require_relative 'routes/roles.rb'
require_relative 'routes/exercises.rb'
require_relative 'routes/solutions.rb'
require 'sinatra/flash'

include Modules
include Verfiers
use BetterErrors::Middleware

SECTIONS = ["instructions", "tests", "solutions"]

enable :sessions

helpers do
  def exercise_color(difficulty)
    case difficulty
    when 1..3
      "green"
    when 4..6
      "yellow"
    when 7..10
      "red"
    end
  end

  def exercise_difficulty(difficulty)
    case difficulty
    when 1..3
      "Easy"
    when 4..6
      "Medium"
    when 7..10
      "Hard"
    end
  end

  def blurb(text)
    text.size > 100 ? text[..100] + "..." : text
  end

  def max_lines(text, lines)
    text.split("\n")[...lines].join("\n")
  end

  def role_count(id)
    fetch_role_count(id)
  end
end

# Method to create a new file
#
# @param path [String] the path to the file directory
# @param content [String] the content of the file
# @param file_name [String] the name of the file
#
# @return [String] the path of the full path
def create_file(path, content, file_name)
  extension = file_name.split(".").last
  new_file_name = "#{SecureRandom.uuid}.#{extension}"
  file_path = "./public/#{path}/#{new_file_name}"
  File.write(file_path, content)
  new_file_name
end

# Method to delete multiple files
#
# @param paths [Array] the paths to the
# 
# @return [Array] the paths to the files that were deleted
def delete_files(*paths)
  paths.each do |path|
    File.delete(path) if File.exist?(path)
  end
end

# Method to update a file
#
# @param path [String] the path to the file directory
# @param folder [String] the folder of the file
# @param file [File] the file to update
#
# @return [String] the path of the updated file
def update_file(path, folder, file)
  temp_file = file[:tempfile]
  "#{path}/#{create_file(folder, temp_file.read, file[:filename])}"
end

# Method to validate files
#
# @param files [Array<Hash<name: <file: String, extensions: <Array<String>>>> the files to validate
#
# @return [nil]
def validate_files(redirect_url, **files)
  result = []
  files.each do |key, value|
    _, extension = value[:file].split(".")
    result << value[:file] unless value[:extensions].include?(".#{extension}")
  end

  unless result.empty?
    flash.next[:notice] = "The following files are not allowed: #{result.join(", ")}"
    redirect redirect_url
  end
end

# Landing page
get "/" do
  erb :index
end

# Before-block for admin pages
# If the user is not of level 4 or higher, they will be given a 401 error
before "/admin/*" do
  verified = (session[:level] || 0) < 4 && !session[:user_id]
  verified ? halt(401, "Unauthorized") : nil
end

# Before-block for protected pages
# If the user is not of level 3 or higher, they will be given a 401 error
before "/protected/*" do
  verified = (session[:level] || 0) < 3 && !session[:user_id]
  verified ? halt(401, "Unauthorized") : nil
end
