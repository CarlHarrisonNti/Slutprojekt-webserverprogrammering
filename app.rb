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


# Page where admins can see all quizzes in database
#
# @see Model#fetch_quizzes
get "/" do
  p session[:user_id]
  erb :index
end

before "/admin/*" do
  verified = (session[:level] || 0) < 4 && !session[:user_id]
  verified ? halt(401, "Unauthorized") : nil
end


before "/protected/*" do
  verified = (session[:level] || 0) < 3 && !session[:user_id]
  verified ? halt(401, "Unauthorized") : nil
end
