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
   PlayerID=1
   ModifState
   AvailablePositions
   PickRandom
   Spawn
   PositionsAva
   BindID
in

   thread
      PositionsAva={AvailablePositions}%position ou il n'y a pas d'iles
      Spawn={PickRandom PositionsAva}% un spawn choisi au hasard
   end



   % state(pastPosition:PastPositions items:Items charges:Charges currentPosition:CurrentPosition surface:Surface)
   proc{TreatStream Stream State} % as as many parameters as you want
      case Stream of initPosition(ID Position)|T then
	 {System.show 'treating initPosition'}
	 {TreatStream T {InitPosition ID Position}}


	 %----------------Actions---------Work in progress...
      []move(ID Position Direction)|T then
	 {TreatStream T {Move ID Position Direction State}}
      []dive|T then
	 {TreatStream T {Dive State}}
      []chargeItem(ID KindItem)|T then
	 {TreatStream T {ChargeItem ID KindItem State}}
      []fireItem(ID KindFire)|T then
	 {TreatStream T {FireItem ID KindFire State}}
      []fireMine(ID Mine)|T then
	 {TreatStream T {FireMine ID Mine State}}
      []isDead(Answer)|T then
	 skip
      %--------------Messages--WIP

      []sayMove(ID Direction)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMove ID Direction State}}
	 end
      []saySurface(ID)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SaySurface ID State}}
	 end
      []sayCharge(ID KindItem)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayCharge ID KindItem State}}
	 end
      []sayMinePlaced(ID)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMinePlaced ID State}}
	 end
      []sayMissileExplode(ID Position Message)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMissileExplode ID State}}
	 end
      []sayMineExplode(ID Position Message)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayMineExplode ID Position Message State}}
	 end
      []sayPassingDrone(Drone ID Answer)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayPassingDrone Drone ID Answer State}}
	 end
      []sayAnswerDrone(Drone ID Answer)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayAnswerDrone Drone ID Answer State}}
	 end
      []sayPassingSonar(ID Answer)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayPassingSonar ID Answer State}}
	 end
      []sayAnswerSonar(ID Answer)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayAnswerSonar ID Answer State}}
	 end
      []sayDeath(ID)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayDeath ID}}
	 end
      []sayDamageTaken(ID Damage LifeLeft)|T then
	 if ID== null then skip
	 else
	    {TreatStream T {SayDamageTaken ID Damage LifeLeft State}}
	 end
      end
   end


   %----------------------------------------------------
   %------------Fonctions Initialisation----------------
   %----------------------------------------------------
   fun{StartPlayer Color ID}
      Stream
      Port
   in
      {NewPort Stream Port}
      thread
	 {TreatStream Stream nil}
      end
      Port
   end


   fun{InitPosition ID Position}
      ID=PlayerID
      Position=Spawn
      {ModifState nil items(missile:0 mine:0 sonar:0 drone:0) charges(missile:0 mine:0 sonar:0 drone:0) Position surface(surface:true time:0) nil}
      %le premier tour on est surface et au tour suivant on peut dive?
   end


   %-------------------------------------------------
   %-------Fonctions pour les messages:--------------
   %-------------------------------------------------
   fun{SayMove ID Direction State}
      ID=PlayerID
      {System.show 'Player of ID:'#ID#'is moving'#Direction#'!'}
      State
   end


   %----------------------------------------------
   %-----Fonctions pour les actions:--------------
   %----------------------------------------------
   %Si on peut aller a droite on y va, sinon on monte, sinon on va a gauche, sinon on descend, sinon on surface.
   %retourne le nouveau state
   fun{Move ID Position Direction State}
      {BindID ID}
      local CurrentX CurrentY in
	 CurrentX=State.currentPosition.x
	 CurrentY=State.currentPosition.y
	 if {List.member pt(x:CurrentX+1 y:CurrentY) PositionsAva}==true andthen {List.member pt(x:CurrentX+1 y:CurrentY) State.pastPositions}==false then
	    Position=pt(x:CurrentX+1 y:CurrentY)
	    Direction='east'
	    {ModifState {List.append State.pastPositions Position|nil} State.items State.charges Position State.surface State.placedMines}
	 elseif  {List.member pt(x:CurrentX y:CurrentY+1) PositionsAva}==true andthen {List.member pt(x:CurrentX y:CurrentY+1) State.pastPositions}==false then
	    Position=pt(x:CurrentX y:CurrentY+1)
	    Direction='north'
	    {ModifState {List.append State.pastPositions Position|nil} State.items State.charges Position State.surface State.placedMines}
	 elseif
	    {List.member pt(x:CurrentX-1 y:CurrentY) PositionsAva}==true andthen {List.member pt(x:CurrentX-1 y:CurrentY) State.pastPositions}==false then
	    Position=pt(x:CurrentX-1 y:CurrentY)
	    Direction='west'
	    {ModifState {List.append State.pastPositions Position|nil} State.items State.charges Position State.surface State.placedMines}
	 elseif  {List.member pt(x:CurrentX y:CurrentY-1) PositionsAva}==true andthen {List.member pt(x:CurrentX y:CurrentY-1) State.pastPositions}==false then
	    Position=pt(x:CurrentX y:CurrentY-1)
	    Direction='south'
	    {ModifState {List.append State.pastPositions Position|nil} State.items State.charges Position State.surface State.placedMines}
	 else
	    Position=pt(x:CurrentX y:CurrentY)
	    Direction='surface'
	    {ModifState nil State.items State.charges Position surface(surface:true time:Input.turnSurface) State.placedMines}
	 end
      end
   end

   %Si on peut charger on charge le missile en premier, sinon la mine, sinon le drone, sinon le sonar.
   fun{ChargeItem ID KindItem State}
      {BindID ID}
      if State.charges.missile+1<Input.missile then
	 KindItem=missile
	 {ModifState State.pastPositions State.items charges(missile:State.charges.missile+1 mine:State.charges.mine sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface State.placedMines}
      elseif State.charges.missile+1==Input.missile then
	 KindItem=missile
	 {ModifState State.pastPositions items(missile:State.items.missile+1 mine:State.items.mine sonar:State.items.sonar drone:State.items.drone) charges(missile:0 mine:State.charges.mine sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface State.placedMines}
      elseif State.charges.mine+1 < Input.mine then
	 KindItem=mine
	 {ModifState State.pastPositions State.items charges(missile:State.charges.missile mine:State.charges.mines+1 sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface State.placedMines}
      elseif State.charges.mine+1 == Input.mine then
	 KindItem=mine
	 {ModifState State.pastPositions items(missile:State.items.missile mine:State.items.mine+1 sonar:State.items.sonar drone:State.items.drone) charges(missile:State.charges.missile mine:0 sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface State.placedMines}
      elseif State.charges.drone+1 <Input.drone then
	 KindItem=drone
	 {ModifState State.pastPositions State.items charges(missile:State.charges.missile mine:State.charges.mine sonar:State.charges.sonar drone:State.charges.drone+1) State.currentPosition State.surface State.placedMines}
      elseif State.charges.drone+1 == Input.drone then
	 KindItem=drone
	 {ModifState State.pastPositions items(missile:State.items.missile mine:State.items.mine sonar:State.items.sonar drone:State.items.drone+1) charges(missile:State.charges.missile mine:State.charges.mines sonar:State.charges.sonar drone:0) State.currentPosition State.surface State.placedMines}
      elseif State.charges.sonar+1 < Input.sonar then
	 KindItem=sonar
	 {ModifState State.pastPositions State.items charges(missile:State.charges.missile mine:State.charges.mines sonar:State.charges.sonar+1 drone:State.charges.drone) State.currentPosition State.surface State.placedMines}
      else
	 KindItem=sonar
	 {ModifState State.pastPositions items(missile:State.items.missile mine:State.items.mine sonar:State.items.sonar+1 drone:State.items.drone) charges(missile:State.charges.missile mine:State.charges.mine sonar:0 drone:State.charges.drone) State.currentPosition State.surface State.placedMines}
      end
   end

   %On tire d'abord un missile, si on a pas ce sera une mine, un drone et puis un sonar et sinon rien. On tire a une position random
   fun{FireItem ID KindFire State}
      {BindID ID}
      local CanFire in
	 fun{CanFire Item State}
	    State.items.Item >0
	 end
	 if {CanFire 'missile' State} then
	    KindFire=missile({PickRandom PositionsAva})
	    {ModifState State.pastPositions items(missile:State.items.missile-1 mine:State.items.mine sonar:State.items.sonar drone:State.items.drone) State.charges State.currentPosition State.surface State.placedMines}
	 elseif {CanFire 'mine' State} then
	    local MinePosition in
	       MinePosition={PickRandom PositionsAva}
	       KindFire=mine(MinePosition) %Strategie pourrie mais en theorie on arrive pas la car on charge toujours le missile en premier et si c'est charge un le tire...
	       {ModifState State.pastPositions items(missile:State.items.missile mine:State.items.mine-1 sonar:State.items.sonar drone:State.items.drone) State.charges State.currentPosition State.surface {List.append State.placedMines MinePosition|nil}}
	    end
	 elseif {CanFire 'drone' State} then
	    KindFire=drone(row {PickRandom PositionsAva}.y)% meme chose
	    {ModifState State.pastPositions items(missile:State.items.missile mine:State.items.mine sonar:State.items.sonar drone:State.items.drone-1) State.charges State.currentPosition State.surface State.placedMines}
	 elseif {CanFire 'sonar' State} then
	    KindFire=sonar
	    {ModifState State.pastPositions items(missile:State.items.missile mine:State.items.mine sonar:State.items.sonar-1 drone:State.items.drone) State.charges State.currentPosition State.surface State.placedMines}
	 else
	    KindFire=null
	    State
	 end
      end
   end

   %makes a previously placed mine explode
   %Si on a une ou plusieur mines on en fait exploser une au hasard.
   fun{FireMine ID Mine State}
      {BindID ID}
      case State.placedMines of H|T then
	 Mine={PickRandom T}
	 {ModifState State.pastPositions State.items State.charges State.currentPosition State.surface {List.subtract State.placedMines Mine}}
      []nil then
	 Mine=null
	 State
      end
   end






   fun{Dive State}
      {ModifState nil State.items State.charges State.currentPosition surface(surface:false time:0) State.placedMines}
   end




   %----------------------------------------------------------------
   %-------------Autres Fonctions------------------------------------------
   %-----------------------------------------------------------------
   proc{BindID ID}
      if {Value.isFree ID} then ID=PlayerID
      else
	 skip
      end
   end



   fun{ModifState PastPositions Items Charges CurrentPosition Surface PlacedMines}
      state(pastPosition:PastPositions items:Items charges:Charges currentPosition:CurrentPosition surface:Surface placedMines:PlacedMines)
   end



   %Returns a list of positions pt(x:X y:Y) where there is no island
   fun{AvailablePositions}
      fun{AvailablePositionsAAA Acc X Y Result}
	 case Acc of H|T then
	    if X>=Input.nColumn then
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
      local Res in
	 Res={AvailablePositionsAAA {List.flatten Input.map} 1 1 000|nil}
	 Res
      end
   end

   %prends un element au hasard dans une liste
   fun{PickRandom Liste}
      local Num Len in
	 Len={List.length Liste}
	 Num=({OS.rand} mod Len)+1
	 {List.nth Liste Num}%Prends le Num element de la liste
      end
   end

end
