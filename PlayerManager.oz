functor
import
	Player1
   Player2
   PlayerBasicAI
   Player
export
	playerGenerator:PlayerGenerator
define
	PlayerGenerator
in
	fun{PlayerGenerator Kind Color ID}
		case Kind
		of player2 then {Player2.portPlayer Color ID}
		[] player1 then {Player1.portPlayer Color ID}
		[]playerBasicAI then {PlayerBasicAI.portPlayer Color ID}
		   []player then {Player.portPlayer Input.colors.1 1}% je pense que c'est comme ca qu'il faut generer les ID
		end
	end
end
