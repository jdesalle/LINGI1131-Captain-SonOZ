functor
import
   Input
   System
   OS
export
   portPlayer:StartPlayer
define
   StartPlayer
   TreatStream

   InitPosition
   Move
   Dive
   ChargeItem
   FireItem
   FireMine
   IsDead
   SayMove
   SaySurface
   SayCharge
   SayMinePlaced
   SayMissileExplode
   SayMineExplode
   SayPassingDrone
   SayAnswerDrone
   SayPassingSonar
   SayAnswerSonar
   SayDeath
   SayDamageTaken
   %Added By me
   PlayerID %assignes par la fonction startplayer qui est appellee par le playerGenerator qui est lui meme appelle quand on cree les ports dans le main
   %L'ID est assigne par la fonction StartPlayer qui est apellee avec les bons arguments dans le player generator.
   %Le playerGenerator est appell� quand on cree les ports dans le main
   ModifState
   AvailablePositions
   PickRandom
   Spawn
   PositionsAva
   ManhattanDistance
   PositionsInRange
in

   thread
      PositionsAva={AvailablePositions}%position ou il n'y a pas d'iles
      Spawn={PickRandom PositionsAva}% un spawn choisi au hasard
   end



   % state(pastPosition:PastPositions items:Items charges:Charges currentPosition:CurrentPosition surface:Surface placedMines:PlacedMines life:Life)
   proc{TreatStream Stream State}
      case Stream of initPosition(ID Position)|T then
	 {System.show 'treating initPosition'}
	 {TreatStream T {InitPosition ?ID ?Position}}


	 %----------------Actions--------
      []move(ID Position Direction)|T then
	 if State.life=<0 then
	    ID=null
	    {TreatStream T State}
	 else
	    {TreatStream T {Move ?ID ?Position ?Direction State}}
	 end

      []dive|T then
	 {TreatStream T {Dive State}}
      []chargeItem(ID KindItem)|T then
	 if State.life=<0 then
	    ID=null
	    {TreatStream T State}
	 else
	    {TreatStream T {ChargeItem ?ID ?KindItem State}}
	 end

      []fireItem(ID KindFire)|T then
	 if State.life=<0 then
	    ID=null
	    {TreatStream T State}
	 else
	    {TreatStream T {FireItem ?ID ?KindFire State}}
	 end

      []fireMine(ID Mine)|T then
	 if State.life=<0 then
	    ID=null
	    {TreatStream T State}
	 else
	    {TreatStream T {FireMine ?ID ?Mine State}}
	 end

      []isDead(Answer)|T then
	 {TreatStream T {IsDead ?Answer State}}
      %--------------Messages-

      []sayMove(ID Direction)|T then
	 if ID== null then {TreatStream T State}
	 else
	    {TreatStream T {SayMove ID Direction State}}
	 end
      []saySurface(ID)|T then
	 if ID== null then {TreatStream T State}
	 else
	    {TreatStream T {SaySurface ID State}}
	 end
      []sayCharge(ID KindItem)|T then
	 if ID== null then {TreatStream T State}
	 else
	    {TreatStream T {SayCharge ID KindItem State}}
	 end
      []sayMinePlaced(ID)|T then
	 if ID== null then {TreatStream T State}
	 else
	    {TreatStream T {SayMinePlaced ID State}}
	 end
      []sayMissileExplode(ID Position Message)|T then
	 if ID== null then
	    Message=null
	    {TreatStream T State}
	 else
	    {TreatStream T {SayMissileExplode ID Position ?Message State}}
	 end
      []sayMineExplode(ID Position Message)|T then
	 if ID== null then
	    Message=null
	    {TreatStream T State}
	 else
	    {TreatStream T {SayMineExplode ID Position ?Message State}}
	 end
      []sayPassingDrone(Drone ID Answer)|T then
	 if State.life=<0 then %Je suis pas sur pour ceci qu'il faille bind Answer a null aussi
	    ID=null
	    Answer=null
	    {TreatStream T State}
	 else
	    {TreatStream T {SayPassingDrone Drone ?ID ?Answer State}}
	 end
      []sayAnswerDrone(Drone ID Answer)|T then
	 if ID== null then {TreatStream T State}
	 else
	    {TreatStream T {SayAnswerDrone Drone ID Answer State}}
	 end
      []sayPassingSonar(ID Answer)|T then
	 if State.life=<0 then %Je suis pas sur pour ceci qu'il faille bind Answer a null aussi
	    ID=null
	    Answer=null
	    {TreatStream T State}
	 else
	    {TreatStream T {SayPassingSonar ?ID ?Answer State}}
	 end
      []sayAnswerSonar(ID Answer)|T then
	 if ID== null then {TreatStream T State}
	 else
	    {TreatStream T {SayAnswerSonar ID Answer State}}
	 end
      []sayDeath(ID)|T then
	 if ID== null then {TreatStream T State}
	 else
	    {TreatStream T {SayDeath ID State}}
	 end
      []sayDamageTaken(ID Damage LifeLeft)|T then
	 if ID== null then {TreatStream T State}
	 else
	    {TreatStream T {SayDamageTaken ID Damage LifeLeft State}}
	 end
      end
   end


   %----------------------------------------------------
   %------------Fonctions Initialisation----------------
   %----------------------------------------------------
   fun{StartPlayer Color ID}%Ici l'ID et la couleur sont deja assignes par le player generator, on peut les recuperer je pense. Sinon ca couille mon player
      Stream
      Port
   in
      {NewPort Stream Port}
      thread
	 PlayerID=id(id:ID color:Color name:'playerstupid')
	 {TreatStream Stream nil}
      end
      Port
   end


   fun{InitPosition ?ID ?Position}
      ID=PlayerID
      Position=Spawn
      {ModifState nil items(missile:0 mine:0 sonar:0 drone:0) charges(missile:0 mine:0 sonar:0 drone:0) Position surface(surface:true time:0) nil Input.maxDamage}
      %le premier tour on est surface et au tour suivant on peut dive Verifier que le surface time est correct.
   end


   %-------------------------------------------------
   %-------Fonctions pour les messages:--------------
   %-------------------------------------------------
   fun{IsDead ?Answer State}
      if State.life=<0 then Answer=true
	 State
      else
	 Answer=false
	 State
      end
   end

   fun{SayMove ID Direction State}
      {System.show 'Player of ID:'#ID#'is moving'#Direction#'!'}
      State
   end

   fun{SaySurface ID State}
      {System.show 'Player of ID:'#ID#'is surfacing!'}
      State
   end

   fun{SayCharge ID KindItem State}
      {System.show 'Player of ID:'#ID#' has charged '#KindItem#'!'}
      State
   end

   fun{SayMinePlaced ID State}
      {System.show 'Player of ID:'#ID#' has placed a mine somewhere!'}
      State
   end


   fun{SayMissileExplode ID Position ?Message State}
      local Dis in
	 Dis={ManhattanDistance State Position}
   if Dis==null then
    Message=sayDamageTaken(ID 0 State.life)
	 elseif State.life - Dis =<0 then
	    Message=sayDeath(ID)
	 else
	    Message=sayDamageTaken(ID Dis State.life-Dis)
	 end
	 {System.show Message}
	 State
      end
   end

   fun{SayMineExplode ID Position ?Message State} %Exactement la meme fonction que sayMissile Explode. Moyen de le traiter dans le case of mais pas sur qui'il faille
      local Dis in
	 Dis={ManhattanDistance State Position}
   if Dis==null then
   Message=sayDamageTaken(ID 0 State.life)
	 elseif State.life-Dis=<0 then
	    Message=sayDeath(ID)
	 else Message=sayDamageTaken(ID Dis State.life-Dis)
	 end
	 {System.show Message}
	 State
      end
   end

   fun{SayPassingDrone Drone ?ID ?Answer State}
      ID=PlayerID
      case Drone of drone(row X) then %Je suis pas sur que le case of drone(row x) soit syntaxiquement correct. A tester.
	 if X==State.currentPosition.x then Answer=true
	 else Answer=false
	 end
      []drone(column Y) then
	 if Y==State.currentPosition.y then Answer=true
	 else Answer=false
	 end
      end
      State
   end

   fun{SayAnswerDrone Drone ID Answer State}
      {System.show 'Drone has been sent at '#Drone#' and the answer is '#Answer#' Player identified is '#ID}
      State
   end

   fun{SayDeath ID State}
      {System.show 'Player of ID '#ID#' died. May he rest in peace'}
      State
   end


   fun{SayDamageTaken ID Damage LifeLeft State}
      {System.show 'Player of ID ' #ID# ' has taken '#Damage# 'damage. He still has ' #LifeLeft# ' lives' }
      State
   end

   %On renvoie notre position avec au hasard soit x soit y qui est correct. La position incorrecte est generee au hasard
   fun{SayPassingSonar ?ID ?Answer State}
      ID=PlayerID
      if ({OS.rand}mod 2)+1 == 1 then
	 Answer=pt(x:State.currentPosition.x y:({OS.rand} mod Input.nColumn)+1)
      else
	 Answer=pt(x:({OS.rand} mod Input.nRow)+1 y:State.currentPosition.y)
      end
      State
   end

   fun{SayAnswerSonar ID Answer State}
      {System.show 'Player of ID' #ID# ' has been identified by a sonar at position ' #Answer}
      State
   end



   %----------------------------------------------
   %-----Fonctions pour les actions:--------------
   %----------------------------------------------
   %On bouge randomly. Si on sait pas bouger on surface
   %retourne le nouveau state
   fun{Move ?ID ?Position ?Direction State}
      ID=PlayerID
      local CardDirections Choose IsPossible in
	 CardDirections= 'east'|'west'|'south'|'north'|nil
      %IN: east ou west ou north ou south
      %OUT: ans(bool:Bool position:Pos) Bool=true si on peu se deplacer dans cette direction, Pos vaut notre nouvelle position si on se deplace par la
	 fun{IsPossible Direction}
	    local NewPos CurrentX CurrentY in
	       CurrentX=State.currentPosition.x
	       CurrentY=State.currentPosition.y
	       case Direction of east then
		  NewPos=pt(x:CurrentX y:CurrentY+1)
		  if {List.member NewPos PositionsAva}==true andthen {List.member NewPos State.pastPosition}==false then
		     ans(bool:true position:NewPos)
		  else
		     ans(bool:false position:pt(x:1 y:1))
		  end
	       []west then
		  NewPos=pt(x:CurrentX y:CurrentY-1)
		  if {List.member NewPos PositionsAva}==true andthen {List.member NewPos State.pastPosition}==false then
		     ans(bool:true position:NewPos)
		  else
		     ans(bool:false position:pt(x:1 y:1))
		  end
	       []north then
		  NewPos=pt(x:CurrentX-1 y:CurrentY)
		  if {List.member NewPos PositionsAva}==true andthen {List.member NewPos State.pastPosition}==false then
		     ans(bool:true position:NewPos)
		  else
		     ans(bool:false position:pt(x:1 y:1))
		  end
	       []south then
		  NewPos=pt(x:CurrentX+1 y:CurrentY)
		  if {List.member NewPos PositionsAva}==true andthen {List.member NewPos State.pastPosition}==false then
		     ans(bool:true position:NewPos)
		  else
		     ans(bool:false position:pt(x:1 y:1))
		  end
	       end
	    end
	 end
      %will choose a random direction D in the list, if it is impossible for the player to move in direction D it will remove D from the list and retry.
      %If there are no more directions in the list then we surface
      %IN:List of <carddirections>
      %OUT: State updated with the correct direction randomly chosen.
	 fun{Choose Directs}
	    if Directs==nil then
	       Direction='surface'
	       Position=State.currentPosition
	       {ModifState nil State.items State.charges Position surface(surface:true time:Input.turnSurface) State.placedMines State.life}
	    else
	       local X  IsNotX Possible in
		  X={PickRandom Directs}
		  fun{IsNotX Ele}
		     if Ele==X then false
		     else
			true
		     end
		  end
          %la fonction isPossible teste si on peut aller dans cette direction
		  Possible={IsPossible X}
		  if Possible.bool then
		     Direction=X
		     Position=Possible.position
		     {ModifState {List.append State.pastPosition Position|nil} State.items State.charges Position State.surface State.placedMines State.life}
		  else
		     {Choose {List.filter Directs IsNotX}}
		  end
	       end
	    end
	 end
	 {Choose CardDirections}
      end
   end


   %Si on peut charger on charge le missile en premier, sinon la mine, sinon le drone, sinon le sonar.
   fun{ChargeItem ?ID ?KindItem State}
      ID=PlayerID
      if State.charges.missile+1<Input.missile then
	 KindItem=missile
	 {ModifState State.pastPosition State.items charges(missile:State.charges.missile+1 mine:State.charges.mine sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface State.placedMines State.life}
      elseif State.charges.missile+1==Input.missile then
	 KindItem=missile
	 {ModifState State.pastPosition items(missile:State.items.missile+1 mine:State.items.mine sonar:State.items.sonar drone:State.items.drone) charges(missile:0 mine:State.charges.mine sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface State.placedMines State.life}
      elseif State.charges.mine+1 < Input.mine then
	 KindItem=mine
	 {ModifState State.pastPosition State.items charges(missile:State.charges.missile mine:State.charges.mines+1 sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface State.placedMines State.life}
      elseif State.charges.mine+1 == Input.mine then
	 KindItem=mine
	 {ModifState State.pastPosition items(missile:State.items.missile mine:State.items.mine+1 sonar:State.items.sonar drone:State.items.drone) charges(missile:State.charges.missile mine:0 sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface State.placedMines State.life}
      elseif State.charges.drone+1 <Input.drone then
	 KindItem=drone
	 {ModifState State.pastPosition State.items charges(missile:State.charges.missile mine:State.charges.mine sonar:State.charges.sonar drone:State.charges.drone+1) State.currentPosition State.surface State.placedMines State.life}
      elseif State.charges.drone+1 == Input.drone then
	 KindItem=drone
	 {ModifState State.pastPosition items(missile:State.items.missile mine:State.items.mine sonar:State.items.sonar drone:State.items.drone+1) charges(missile:State.charges.missile mine:State.charges.mines sonar:State.charges.sonar drone:0) State.currentPosition State.surface State.placedMines State.life}
      elseif State.charges.sonar+1 < Input.sonar then
	 KindItem=sonar
	 {ModifState State.pastPosition State.items charges(missile:State.charges.missile mine:State.charges.mines sonar:State.charges.sonar+1 drone:State.charges.drone) State.currentPosition State.surface State.placedMines State.life}
      else
	 KindItem=sonar
	 {ModifState State.pastPosition items(missile:State.items.missile mine:State.items.mine sonar:State.items.sonar+1 drone:State.items.drone) charges(missile:State.charges.missile mine:State.charges.mine sonar:0 drone:State.charges.drone) State.currentPosition State.surface State.placedMines State.life}
      end
   end

   %On tire d'abord un missile, si on a pas ce sera une mine, un drone et puis un sonar et sinon rien. On tire a une position random
   fun{FireItem ?ID ?KindFire State}
      ID=PlayerID
      local CanFire in
	 fun{CanFire Item State}
	    State.items.Item >0
	 end
	 if {CanFire 'missile' State} then
	    KindFire=missile({PickRandom {PositionsInRange missile PositionsAva State}})%ducoup on peut se tirer sur soi meme
	    {ModifState State.pastPosition items(missile:State.items.missile-1 mine:State.items.mine sonar:State.items.sonar drone:State.items.drone) State.charges State.currentPosition State.surface State.placedMines State.life}
	 elseif {CanFire 'mine' State} then
	    local MinePosition in
	       MinePosition={PickRandom {PositionsInRange mine PositionsAva State}}
	       KindFire=mine(MinePosition) %Strategie pourrie mais en theorie on arrive pas la car on charge toujours le missile en premier et si c'est charge on le tire...
	       {ModifState State.pastPosition items(missile:State.items.missile mine:State.items.mine-1 sonar:State.items.sonar drone:State.items.drone) State.charges State.currentPosition State.surface {List.append State.placedMines MinePosition|nil} State.life}
	    end
	 elseif {CanFire 'drone' State} then
	    KindFire=drone(row {PickRandom PositionsAva}.y)% meme chose
	    {ModifState State.pastPosition items(missile:State.items.missile mine:State.items.mine sonar:State.items.sonar drone:State.items.drone-1) State.charges State.currentPosition State.surface State.placedMines State.life}
	 elseif {CanFire 'sonar' State} then
	    KindFire=sonar
	    {ModifState State.pastPosition items(missile:State.items.missile mine:State.items.mine sonar:State.items.sonar-1 drone:State.items.drone) State.charges State.currentPosition State.surface State.placedMines State.life}
	 else
	    KindFire=null
	    State
	 end
      end
   end

   %makes a previously placed mine explode
   %Si on a une ou plusieur mines on en fait exploser une au hasard.
   fun{FireMine ?ID ?Mine State}
      ID=PlayerID
      case State.placedMines of _|_ then
	 Mine={PickRandom State.placedMines}
	 {ModifState State.pastPosition State.items State.charges State.currentPosition State.surface {List.subtract State.placedMines Mine} State.life}
      []nil then
	 Mine=null
	 State
      end
   end




   fun{Dive State}
      {ModifState nil State.items State.charges State.currentPosition surface(surface:false time:0) State.placedMines State.life}
   end




   %----------------------------------------------------------------
   %-------------Autres Fonctions------------------------------------------
   %-----------------------------------------------------------------


   fun{ModifState PastPositions Items Charges CurrentPosition Surface PlacedMines Life}
      state(pastPosition:PastPositions items:Items charges:Charges currentPosition:CurrentPosition surface:Surface placedMines:PlacedMines life:Life)
   end

   %return damage taken by the submarine at the current the position from the explosion at located at Position.
   %Damage is calculated proportionnally to the manhattanDistance
   fun{ManhattanDistance State Position}
      local Xsub Ysub Xex Yex Distance in
	 Xsub=State.currentPosition.x
	 Ysub=State.currentPosition.y
	 Xex=Position.x
	 Yex=Position.y
	 Distance={Number.abs Xsub-Xex}+{Number.abs Ysub-Yex}
	 if Distance >=2 then null
	 elseif Distance==1 then 1
	 else
	    2
	 end
      end
   end



   %Returns a list of positions pt(x:X y:Y) where there is no island
   fun{AvailablePositions}
      fun{AvailablePositionsAAA Acc X Y Result}
	 case Acc of _|_ then
	    if X>=Input.nRow then
	       if Acc.1\=1 then {AvailablePositionsAAA Acc.2 1 Y+1 {List.append Result pt(x:X y:Y)|nil}}
	       else
		  {AvailablePositionsAAA Acc.2 1 Y+1 Result}
	       end
	    else
	       if Acc.1 \=1 then {AvailablePositionsAAA Acc.2 X+1 Y {List.append Result pt(x:X y:Y)|nil}}
	       else
		  {AvailablePositionsAAA Acc.2 X+1 Y Result}
	       end
	    end
	 []nil then
	    Result.2 %on est au bout, on skip le premier element qui est 000
	 end
      end
   in
      {AvailablePositionsAAA {List.flatten Input.map} 1 1 000|nil}
   end

   %prends un element au hasard dans une liste
   fun{PickRandom Liste}
      local Num Len in
	 Len={List.length Liste}
	 Num=({OS.rand} mod Len)+1
	 {List.nth Liste Num}%Prends le Num element de la liste
      end
   end

   %returns a list of positions where the item can be fired
   fun{PositionsInRange KindItem PositionsAva State}
      local Distance MineBool MissBool in
	 fun{Distance Position}% donne la manhattan distance entre la position actuelle et Position
	    {Number.abs State.currentPosition.x-Position.x}+{Number.abs State.currentPosition.y-Position.y}
	 end

	 fun{MineBool Pos}%retoune true si la mine peut etre placee a la position pos
	    local Dist={Distance Pos} in
	       if Dist>=Input.minDistanceMine andthen Dist =<Input.maxDistanceMine then true
	       else
		  false
	       end
	    end
	 end

	 fun{MissBool Pos}
	    local Dist={Distance Pos} in
	       if Dist>=Input.minDistanceMissile andthen Dist =<Input.maxDistanceMissile then true
	       else
		  false
	       end
	    end
	 end

	 case KindItem of mine then
	    {List.filter PositionsAva MineBool} %retourne la liste des elements qui satisfont la fonction {MineBool Element} parmis les positions sans iles.
	 []missile then
	    {List.filter PositionsAva MissBool}
	 end
      end
   end
end
