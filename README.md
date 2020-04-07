# ProjetOZ2
projet OZ2  2019/2020 CaptainSonOZ

=======
**overleaf du rapport**:https://www.overleaf.com/project/5e8aeda58259d10001fd5513

**project description**: https://moodleucl.uclouvain.be/pluginfile.php/2093466/mod_resource/content/1/main.pdf

**deadline**: 29 avril 18H
>>>>>>> 8433890773b3e0742e43d041dc81854c37e7e746



PSEUDO CODE:

#Turn by turn gameplay:
  initGame()
  while(nobodyDead)
    startTurn()
  endGame()





#functions definitions
----------------------------------------------
#initGame()
lets player 1 and 2 choose position
#startTurn()
  if canPlay==false:
    if count==0:
      canPlay=true
    else:
      count=count-1
      nextTurn()      
  else:
    isAtSurface()
    chooseDirection(key)
    chargeItem(key)
    fireItem(key)
    explodeMine(key)
------------------------------------------------
#nextTurn()
Launch startTurn() for other player and ends this player turn.
-----------------------------------------------
#radio(message)
sends name of player + message in the chat

#GUI(position,ammo,health)
Update the position of the submarine on the map, the amount of ammo and health.

#isAtSurface()
  if isAtSurface==true:
    isAtSurface=false
    radio(diving)
    GUI(diving)
    nextTurn()
  else:
    do nothing and continue turn

#chooseDirection
if key==spacebar:
  radio(diving)
  GUI(diving)
  canPlay=false
  count=input.turnSurface
  nextTurn()
else:
  checkCanMove()
  radio(direction)
  GUI(direction)

#chargeItem
if key==d:
  canReload?
  radio(reload Drone)
  GUI(reloadDrone)
  nextTurn()
if key=m
    canReload?
    radio(reload mine)
    GUI(reloadMine)
    nextTurn()
if key=f
  canReload?
  radio(reload missile)
  GUI(reloadMissile)
  nextTurn()
if key=s
  canReload?
  radio(reload sonar)
  GUI(reloadSonar)

#fireMissile
  canFire?
  radio(Missile Fired at position x y)
  GUI(missileFired)
  checkHit()
  nextTurn()

#explodeMine
canExplode?
radio(Mine exploded at position x y)
GUI(mineExploded)
checkHit()

#checkHit()
checks if other player is hit and update life.

#endGame
display scoreboard and stats. Propose play again.
