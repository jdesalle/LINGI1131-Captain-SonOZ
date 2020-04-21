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
		   %[]player then {Player.portPlayer Input.colors.1 id(id:1 color:Input.Colors.1 name:Kind)}
		end
	end
end
