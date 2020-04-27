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
   PositionsAva
   ManhattanDistance
   PositionsInRange
   FindPlayerPosition
   FindMissileFirePosition
   FindMineToDetonate
   EditEnnemyStateList
in






   % state(pastPosition:PastPositions items:Items charges:Charges currentPosition:CurrentPosition surface:Surface placedMines:PlacedMines life:Life ennemyStateList:ennemyState(id:ID direction:DirectionList)|...|nil)
   proc{TreatStream Stream State PlayerID}
      case Stream of initPosition(ID Position)|T then
	 {System.show 'treating initPosition'}
	 {TreatStream T {InitPosition ?ID ?Position PlayerID}PlayerID}


	 %----------------Actions--------
      []move(ID Position Direction)|T then
	 if State.life=<0 then
	    ID=null
	    {TreatStream T State PlayerID}
	 else
	    {TreatStream T {Move ?ID ?Position ?Direction State PlayerID} PlayerID}
	 end
      []dive|T then
	 {TreatStream T {Dive State} PlayerID}
      []chargeItem(ID KindItem)|T then
	 if State.life=<0 then
	    ID=null
	    {TreatStream T State PlayerID}
	 else
	    {TreatStream T {ChargeItem ?ID ?KindItem State PlayerID} PlayerID}
	 end

      []fireItem(ID KindFire)|T then
	 if State.life=<0 then
	    ID=null
	    {TreatStream T State PlayerID}
	 else
	    {TreatStream T {FireItem ?ID ?KindFire State PlayerID} PlayerID}
	 end
      []fireMine(ID Mine)|T then
	 if State.life=<0 then
	    ID=null
	    {TreatStream T State PlayerID}
	 else
	    {TreatStream T {FireMine ?ID ?Mine State PlayerID} PlayerID}
	 end
      []isDead(Answer)|T then
	 {TreatStream T {IsDead ?Answer State} PlayerID}
      %--------------Messages-

      []sayMove(ID Direction)|T then
	 if ID== null orelse ID==PlayerID then {TreatStream T State PlayerID} %SI c'est notre ID on ignore ou l'id d'un joueur mort
	 else
	    {TreatStream T {SayMove ID Direction State} PlayerID}
	 end
      []saySurface(ID)|T then
	 if ID== null then {TreatStream T State PlayerID}
	 else
	    {TreatStream T {SaySurface ID State} PlayerID}
	 end
      []sayCharge(ID KindItem)|T then
	 if ID== null then {TreatStream T State PlayerID}
	 else
	    {TreatStream T {SayCharge ID KindItem State} PlayerID}
	 end
      []sayMinePlaced(ID)|T then
	 if ID== null then {TreatStream T State PlayerID}
	 else
	    {TreatStream T {SayMinePlaced ID State} PlayerID}
	 end
      []sayMissileExplode(ID Position Message)|T then
	 if ID== null then
	    Message=null
	    {TreatStream T State PlayerID}
	 else
	    {TreatStream T {SayMissileExplode ID Position ?Message State PlayerID} PlayerID}
	 end
      []sayMineExplode(ID Position Message)|T then
	 if ID== null then
	    Message=null
	    {TreatStream T State PlayerID}
	 else
	    {TreatStream T {SayMineExplode ID Position ?Message State PlayerID} PlayerID}
	 end
      []sayPassingDrone(Drone ID Answer)|T then
	 if State.life=<0 then %Je suis pas sur pour ceci qu'il faille bind Answer a null aussi
	    ID=null
	    Answer=null
	    {TreatStream T State PlayerID}
	 else
	    {TreatStream T {SayPassingDrone Drone ?ID ?Answer State PlayerID} PlayerID}
	 end
      []sayAnswerDrone(Drone ID Answer)|T then
	 if ID== null then {TreatStream T State PlayerID}
	 else
	    {TreatStream T {SayAnswerDrone Drone ID Answer State} PlayerID}
	 end
      []sayPassingSonar(ID Answer)|T then
	 if State.life=<0 then %Je suis pas sur pour ceci qu'il faille bind Answer a null aussi
	    ID=null
	    Answer=null
	    {TreatStream T State PlayerID}
	 else
	    {TreatStream T {SayPassingSonar ?ID ?Answer State PlayerID} PlayerID}
	 end
      []sayAnswerSonar(ID Answer)|T then
	 if ID== null then {TreatStream T State PlayerID}
	 else
	    {TreatStream T {SayAnswerSonar ID Answer State} PlayerID}
	 end
      []sayDeath(ID)|T then
	 if ID== null then {TreatStream T State PlayerID}
	 else
	    {TreatStream T {SayDeath ID State} PlayerID}
	 end
      []sayDamageTaken(ID Damage LifeLeft)|T then
	 if ID== null then {TreatStream T State PlayerID}
	 else
	    {TreatStream T {SayDamageTaken ID Damage LifeLeft State} PlayerID}
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
	 PlayerID=id(id:ID color:Color name:'smartPlayer')
	 {TreatStream Stream nil PlayerID}
      end
      Port
   end


   fun{InitPosition ?ID ?Position PlayerID}
      ID=PlayerID
      Position={PickRandom PositionsAva}% un spawn choisi au hasard
      {ModifState Position|nil items(missile:0 mine:0 sonar:0 drone:0) charges(missile:0 mine:0 sonar:0 drone:0) Position surface(surface:true time:0) nil Input.maxDamage nil}
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
      {EditEnnemyStateList State ID Direction}
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


   fun{SayMissileExplode ID Position ?Message State PlayerID}
   {System.show 'player of ID'#ID#'has made a missile explode at position'#Position#'this player:'#PlayerID#'Is updating its life accordingly'}
      local Dis Dam in
	 Dis={ManhattanDistance State Position}
	 if Dis==null then Message=sayDamageTaken(ID 0 State.life)
   Dam=0
	 elseif State.life - Dis =<0 then
	    Message=sayDeath(ID)
      Dam=Dis
	 else
	    Message=sayDamageTaken(ID Dis State.life-Dis)
      Dam=Dis
	 end
	 {System.show Message}
	   {ModifState State.pastPosition State.items State.charges State.currentPosition State.surface State.placedMines State.life-Dam State.ennemyStateList}
      end
   end

   fun{SayMineExplode ID Position ?Message State PlayerID} %Exactement la meme fonction que sayMissile Explode. Moyen de le traiter dans le case of mais pas sur qui'il faille
 {System.show 'player of ID'#ID#'has made a mine explode at position'#Position#'this player:'#PlayerID#'Is updating its life accordingly'}
      local Dis Dam in
	 Dis={ManhattanDistance State Position}
	 if Dis==null then Message=sayDamageTaken(ID 0 State.life)
   Dam=0
	 elseif State.life-Dis=<0 then
	    Message=sayDeath(ID)
      Dam=Dis
	 else Message=sayDamageTaken(ID Dis State.life-Dis)
   Dam=Dis
	 end
	 {System.show Message}
	   {ModifState State.pastPosition State.items State.charges State.currentPosition State.surface State.placedMines State.life-Dam State.ennemyStateList}
      end
   end

   fun{SayPassingDrone Drone ?ID ?Answer State PlayerID}
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
   fun{SayPassingSonar ?ID ?Answer State PlayerID}
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
   %Si on peut aller a droite on y va, sinon on monte, sinon on va a gauche, sinon on descend, sinon on surface.
   %retourne le nouveau state
   fun{Move ?ID ?Position ?Direction State PlayerID}
      ID=PlayerID
      local CurrentX CurrentY in
	 CurrentX=State.currentPosition.x
	 CurrentY=State.currentPosition.y
	 if {List.member pt(x:CurrentX y:CurrentY+1) PositionsAva}==true andthen {List.member pt(x:CurrentX y:CurrentY+1) State.pastPosition}==false then
	    Position=pt(x:CurrentX y:CurrentY+1)
	    Direction='east'
	    {ModifState {List.append State.pastPosition Position|nil} State.items State.charges Position State.surface State.placedMines State.life State.ennemyStateList}
	 elseif  {List.member pt(x:CurrentX-1 y:CurrentY) PositionsAva}==true andthen {List.member pt(x:CurrentX-1 y:CurrentY) State.pastPosition}==false then
	    Position=pt(x:CurrentX-1 y:CurrentY)
	    Direction='north'
	    {ModifState {List.append State.pastPosition Position|nil} State.items State.charges Position State.surface State.placedMines State.life State.ennemyStateList}
	 elseif
	    {List.member pt(x:CurrentX y:CurrentY-1) PositionsAva}==true andthen {List.member pt(x:CurrentX y:CurrentY-1) State.pastPosition}==false then
	    Position=pt(x:CurrentX y:CurrentY-1)
	    Direction='west'
	    {ModifState {List.append State.pastPosition Position|nil} State.items State.charges Position State.surface State.placedMines State.life State.ennemyStateList}
	 elseif  {List.member pt(x:CurrentX+1 y:CurrentY) PositionsAva}==true andthen {List.member pt(x:CurrentX+1 y:CurrentY) State.pastPosition}==false then
	    Position=pt(x:CurrentX+1 y:CurrentY)
	    Direction='south'
	    {ModifState {List.append State.pastPosition Position|nil} State.items State.charges Position State.surface State.placedMines State.life State.ennemyStateList}
	 else
	    Position=pt(x:CurrentX y:CurrentY)
	    Direction='surface'
	    {ModifState Position State.items State.charges Position surface(surface:true time:Input.turnSurface) State.placedMines State.life State.ennemyStateList}
	 end
      end
   end

   %Si on peut charger on charge le missile en premier, sinon la mine, sinon le drone, sinon le sonar.
   fun{ChargeItem ?ID ?KindItem State PlayerID}
      ID=PlayerID
      if State.charges.missile+1<Input.missile then
	 KindItem=missile
	 {ModifState State.pastPosition State.items charges(missile:State.charges.missile+1 mine:State.charges.mine sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface State.placedMines State.life State.ennemyStateList}
      elseif State.charges.missile+1==Input.missile then
	 KindItem=missile
	 {ModifState State.pastPosition items(missile:State.items.missile+1 mine:State.items.mine sonar:State.items.sonar drone:State.items.drone) charges(missile:0 mine:State.charges.mine sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface State.placedMines State.life State.ennemyStateList}
      elseif State.charges.mine+1 < Input.mine then
	 KindItem=mine
	 {ModifState State.pastPosition State.items charges(missile:State.charges.missile mine:State.charges.mines+1 sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface State.placedMines State.life State.ennemyStateList}
      elseif State.charges.mine+1 == Input.mine then
	 KindItem=mine
	 {ModifState State.pastPosition items(missile:State.items.missile mine:State.items.mine+1 sonar:State.items.sonar drone:State.items.drone) charges(missile:State.charges.missile mine:0 sonar:State.charges.sonar drone:State.charges.drone) State.currentPosition State.surface State.placedMines State.life State.ennemyStateList}
      elseif State.charges.drone+1 <Input.drone then
	 KindItem=drone
	 {ModifState State.pastPosition State.items charges(missile:State.charges.missile mine:State.charges.mine sonar:State.charges.sonar drone:State.charges.drone+1) State.currentPosition State.surface State.placedMines State.life State.ennemyStateList}
      elseif State.charges.drone+1 == Input.drone then
	 KindItem=drone
	 {ModifState State.pastPosition items(missile:State.items.missile mine:State.items.mine sonar:State.items.sonar drone:State.items.drone+1) charges(missile:State.charges.missile mine:State.charges.mines sonar:State.charges.sonar drone:0) State.currentPosition State.surface State.placedMines State.life State.ennemyStateList}
      elseif State.charges.sonar+1 < Input.sonar then
	 KindItem=sonar
	 {ModifState State.pastPosition State.items charges(missile:State.charges.missile mine:State.charges.mines sonar:State.charges.sonar+1 drone:State.charges.drone) State.currentPosition State.surface State.placedMines State.life State.ennemyStateList}
      else
	 KindItem=sonar
	 {ModifState State.pastPosition items(missile:State.items.missile mine:State.items.mine sonar:State.items.sonar+1 drone:State.items.drone) charges(missile:State.charges.missile mine:State.charges.mine sonar:0 drone:State.charges.drone) State.currentPosition State.surface State.placedMines State.life State.ennemyStateList}
      end
   end

   %On tire d'abord un missile, si on a pas ce sera une mine, un drone et puis un sonar et sinon rien. On tire a une position random
   fun{FireItem ?ID ?KindFire State PlayerID}
      ID=PlayerID
      local CanFire PositionInRange PositionsToChooseFrom FirePosition in
	 fun{CanFire Item State}
	    State.items.Item >0
	 end
	 if {CanFire 'missile' State} then %si on a un missile on tente de le tirer, si ca marche pas on tire rien
	    PositionInRange={PositionsInRange missile PositionsAva State}
	    PositionsToChooseFrom={FindPlayerPosition PositionsAva {PickRandom State.ennemyStateList}.direction}
	    FirePosition={FindMissileFirePosition PositionsToChooseFrom PositionInRange State false 0}%On s'autorise a prendre 1 degat quand on tire
	    if FirePosition.fire==true then
	       KindFire=missile(FirePosition.where)
	       {ModifState State.pastPosition items(missile:State.items.missile-1 mine:State.items.mine sonar:State.items.sonar drone:State.items.drone) State.charges State.currentPosition State.surface State.placedMines State.life State.ennemyStateList}
	    else
	       KindFire=null
	       State
	    end

	 elseif {CanFire 'mine' State} then %si on a pas de missile on tente de poser une mine au hasard autour de nous
	    local MinePosition in
	       MinePosition={PickRandom {PositionsInRange mine PositionsAva State}}
	       KindFire=mine(MinePosition)
	       {ModifState State.pastPosition items(missile:State.items.missile mine:State.items.mine-1 sonar:State.items.sonar drone:State.items.drone) State.charges State.currentPosition State.surface {List.append State.placedMines MinePosition|nil} State.life State.ennemyStateList}
	    end
	 elseif {CanFire 'drone' State} then %si on a pas de mine ni de missile on tente de tirer un drone quelque part
	    KindFire=drone(row {PickRandom PositionsAva}.y)% On tire un drone sur une ligne au hasard, jamais une colonne
	    {ModifState State.pastPosition items(missile:State.items.missile mine:State.items.mine sonar:State.items.sonar drone:State.items.drone-1) State.charges State.currentPosition State.surface State.placedMines State.life State.ennemyStateList}
	 elseif {CanFire 'sonar' State} then %si on a pas de mine ni de missile ni de drone on tente de tirer un sonar
	    KindFire=sonar
	    {ModifState State.pastPosition items(missile:State.items.missile mine:State.items.mine sonar:State.items.sonar-1 drone:State.items.drone) State.charges State.currentPosition State.surface State.placedMines State.life State.ennemyStateList}
	 else
	    KindFire=null
	    State
	 end
      end
   end

   %makes a previously placed mine explode
   %Si on a une ou plusieur mines on en fait exploser une sur un endroit ou en pense qu'un joueur est
   fun{FireMine ?ID ?Mine State PlayerID}
      ID=PlayerID
      case State.placedMines of _|_ then
	 local PositionsToChooseFrom in
	    PositionsToChooseFrom={FindPlayerPosition PositionsAva {PickRandom State.ennemyStateList}.direction} %on choisi un joueur a tuer au hasard parmis ceux qu'on a enregistre
	    Mine={FindMineToDetonate State PositionsToChooseFrom false 1} %on dit qu'on ne veut pas se tirer sur nous meme
	    {ModifState State.pastPosition State.items State.charges State.currentPosition State.surface {List.subtract State.placedMines Mine} State.life State.ennemyStateList}
	 end
      []nil then
	 Mine=null
	 State
      end
   end

   fun{Dive State}
      {ModifState nil State.items State.charges State.currentPosition surface(surface:false time:0) State.placedMines State.life State.ennemyStateList}
   end


   %----------------------------------------------------------------
   %-------------Autres Fonctions------------------------------------------
   %-----------------------------------------------------------------


   fun{ModifState PastPositions Items Charges CurrentPosition Surface PlacedMines Life EnnemyStateList}
      state(pastPosition:PastPositions items:Items charges:Charges currentPosition:CurrentPosition surface:Surface placedMines:PlacedMines life:Life ennemyStateList:EnnemyStateList)
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
	    if Y>=Input.nColumn then
	       if Acc.1\=1 then {AvailablePositionsAAA Acc.2 X+1 1 {List.append Result pt(x:X y:Y)|nil}}
	       else
		  {AvailablePositionsAAA Acc.2 X+1 1 Result}
	       end
	    else
	       if Acc.1 \=1 then {AvailablePositionsAAA Acc.2 X Y+1 {List.append Result pt(x:X y:Y)|nil}}
	       else
		  {AvailablePositionsAAA Acc.2 X Y+1 Result}
	       end
	    end
	 []nil then
	    Result
	 end
      end
   in
      {AvailablePositionsAAA {List.flatten Input.map} 1 1 nil}
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


   fun{FindPlayerPosition PositionsAvailable DirectionList}
      local NewPoint in
      %IN:Point ou on veut tester si le sous marin ennemi peut etre
      %OUT: true si le sous marin peut etre la avec l'info qu'on a false sinon
	 fun{NewPoint TestPoint}
	    local NewPointAAA in
	    % fonction recursive qui va appliquer le mouvement inverse de DirectionList (donc si c'est east on fait y-1 et pas y+1)
	    %en partant de l'element le plus recent de la liste de direction donc le dernier (d'ou le liste.reverse) a testPoint.
      %La fonction FindPlayerPosition teste cette fonction Newpoint sur chaque case de la grille sans ile donc testPoint sera chaque case de la grille.
	    %A chaque fois qu'on a applique UN mouvement au point on verifie si le mouvement est valide (le point est dans la liste des positionsAvailable). Si c'est le cas on passe a la direction suivante dans la liste des directions et on refait le procede, sinon on renvoie direct false pour ce point
	       fun{NewPointAAA ReversedDirectList Point}
		  case ReversedDirectList of H|T then
		     case H of west then
			if {List.member pt(x:Point.x y:Point.y+1) PositionsAvailable} then
			   {NewPointAAA T pt(x:Point.x y:Point.y+1)}
			else
			   false
			end
		     []east then
			if {List.member pt(x:Point.x y:Point.y-1) PositionsAvailable} then
			   {NewPointAAA T pt(x:Point.x y:Point.y-1)}
			else
			   false
			end
		     []south then
			if {List.member pt(x:Point.x-1 y:Point.y) PositionsAvailable} then
			   {NewPointAAA T pt(x:Point.x-1 y:Point.y)}%quand le joueur descend il augmente son y de 1 donc on diminue le y de 1
			else
			   false
			end
		     []north then
			if {List.member pt(x:Point.x+1 y:Point.y) PositionsAvailable} then
			   {NewPointAAA T pt(x:Point.x+1 y:Point.y)}
			else
			   false
			end
		     end%fin du case of direction
		  []nil then true % on est au bout de la liste de directions!
		  end%fin du case List.reverse
	       end%Fin de NewPointAAA
	       {NewPointAAA {List.reverse DirectionList} TestPoint}
	    end %fin du local NewPointAAA
	 end%fin de NewPoint
	 {List.filter PositionsAvailable NewPoint}
      end%fin du local Newpoint
   end%Fin de findplayerPosition



   %trouve ou tirer en fonction de l'item donn�
   %in:item we want to fire (mine or missile) State et si on est autorise a se prendre des degats et de combien
   %out: if we should fire the item and the best position to fire the item. out(fire:Boolean where:Position)
   fun{FindMissileFirePosition PositionsToChooseFrom PositionInRange State CanTakeDamage HowMuch}
      local IsInRange InRangeAndProbable WillNotDamage BestOKDamage
      in
	 fun{IsInRange Point}
	    {List.member Point PositionInRange}
	 end
	 %Returns false si le point donne des degats trop importants
	 %Returns true si le point donne de degats acceptables
	 fun{WillNotDamage Point}
	    local DamageTaken in
	       DamageTaken={ManhattanDistance State Point}
	       if DamageTaken==null then true
	       elseif CanTakeDamage==true andthen DamageTaken =<HowMuch then true
	       else
		  false
	       end
	    end
	 end

	 InRangeAndProbable={List.filter PositionsToChooseFrom IsInRange}
	 BestOKDamage={List.filter InRangeAndProbable WillNotDamage}
	 case BestOKDamage of _|_ then
	    out(fire:true where:{PickRandom BestOKDamage})
	 []nil then out(fire:false where:pt(x:1 y:1))
	 end
      end
   end


   %PositionsToChooseFrom sont les positions probables d un joueur
   %Regarde si une mine placee avant est sur une PositionToChooseFrom et ne nous ferait pas trop de degats en explosant.
   %OUT: out(fire:Boolean where:pt)
   fun{FindMineToDetonate State PositionsToChooseFrom CanTakeDamage HowMuch}
      local IsUseful UsefulMines WillNotDamage BestOKDamage in
	 fun{IsUseful PlacedMine}
	    {List.member PlacedMine PositionsToChooseFrom}
	 end

	 fun{WillNotDamage Point}
	    local DamageTaken in
	       DamageTaken={ManhattanDistance State Point}
	       if DamageTaken==null then true
	       elseif CanTakeDamage==true andthen DamageTaken =<HowMuch then true
	       else
		  false
	       end
	    end
	 end

	 UsefulMines={List.filter State.placedMines IsUseful}
	 BestOKDamage={List.filter UsefulMines WillNotDamage}
	 case BestOKDamage of _|_ then
	    out(fire:true where:{PickRandom BestOKDamage})
	 []nil then out(fire:false where:pt(x:1 y:1))
	 end
      end
   end

   % state(pastPosition:PastPositions items:Items charges:Charges currentPosition:CurrentPosition surface:Surface placedMines:PlacedMines life:Life EnnemyStateList:ennemyState(id:ID direction:DirectionList)|..|nil)
  % ennemyState(id:ID direction:DirectionsList)
   fun{EditEnnemyStateList State ID Direction} % On aura une liste de ces etats, qui contient les etats pour chaque joueur
      local IsId IsNotId Temp Temporary NewEnnemyState NewEnnemyStateList IsInStateList
      in
	 fun{IsId EnnemyState}
	    if EnnemyState.id==ID then true
	    else
	       false
	    end

	 end

	 fun{IsNotId EnnemyState}
	    if EnnemyState.id==ID then false
	    else
	       true
	    end
	 end

	 fun{IsInStateList ID Liste} %To check if player is in stateList
	    case Liste of _|_ then
	       if Liste.1.id==ID then true
	       else
		  {IsInStateList ID Liste.2}
	       end
	    []nil then false
	    end
	 end

	 if {IsInStateList ID State.ennemyStateList}==true then
         %si l'id du player auquel on veut ajouter une direction est dans la EnnemyStateList on le vire de la liste.
	 %On le stocke dans Temp et on stocke le reste de la liste dans Temporary
	    Temp={List.filter State.ennemyStateList IsId}.1
	    Temporary={List.filter State.ennemyStateList IsNotId}
	    NewEnnemyState=ennemyState(id:Temp.id direction:{List.append Temp.direction Direction|nil})
	    NewEnnemyStateList={List.append Temporary NewEnnemyState|nil}
	    {ModifState State.pastPosition State.items State.charges State.currentPosition State.surface State.placedMines State.life NewEnnemyStateList}
	 else
	    NewEnnemyState=ennemyState(id:ID direction:Direction|nil)
	    {ModifState State.pastPosition State.items State.charges State.currentPosition State.surface State.placedMines State.life {List.append State.ennemyStateList NewEnnemyState|nil}}
	 end
      end
   end

  % state(pastPosition:PastPositions items:Items charges:Charges currentPosition:CurrentPosition surface:Surface placedMines:PlacedMines life:Life otherPlayersState:OtherPlayersStateList)

   PositionsAva={AvailablePositions}%position ou il n'y a pas d'iles


end
