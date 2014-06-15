require_relative "game"


require 'sinatra'

set :views, Proc.new {File.join(root, '..', "views")}
set :public, Proc.new {File.join(root, '..', "public")}

enable :sessions

SUNK_SHIPS_TO_WIN = 1

get '/' do
	session[:game]= create_game
	session[:num_of_players]= 0
	game_created = !game.nil?
	session[:message]= "Player One, please enter your name:"
	erb :index
end

get '/login' do
	redirect '/'
end

post '/login_player_one' do
	session[:player_one]= params[:text]
	session[:num_of_players] += 1
	set_player_name(player_one, (session[:player_one]).to_s)
	session[:message]= "Player Two, please enter your name:"
	erb :index
end

post '/login_player_two' do
	session[:player_two]= params[:text]
	if session[:player_two] != session[:player_one]
		session[:num_of_players] += 1
		set_player_name(player_two, (session[:player_two]).to_s)
		redirect '/setup'
	else
		session[:message]= "This is not a valid name, please try again:"
		erb :index
	end
end

get '/setup' do
	if session[:num_of_players] == 2
		session[:message]= "Welcome #{session[:player_one]} and #{session[:player_two]}!"
		erb :index
	else
		redirect '/'
	end
end

post '/setup' do
	redirect '/setup_player_one'
end

get '/setup_player_one' do
	session[:message]= "#{session[:player_one]}, please select coordinates for battleship:"
	erb :setup
end

post '/place_ship' do
	ship_type=(params[:ship_type]).to_sym
	coords=params[:coords].split(", ").sort.map { |s| s.to_sym }
	ship=nil
		case ship_type
			when :submarine
				if coords.count == 1
					coordinate_1 = Coordinate.new(coords[0])
					coordinates = Coordinates.new(coordinate_1)
					ship = Submarine.new(coordinates)
				end
			when :destroyer
				if coords.count == 2
					coordinate_1 = Coordinate.new(coords[0])
					coordinate_2 = Coordinate.new(coords[1])
					coordinates = Coordinates.new(coordinate_1, coordinate_2)
					if coordinates.valid?
						ship = Destroyer.new(coordinates)
					end
				end
			when :cruiser
				if coords.count == 3
					coordinate_1 = Coordinate.new(coords[0])
					coordinate_2 = Coordinate.new(coords[1])
					coordinate_3 = Coordinate.new(coords[2])
					coordinates = Coordinates.new(coordinate_1, coordinate_2, coordinate_3)
					if coordinates.valid?
						ship = Cruiser.new(coordinates)
					end
				end
			when :battleship
				if coords.count == 4
					coordinate_1 = Coordinate.new(coords[0])
					coordinate_2 = Coordinate.new(coords[1])
					coordinate_3 = Coordinate.new(coords[2])
					coordinate_4 = Coordinate.new(coords[3])
					coordinates = Coordinates.new(coordinate_1, coordinate_2, coordinate_3, coordinate_4)
					if coordinates.valid?
						ship = Destroyer.new(coordinates)
					end
				end
		end
	if !ship.nil?
		place(ship)
		session[:message]= "#{current_player_name}, #{ship_type.to_s.capitalize} placed at coordinates: #{coords.join(', ')}; ship count: #{current_player.ship_count}; occupied coordinates: #{current_player_occupied_coordinates}"
	else
		session[:message]= "ship could not be created"
	end
	erb :setup
end
	
def message
 	session[:message]
end

def player_occupied_coordinates
	game.player_one.occupied_coordinates
end

def player_two_occupied_coordinates
	game.player_two.occupied_coordinates
end

def current_player_occupied_coordinates
	game.current_player.occupied_coordinates
end

def create_game
	Game.new
end

def game
	session[:game]
end

def player_one
	game.player_one
end

def player_two
	game.player_two
end

def current_player
	game.current_turn
end	

def other_player
	game.other_player
end

def switch_turn
	game.switch_turn
end

def	current_player_name
	game.current_player.name
end

def	other_player_name
	game.other_player.name
end

def set_player_name player, new_name
	game.set_player_name(player, new_name)
end

def board_setup_stage
	2.times do
		place_ships_sequence
		switch_turn
	end
end

def place_ships_sequence
	place :battleship
	# 2.times {place :cruiser}
	# 3.times {place :destroyer}
	# 4.times {place :submarine}
end

def place ship
	game.place(ship)
end

def name_of ship_type
	ship_type.to_s.capitalize
end

def play_loop_until_game_over
	while !game.over?
		play_turn
		switch_turn
	end
end

def play_turn
	# coordinate = get_attack_coordinate_from(current_player)
	# print attack_result_message(get_attack_result(coordinate))
end

def get_attack_result(coordinate)
	game.attack(coordinate).to_s.capitalize!
end

def winner_name
	game.winner_name
end





