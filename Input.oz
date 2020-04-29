functor
import
   OS
export
   isTurnByTurn:IsTurnByTurn
   nRow:NRow
   nColumn:NColumn
   map:Map
   nbPlayer:NbPlayer
   players:Players
   colors:Colors
   thinkMin:ThinkMin
   thinkMax:ThinkMax
   turnSurface:TurnSurface
   maxDamage:MaxDamage
   missile:Missile
   mine:Mine
   sonar:Sonar
   drone:Drone
   minDistanceMine:MinDistanceMine
   maxDistanceMine:MaxDistanceMine
   minDistanceMissile:MinDistanceMissile
   maxDistanceMissile:MaxDistanceMissile
   guiDelay:GUIDelay
define
   IsTurnByTurn
   NRow
   NColumn
   Map
   NbPlayer
   Players
   Colors
   ThinkMin
   ThinkMax
   TurnSurface
   MaxDamage
   Missile
   Mine
   Sonar
   Drone
   MinDistanceMine
   MaxDistanceMine
   MinDistanceMissile
   MaxDistanceMissile
   GUIDelay
   CreateMatrix
in

%%%% Style of game %%%%

   IsTurnByTurn = true

%%%% Description of the map %%%%

  fun{CreateMatrix Nrow Ncol}
   local CreateMatrixAAA CreateRow in
      fun{CreateRow}% creates list of 1 and 0 randomly
	 local CreateRowAAA GenerateNum in
	    fun{CreateRowAAA Acc}
	       if{List.length Acc}<Ncol then
		  local Y  in
		     Y={GenerateNum}
		     {CreateRowAAA {List.append Acc Y|nil}}
		  end    
	       else
		  Acc
	       end
	    end
	    fun{GenerateNum}%generates either a 1 or a 0 but more frequently 0
	       local Z ZZ in
		  Z={OS.rand} mod 2
		  if Z==1 then %If we feel we still have too many ones simply do an OS random a third time
		     ZZ={OS.rand} mod 2
		     if ZZ==1 then
			{OS.rand} mod 2
		     else
			ZZ
		     end    
		  else
		     Z
		  end
	       end  
	    end	       
	    {CreateRowAAA nil}
	 end
      end    
      fun{CreateMatrixAAA Acc Rows}
	 local X in
	    if Rows>0 then
	       X={CreateRow}
	       {CreateMatrixAAA {List.append Acc X|nil} Rows-1}
	    else
	       Acc
	    end
	 end	 
      end
      {CreateMatrixAAA [0] Nrow}.2 
   end
end
   NRow = 15
   NColumn = 15

   Map={CreateMatrix NRow NColumn}
 %  Map = [[0 0 0 0 0 0 0 0 0 0]
	  % [0 0 0 0 0 0 0 0 0 0]
	  % [0 0 0 1 1 0 0 0 0 0]
	  % [0 0 1 1 0 0 1 0 0 0]
	  % [0 0 0 0 0 0 0 0 0 0]
	  % [0 0 0 0 0 0 0 0 0 0]
	  % [0 0 0 1 0 0 1 1 0 0]
	  % [0 0 1 1 0 0 1 0 0 0]
	  % [0 0 0 0 0 0 0 0 0 0]
	  % [0
   %0 0 0 0 0 0 0 0 0]]

%%%% Players description %%%%

   NbPlayer = 4
   Players = [playerBasicAI playerBasicAI player004Random player004Smart]
   Colors = [red green yellow blue]

%%%% Thinking parameters (only in simultaneous) %%%%

   ThinkMin = 500
   ThinkMax = 3000

%%%% Surface time/turns %%%%

   TurnSurface = 3

%%%% Life %%%%

   MaxDamage = 4

%%%% Number of load for each item %%%%

   Missile = 3
   Mine = 3
   Sonar = 3
   Drone = 3

%%%% Distances of placement %%%%

   MinDistanceMine = 1
   MaxDistanceMine = 2
   MinDistanceMissile = 1
   MaxDistanceMissile = 4

%%%% Waiting time for the GUI between each effect %%%%

   GUIDelay = 500 % ms

end
