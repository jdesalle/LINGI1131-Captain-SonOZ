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
		   []player then {Player.portPlayer Color ID}
		end
	end
end
