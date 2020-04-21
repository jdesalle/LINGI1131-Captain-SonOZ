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
		  if {List.Member PositionsAvailable pt(x:TestPoint.x+1 y:TestPoint.y)} then
		     {NewPoint T pt(x:TestPoint.x+1 y:TestPoint.y)} %si c'est west ca veut dire que le player a bouge a gauche donc on fait aller le point a droite
		  else
		     false
		  end		  
	       []east then
		  if {List.Member PositionsAvailable pt(x:TestPoint.x-1 y:TestPoint.y)} then
		     {NewPoint T pt(x:TestPoint.x-1 y:TestPoint.y)}
		  else
		     false
		  end		     
	       []south then
		  if {List.Member PositionsAvailable pt(x:TestPoint.x y:TestPoint.y-1)} then
		     {NewPoint T pt(x:TestPoint.x y:TestPoint.y-1)}%quand le joueur descend il augmente son y de 1 donc on diminue le y de 1
		  else
		     false
		  end
	       []north then
		  if {List.Member PositionsAvailable pt(x:TestPoint.x y:TestPoint.y+1)} then
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
   %in:item we want to fire (mine or missile) notre position et si on est autorise a se prendre des degats et de combien
   %out:best position to fire the item
   fun{FindFirePosition KindItem OurPosition CanTakeDamage HowMuch}
      
   end
   

end
