define
   FindPlayerPosition
in

   
   %returns a list of potential positions of a player
   %PositionsAvailable est la liste des positions ou le joueur pourrait etre (normalement les positions sans iles, mais ca veut dire qu'on peut utiliser l'info des drones et sonar!)
   %PlayerState est la liste des directions prises par le joueur (surface peut pas etre dedans car alors la liste devient vide)
   fun{FindPlayerPosition PositionsAvailable DirectionList}
      local NewPoint in
	 %IN:Point ou on veut tester si le sous marin ennemi peut etre
	 %OUT: true si le sous marin peut etre la avec l'info qu'on a false sinon
	 fun{NewPoint TestPoint}
	    case {List.reverse DirectionList} of H|T then %on retourne la liste car on veut voir si le path emprunte peut mener au point, et pas ou va le sous marin
	       case H of west then
		  if {List.Member pt(x:TestPoint.x+1 y:TestPoint.y) PositionsAvailable} then
		     {NewPoint T pt(x:TestPoint.x+1 y:TestPoint.y)} %si c'est west ca veut dire que le player a bouge a gauche donc on fait aller le point a droite
		  else
		     false
		  end		  
	       []east then
		  if {List.Member pt(x:TestPoint.x-1 y:TestPoint.y) PositionsAvailable} then
		     {NewPoint T pt(x:TestPoint.x-1 y:TestPoint.y)}
		  else
		     false
		  end		     
	       []south then
		  if {List.Member pt(x:TestPoint.x y:TestPoint.y-1) PositionsAvailable} then
		     {NewPoint T pt(x:TestPoint.x y:TestPoint.y-1)}%quand le joueur descend il augmente son y de 1 donc on diminue le y de 1
		  else
		     false
		  end
	       []north then
		  if {List.Member pt(x:TestPoint.x y:TestPoint.y+1) PositionsAvailable} then
		     {NewPoint T pt(x:TestPoint.x y:TestPoint.y+1)}
		  else
		     false
		  end		  
	       end	       
	    []nil then true % on est au bout de la liste, si on a pas deja rendu false on rends true
	    end	    
	 end  
	 {List.filter PositionsAvailable NewPoint}
      end
   end

   %trouve ou tirer en fonction de l'item donné
   %in:item we want to fire (mine or missile) State et si on est autorise a se prendre des degats et de combien
   %out: if we should fire the item and the best position to fire the item. out(fire:Boolean where:Position)
   fun{FindMissileFirePosition PositionsToChooseFrom PositionsInRange State CanTakeDamage HowMuch}
      local IsInRange InRangeAndProbable WillNotDamage BestOKDamage
      in
	 fun{IsInRange Point}
	    {List.Member Point PositionsInRange}
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
	 BestOKDamage={List.filter Best WillNotDamage}
	 case BestOKDamage of H|T then
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
	    {List.Member Mine PositionsToChooseFrom}
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
	 case BestOKDamage of H|T then
	    out(fire:true where:{PickRandom BestOKDamage})
	 []nil then out(fire:false where:pt(x:1 y:1))
	 end	 
      end 
   end



   
  % otherPlayerState(id:ID directions:Directions isAlive:IsAlive)
   fun{EditOtherPlayersState OtherPlayerState DirectionToAdd IsAlive} % On aura une liste de ces etats, qui contient les etats pour chaque joueur
      if IsAlive then
	 case DirectionToAdd of surface then %On decide de ne pas enregistrer surface car on s'en sert pas mais on pourrait le faire facilement ici
	    otherPlayerState(id:OtherPlayerState.id directions:OtherPlayerState.directions isAlive:OtherPlayerState.isAlive)
	 []_ then
	    otherPlayerState(id:OtherPlayerState.id directions:{List.append OtherPlayerState.directions DirectionToAdd|nil} isAlive:OtherPlayerState.isAlive)
	 end	 
      else
	 otherPlayerState(id:OtherPlayerState.id directions:nil isAlive:false)
      end
   end

   %To check if player is in stateList
   fun{IsInStateList ID List}
      case List of H|T then
	 if List.1.id==ID then true
	 else
	    {IsInStateList ID List.2}
	 end
      []nil then false
      end
   end

   
end
   
